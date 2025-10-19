import { onRequest } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import fetch from "node-fetch";

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Reusable function for both HTTP + scheduled
async function generatePrompt() {
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
    "If your shadow had a personality, what would it be doing?",
    "Combine two holidays into one chaotic celebration.",
    "Design footwear for a time traveler.",
    "What would your phone look like if it had feelings?",
    "Create a Pokémon inspired by your morning routine.",
    "Draw a cloud that just got promoted.",
    "Reimagine your favorite snack as a superhero.",
    "Sketch 'Monday' as a living thing.",
    "Draw a transportation method powered by laughter.",
    "If colors could argue, draw their fight.",
  ];

  const randomExamples = examples.sort(() => 0.5 - Math.random()).slice(0, 5);
  const exampleText = randomExamples.join("\n");

  const url = `https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`;
  const body = {
    contents: [
      {
        parts: [
          {
            text: `You are a creative art prompt generator.
Here are some example prompts for inspiration:
${exampleText}

Now create ONE new, original, imaginative, and funny drawing prompt (under 15 words) that matches this style. Return only the new prompt.`,
          },
        ],
      },
    ],
  };

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  const data: any = await response.json();
  const generatedText =
    data?.candidates?.[0]?.content?.parts
      ?.map((p: any) => p.text)
      .join(" ")
      ?.trim() || "No response generated.";

  console.log("🎨 Daily prompt:", generatedText);
  return { success: true, prompt: generatedText, raw: data };
}

// ✅ HTTP trigger for manual testing
export const generateDailyPrompt = onRequest(async (_req, res) => {
  try {
    const result = await generatePrompt();
    res.status(200).json(result);
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ✅ Automatic trigger every 24 hours
export const autoGeneratePrompt = onSchedule("every 24 hours", async () => {
  try {
    const result = await generatePrompt();
    console.log("✅ Automatically generated daily prompt:", result.prompt);
  } catch (err) {
    console.error("❌ Failed to auto-generate prompt:", err);
  }
});
