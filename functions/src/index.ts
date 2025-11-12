import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";
import * as dotenv from "dotenv";
dotenv.config();

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
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

// 🧠 Detect current season & trending topic
function getSeasonalContext(): string {
  const month = new Date().getMonth();
  if ([11, 0, 1].includes(month)) return "winter, holidays, new year vibes";
  if ([2, 3, 4].includes(month)) return "spring, flowers, festivals, fresh energy";
  if ([5, 6, 7].includes(month)) return "summer, beach, travel, sunshine";
  return "fall, halloween, cozy weather, gratitude";
}

// 🪄 Function to generate trend-aware, seasonal prompts
async function generatePrompt(): Promise<string> {
  const examples = [
    "Draw a snowman celebrating Diwali.",
    "Design a surfboard powered by friendship.",
    "Sketch a pumpkin with WiFi.",
    "Create a plant that grows summer memories.",
  ];

  const context = getSeasonalContext();

  const promptBody = {
    contents: [
      {
        parts: [
          {
            text: `Generate ONE short, fun, creative drawing prompt (under 15 words)
that matches the current ${context} or trending global mood.
Example ideas:
${examples.join("\n")}`,
          },
        ],
      },
    ],
  };

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(promptBody),
    }
  );

  const data = (await response.json()) as GeminiResponse;
  return data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || "No prompt generated.";
}

// ⏱ Refreshes every 20 seconds
export const generateTimedPrompt = functions.https.onRequest(async (_req, res) => {
  try {
    const now = Math.floor(Date.now() / 1000);
    const intervalKey = Math.floor(now / 20);
    const ref = db.collection("prompts").doc("timed");
    const doc = await ref.get();

    if (doc.exists && doc.data()?.intervalKey === intervalKey) {
      res.status(200).json({ success: true, prompt: doc.data()?.prompt, timestamp: doc.data()?.timestamp });
      return;
    }

    const prompt = await generatePrompt();
    const timestamp = new Date().toISOString();
    await ref.set({ prompt, intervalKey, timestamp });

    res.status(200).json({ success: true, prompt, timestamp });
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).json({ success: false, prompt: "Error generating prompt." });
  }
});
