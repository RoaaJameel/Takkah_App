import dotenv from "dotenv";
import { createClient } from "@supabase/supabase-js";
import OpenAI from "openai";

dotenv.config();

// 🗄️ Connect to Supabase
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

// 🤖 Connect to OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// 🧩 Function: Process messages using NLP
async function processMessages() {
  console.log("🧠 Starting NLP Processor...");

  // 1️⃣ Fetch unprocessed messages from telegram_raw_messages
  const { data: rawMessages, error } = await supabase
    .from("telegram_raw_messages")
    .select("*")
    .order("id", { ascending: true });

  if (error) {
    console.error("❌ Error fetching raw messages:", error);
    return;
  }

  if (!rawMessages || rawMessages.length === 0) {
    console.log("ℹ️ No new messages to process.");
    return;
  }

  console.log(`📩 Found ${rawMessages.length} messages to analyze.`);

  // 2️⃣ Process each message
  for (const msg of rawMessages) {
    try {
      const prompt = `
      Analyze the following Arabic message about Palestinian roads.
      Extract the following as JSON:
      {
        "status": "open" | "blocked" | "traffic" | "unknown",
        "location": "<place name or null>",
        "event_type": "checkpoint" | "accident" | "closure" | "normal" | "unknown"
      }
      Message: """${msg.message}"""
      `;

      const completion = await openai.chat.completions.create({
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.2,
      });

      const responseText = completion.choices[0].message.content;
      console.log("🔍 Analysis result:", responseText);

      // 3️⃣ Insert processed data into telegram_processed_messages
      const { error: insertError } = await supabase
        .from("telegram_processed_messages")
        .insert([
          {
            raw_id: msg.id,
            message: msg.message,
            analysis: responseText,
          },
        ]);

      if (insertError) {
        console.error("❌ Error saving analysis:", insertError);
      } else {
        console.log(`✅ Message ${msg.id} processed and saved.`);
      }
    } catch (err) {
      console.error("⚠️ NLP error:", err.message);
    }
  }

  console.log("🏁 Processing completed successfully.");
}

// 🚀 Run
processMessages();
