import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import dotenv from "dotenv";
import { createClient } from "@supabase/supabase-js";

dotenv.config();

const app = express();

// ✅ تمكين CORS لكل الطلبات (Flutter Web يحتاج هذا)
app.use(cors({
  origin: "*", // يمكن تغييره لاحقاً للـ URL الخاص بك
  methods: ["GET", "POST", "DELETE", "PUT"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(bodyParser.json());

// إعداد Supabase
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

// تسجيل مستخدم جديد
app.post("/register", async (req, res) => {
  const { username, phone_number, password_hash } = req.body;
  console.log("Received /register:", req.body);

  if (!username || !phone_number || !password_hash)
    return res.status(400).json({ message: "Missing fields" });

  try {
    // تحقق من وجود المستخدم مسبقًا
    const { data: existing, error: checkError } = await supabase
      .from("users")
      .select("*")
      .or(`username.eq.${username},phone_number.eq.${phone_number}`);

    if (checkError) {
      console.error("Supabase check error:", checkError);
      return res.status(500).json({ message: checkError.message });
    }

    console.log("Existing users:", existing);

    if (existing.length > 0)
      return res.status(400).json({ message: "User already exists" });

    // إضافة المستخدم
    const { error } = await supabase.from("users").insert([
      { username, phone_number, password_hash }
    ]);

    if (error) {
      console.error("Supabase insert error:", error);
      return res.status(500).json({ message: error.message });
    }

    console.log("User registered successfully:", username);
    res.json({ message: "User registered successfully ✅" });

  } catch (err) {
    console.error("Server error:", err);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// جلب التقارير
app.get("/reports", async (req, res) => {
  const { data, error } = await supabase
    .from("traffic_reports")
    .select("*")
    .order("timestamp", { ascending: false });

  if (error) {
    console.error("Supabase reports error:", error);
    return res.status(500).json({ message: error.message });
  }

  res.json(data);
});

// حذف البيانات القديمة
app.delete("/cleanup", async (req, res) => {
  const { error } = await supabase.rpc("delete_old_reports");
  if (error) {
    console.error("Supabase cleanup error:", error);
    return res.status(500).json({ message: error.message });
  }
  res.json({ message: "Old reports deleted 🧹" });
});
// تسجيل دخول مستخدم
app.post("/login", async (req, res) => {
  const { username, password_hash } = req.body;
  console.log("Received /login:", req.body);

  if (!username || !password_hash)
    return res.status(400).json({ message: "Missing fields" });

  try {
    const { data, error } = await supabase
      .from("users")
      .select("*")
      .or(`username.eq.${username},phone_number.eq.${username}`)
      .eq("password_hash", password_hash);

    if (error) {
      console.error("Supabase login error:", error);
      return res.status(500).json({ message: error.message });
    }

    if (data.length === 0) {
      return res.status(401).json({ message: "بيانات الدخول غير صحيحة" });
    }

    res.json({ message: "Login successful", user: data[0] });
  } catch (err) {
    console.error("Server error:", err);
    res.status(500).json({ message: "Internal Server Error" });
  }
});


// استماع على PORT
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`🚀 Server running on port ${port}`));
// ====== Telegram Bot Section ======
import { Telegraf } from "telegraf";

// تأكدي من وجود التوكن
if (!process.env.BOT_TOKEN) {
  console.error("❌ Missing BOT_TOKEN in .env file");
} else {
  const bot = new Telegraf(process.env.BOT_TOKEN);

  // استقبال أمر /start
  bot.start(async (ctx) => {
    const chatId = ctx.chat.id;
    const username = ctx.chat.username || "Unknown";
    const firstName = ctx.chat.first_name || "";

    // حفظ المستخدم في Supabase لو مش موجود
    const { data: existing, error: checkError } = await supabase
      .from("telegram_users")
      .select("*")
      .eq("chat_id", chatId);

    if (checkError) {
      console.error("Supabase check error:", checkError);
      return ctx.reply("⚠️ Error while saving your info.");
    }

    if (existing.length === 0) {
      const { error } = await supabase.from("telegram_users").insert([
        {
          chat_id: chatId,
          username: username,
          first_name: firstName,
        },
      ]);
      if (error) {
        console.error("Supabase insert error:", error);
        ctx.reply("⚠️ Couldn't save your data.");
      } else {
        ctx.reply(`👋 أهلاً ${firstName}! تم حفظك في قاعدة البيانات ✅`);
      }
    } else {
      ctx.reply(`👋 مرحبًا من جديد ${firstName}!`);
    }
  });

  // أي رسالة نصية ثانية
  bot.on("text", (ctx) => {
    const msg = ctx.message.text.toLowerCase();
    if (msg.includes("ping")) return ctx.reply("pong 🏓");
    ctx.reply("📍 وصلت رسالتك، شكرًا!");
  });
// 🔹 استماع للرسائل الجديدة في القنوات (منشورات نصية فقط)
bot.on("channel_post", async (ctx) => {
  const post = ctx.channelPost;
  if (!post.text && !post.caption) return; // نتجاهل غير النصوص

  const message = post.text || post.caption;

  console.log("📩 New raw message:", message);

  const { error } = await supabase.from("telegram_raw_messages").insert([
    {
      message: message,
      source: "telegram",
    },
  ]);

  if (error) console.error("Supabase insert error:", error.message);
  else console.log("✅ Raw message saved.");
});


  // تشغيل البوت (Polling)
  bot.launch();
  console.log("🤖 Telegram bot is running (polling mode)...");
}
