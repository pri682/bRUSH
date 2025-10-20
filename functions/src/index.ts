import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const GEMINI_API_KEY =
  process.env.GEMINI_API_KEY || functions.config().gemini?.key;

// ✅ Corrected Gemini response type
interface GeminiResponse {
  candidates?: {
    content?: {
      parts?: { text?: string }[];
    };
  }[];
}

// ✅ Function to generate a new creative prompt
async function generatePrompt(): Promise<string> {
  const examples = [
    "What does your brain look like on a happy day?",
    "Redesign money if it didn’t have numbers.",
    "If emotions had uniforms, what would 'curiosity' wear?",
    "Draw the weather inside your head right now.",
    "Merge two animals that would never meet in real life.",
    "Turn your favorite song into a creature.",
    "If dreams had traffic rules, sketch a traffic sign.",
    "Design a chair for an alien.",
    "Reimagine Earth if gravity took weekends off.",
    "Draw a plant that grows emotions instead of fruits.",
  ];

  const promptBody = {
    contents: [
      {
        parts: [
          {
            text: `Generate ONE funny, creative, short drawing prompt (under 15 words).
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

  const text =
    data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() ||
    "No prompt generated.";

  return text;
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
      if (doc.exists && doc.data()?.date === today) {
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