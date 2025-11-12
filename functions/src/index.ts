import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";
import * as dotenv from "dotenv";
import * as functionsV1 from "firebase-functions/v1";

dotenv.config();

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
console.log("🔑 GEMINI_API_KEY loaded:", !!GEMINI_API_KEY);
if (!GEMINI_API_KEY) {
  throw new Error("❌ Missing Gemini API key! Add GEMINI_API_KEY to .env file.");
}

interface GeminiResponse {
  candidates?: {
    content?: {
      parts?: { text?: string }[];
    };
  }[];
}

// 🌤 Detect current seasonal context - Refined
function getSeasonalContext(): string {
  const month = new Date().getMonth();
  if ([11, 0, 1].includes(month))
    return "winter stillness, cozy sweaters, warm lights, and reflection";
  if ([2, 3, 4].includes(month))
    return "spring renewal, bright mornings, soft greens, and new beginnings";
  if ([5, 6, 7].includes(month))
    return "summer adventures, sunshine, open skies, and lazy afternoons";
  return "autumn leaves, changing air, deep colors, and calm moods";
}

// 🌍 Add trending keywords for each month (kept for seasonal variety)
function getTrendingKeywords(month: number): string[] {
  switch (month) {
    case 0:
      return ["AI influencer", "space heater rebellion", "resolutions meme"];
    case 1:
      return ["Valentine’s algorithm", "snowstorm TikTok", "digital detox trend"];
    case 2:
      return ["spring cleaning app", "March meme madness", "quantum dating AI"];
    case 3:
      return ["AI art protest", "cherry blossom filter", "celebrity livestream"];
    case 4:
      return ["summer playlist", "self-care robot", "lazy productivity trend"];
    case 5:
      return ["travel vlog AI", "Pride avatar filter", "cosmic festival"];
    case 6:
      return ["heatwave meme", "retro vacation", "digital garden revival"];
    case 7:
      return ["back-to-school influencer", "nostalgia edit", "late-summer chaos"];
    case 8:
      return ["pumpkin AI latte", "fall decor influencer", "cozycore revival"];
    case 9:
      return ["Halloween filter", "ghost influencer", "spooky playlist bot"];
    case 10:
      return ["gratitude app", "cozy productivity", "AI family dinner"];
    case 11:
      return ["holiday AI commercial", "winter playlist", "snow meme"];
    default:
      return ["AI meme", "daily trend", "weird internet energy"];
  }
}

// 🪄 Generate vague, funny, and trend-aware daily prompts
async function generatePrompt(): Promise<string> {
  const month = new Date().getMonth();
  const seasonContext = getSeasonalContext();
  const trendingKeywords = getTrendingKeywords(month);

  const randomTrend =
    trendingKeywords[Math.floor(Math.random() * trendingKeywords.length)];

  const humorTones = [
    "absurd",
    "deadpan",
    "chaotic",
    "sarcastic",
    "whimsical",
    "self-aware",
    "parody",
    "daydream-like",
    "meta",
    "lazy genius",
  ];
  const randomTone =
    humorTones[Math.floor(Math.random() * humorTones.length)];

  const systemPrompt = `You are a witty, internet-savvy creative prompt generator.
You invent short, vague, and funny drawing prompts that feel like modern memes or surreal jokes.
Rules:
- Output ONE prompt only (under 12 words).
- No quotes, no lists, no explanations.
- Be vague but visual and relatable.
- Gently reference online culture (AI, influencers, memes, trends).
- The prompt should feel like a surreal thought you'd see on social media.`;

  const examples = [
    "A pigeon explaining AI to a confused robot.",
    "The moon joining a group chat about astrology.",
    "A cat becoming a motivational speaker.",
    "A toaster applying for influencer sponsorships.",
    "A cloud trying to cancel the sun.",
    "An avocado giving a TED Talk about anxiety.",
    "A raccoon running a crypto startup.",
    "The internet on vacation, ignoring notifications.",
    "A robot arguing with its own AI therapist.",
    "A ghost updating its social media bio.",
    "A pumpkin trying to become a fashion blogger.",
    "A plant streaming its growth journey live.",
  ];

  const exampleMix = examples.sort(() => Math.random() - 0.5).slice(0, 5).join("\n");

  const userPrompt = `Generate ONE funny, vague drawing prompt in a ${randomTone} tone.
It should feel weirdly relatable and gently reflect online culture like ${randomTrend}.
Include hints of ${seasonContext}.
Keep it short (max 12 words).
Examples:
${exampleMix}`;

  const promptBody = {
    contents: [
      {
        role: "user",
        parts: [{ text: userPrompt }],
      },
    ],
    systemInstruction: { parts: [{ text: systemPrompt }] },
    generationConfig: {
      temperature: 1.4,
      topK: 60,
      topP: 0.95,
    },
  };

  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(promptBody),
      }
    );

    const data = (await response.json()) as GeminiResponse;

    if (!data?.candidates?.length) {
      console.error("⚠️ Gemini API empty response:", data);
      return getFallbackPrompt();
    }

    const text =
      data.candidates[0]?.content?.parts?.[0]?.text?.trim() ||
      getFallbackPrompt();

    console.log("😂 New Funny Prompt:", text);
    return text;
  } catch (error) {
    console.error("❌ Gemini API Error:", error);
    return getFallbackPrompt();
  }
}

// 🪴 Fallback prompt if Gemini fails
function getFallbackPrompt(): string {
  const fallbacks = [
    "A toaster running for president.",
    "The internet taking a nap.",
    "A chicken starting a tech startup.",
    "A UFO confused by modern fashion.",
    "A frog trying to use a smartphone.",
  ];
  return fallbacks[Math.floor(Math.random() * fallbacks.length)];
}

// ✅ Function — returns same prompt for 24 hrs, refreshes after midnight
export const generateDailyPrompt = functions.https.onRequest(
  async (req, res): Promise<void> => {
    try {
      const force = req.query.force === "true";
      const today = new Date().toLocaleDateString("en-US", {
        timeZone: "America/Chicago",
      });

      const ref = db.collection("prompts").doc("daily");
      const doc = await ref.get();

      if (!force && doc.exists && doc.data()?.date === today && doc.data()?.prompt) {
        res.status(200).json({
          success: true,
          prompt: doc.data()?.prompt,
          date: doc.data()?.date,
        });
        return;
      }

      const prompt = await generatePrompt();
      await ref.set({ prompt, date: today });

      res.status(200).json({
        success: true,
        prompt,
        date: today,
      });
    } catch (err) {
      console.error("❌ Error:", err);
      res.status(500).json({
        success: false,
        prompt: "Error generating prompt.",
      });
    }
  }
);

// 🕛 Scheduled function — auto-refreshes daily at midnight CST
export const scheduledDailyPrompt = functionsV1.pubsub
  .schedule("0 0 * * *") // every midnight UTC
  .timeZone("America/Chicago")
  .onRun(async () => {
    try {
      console.log("🌙 Running scheduledDailyPrompt...");

      const today = new Date().toLocaleDateString("en-US", {
        timeZone: "America/Chicago",
      });

      const ref = db.collection("prompts").doc("daily");
      const doc = await ref.get();

      if (doc.exists && doc.data()?.date === today) {
        console.log("🕒 Prompt already up to date for", today);
        return null;
      }

      console.log("✨ Generating a new scheduled prompt for", today);
      const prompt = await generatePrompt();
      await ref.set({ prompt, date: today });

      console.log("✅ New prompt saved:", prompt);
      return null;
    } catch (error) {
      console.error("❌ Scheduled prompt generation failed:", error);
      return null;
    }
  });
