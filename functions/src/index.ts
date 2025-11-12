import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";
import * as dotenv from "dotenv";
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

// 🌤 Detect current seasonal context - Made less specific (e.g., removed direct 'pumpkins')
function getSeasonalContext(): string {
  const month = new Date().getMonth();
  if ([11, 0, 1].includes(month))
    return "winter stillness, crystalline structures, deep blues, and reflection";
  if ([2, 3, 4].includes(month))
    return "spring renewal, soft greens, new growth, and bold colors";
  if ([5, 6, 7].includes(month))
    return "summer warmth, bright skies, expansive spaces, and high energy";
  // FIX: Changed "dramatic weather" to "shifting light, and soft ground textures" 
  // to eliminate the strong "wet" trigger.
  return "autumn harvest, deep rich colors, shifting light, and soft ground textures";
}

// 🌍 Add trending keywords for each month (Expanded for more variety and abstract concepts!)
function getTrendingKeywords(month: number): string[] {
  switch (month) {
    case 0: // January
      return ["Frozen Neon", "Arctic Flora", "Clockwork Labyrinth", "Digital Nomad Tent", "Whispering Satellite"];
    case 1: // February
      return ["Cybernetic Heart", "Secret Garden Gate", "Self-Love Portal", "Floating Opera House", "Misty Mountain Base"];
    case 2: // March
      return ["Emerald Cityscape", "Biotech Butterfly", "Ancient Computer Chip", "Celestial Architect", "First Thaw"];
    case 3: // April
      return ["Cosmic Egg", "Rainy Window", "Mythic Beast", "Time-Lapse Flower", "Microplastic Beach"];
    case 4: // May
      return ["Biopunk", "Floating Islands", "Submerged City Hall", "Future Botanical Garden", "Solar Powered Snail"];
    case 5: // June
      return ["Rainbow Galaxy", "Hidden Waterfall", "Tropical Synthwave", "Shattered Mirror Dimension", "Ephemeral Sculpture"];
    case 6: // July
      return ["Sunken Temple", "Glow Stick Party", "Retro Arcade Cabinet", "Molten Metal River", "Desert Glass Tower"];
    case 7: // August
      return ["Desert Oasis", "Star Map", "Golden Hour", "Dimensional Rift", "Quiet Train Station"];
    case 8: // September
      return ["Magical Library", "Changing Leaves", "Cozy Cabin", "Crystal Cave Entrance", "Echoing Wind Chime"];
    case 9: // October
      return ["Glitch Art Ghost", "Haunted Neon Sign", "Spooky Forest Trail", "Candlelit Altar", "Geometric Skeleton"];
    case 10: // November - Highly abstract and less holiday-centric
      return ["Ceremonial Mask", "Deep Sea Explorer", "Floating Library", "Cosmic Cartographer", "Abandoned Carousel"];
    case 11: // December
      return ["Holiday Lights", "Winter Solstice", "Snow Globe Town", "Zero Gravity Sleigh", "Icy Steampunk Gear"];
    default:
      return ["creativity", "art", "friendship", "ephemeral", "cyberpunk"];
  }
}

// 🪄 Generate creative prompt (refined logic for variety and simplicity)
async function generatePrompt(): Promise<string> {
  const month = new Date().getMonth();

  const seasonContext = getSeasonalContext();
  const trendingKeywords = getTrendingKeywords(month);

  // 🎲 Random creative tone (Vastly expanded for more variety)
  const creativeTones = [
    "surreal", "dreamy", "mystical", "nostalgic", "cyberpunk", "retro-futuristic",
    "poetic", "cinematic", "abstract", "playful", "minimalist", "baroque",
    "steampunk", "gothic", "Maximalist", "Vaporwave", "Glitchcore", "Cottagecore",
    "Neo-Expressionist", "Cozy Horror", "Low Poly", "Line Art", "Ukiyo-e",
    "Cartoon", "Claymation", "Pixel Art", "Psychedelic", "Fairycore", "Dark Academia"
  ];
  const randomTone =
    creativeTones[Math.floor(Math.random() * creativeTones.length)];

  // 🌈 Random emotional theme (Expanded for more depth)
  const emotionalThemes = [
    "hope", "curiosity", "peace", "love", "imagination", "freedom", "harmony",
    "energy", "wonder", "Solitude", "Awe", "Relief", "Acceptance", "Melancholy",
    "Excitement", "Tranquility", "Resilience", "Ephemeral", "Jubilation", "Vulnerability"
  ];
  const themeOfDay =
    emotionalThemes[Math.floor(Math.random() * emotionalThemes.length)];

  // 1. Define the model's persona and output rules clearly
  const systemPrompt = `You are a creative prompt generator. Your ONLY job is to generate ONE single, imaginative, raw drawing prompt. The prompt MUST be under 10 words. Do not add quotes, headers, or commentary. Use only **BASIC, COMMON, and simple English vocabulary (3rd-grade reading level max)**. FOCUS on blending the three randomized elements below into a unique, concrete image.`;

  // 2. Define the generation task, emphasizing novelty and the blend of abstract concepts
  const userQuery = `Generate ONE short prompt. The prompt must strictly combine:
1. The style: ${randomTone}
2. The emotion: ${themeOfDay}
3. The trending concept: (Choose ONE from this list: ${trendingKeywords.join(", ")})
Also, incorporate the visual context of ${seasonContext}.`;

  const promptBody = {
    contents: [
      {
        role: "user",
        parts: [{ text: userQuery }],
      },
    ],
    // Using systemInstruction for better persona grounding and negative constraints
    systemInstruction: { parts: [{ text: systemPrompt }] },
    generationConfig: {
      temperature: 0.85, // Adjusted temperature slightly down to encourage less repetitive phrasing
      topK: 50,
      topP: 0.9,
    },
  };

  try {
    // 3. Changed model to a more modern, instruction-following version
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

    console.log("🖌️ New Gemini Prompt:", text);
    return text;
  } catch (error) {
    console.error("❌ Gemini API Error:", error);
    return getFallbackPrompt();
  }
}

// 🪴 Local fallback in case Gemini fails
function getFallbackPrompt(): string {
  const fallbacks = [
    "Floating ice cream mountain.",
    "A cozy snow globe library.",
    "A neon-lit space cat.",
    "Summer beach time machine.",
    "A spooky pumpkin spice forest.",
  ];
  return fallbacks[Math.floor(Math.random() * fallbacks.length)];
}

// ✅ Function — returns same prompt for 24 hrs, refreshes after midnight
export const generateDailyPrompt = functions.https.onRequest(
  async (_req, res): Promise<void> => {
    try {
      const today = new Date().toLocaleDateString("en-US", {
        timeZone: "America/Chicago",
      });

      const ref = db.collection("prompts").doc("daily");
      const doc = await ref.get();

      // 🔹 If today's prompt already exists → reuse it
      if (doc.exists && doc.data()?.date === today && doc.data()?.prompt) {
        res.status(200).json({
          success: true,
          prompt: doc.data()?.prompt,
          date: doc.data()?.date,
        });
        return;
      }

      // 🔹 Otherwise, generate new and save it
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