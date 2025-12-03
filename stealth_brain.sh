#!/bin/bash

echo "🧠 ОБНОВЛЯЕМ МОЗГ ИИ (MAX STEALTH MODE)..."

cat > src/app/api/humanize/route.js << 'EOL'
import { NextResponse } from 'next/server';
import OpenAI from 'openai';

// Защита от ошибки сборки
export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    const { text } = await req.json();
    if (!text) return NextResponse.json({ error: 'No text' }, { status: 400 });

    // Инициализация внутри (чтобы Render не падал)
    const openai = new OpenAI({ 
      apiKey: process.env.OPENAI_API_KEY 
    });

    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: `You are an expert Ghostwriter. 
          OBJECTIVE: Rewrite the text to be 100% Undetectable by AI detectors (GPTZero, Turnitin).
          
          CRITICAL RULES:
          1. **Temperature 1.0 Behavior**: Be unpredictable. Mix short fragments with long, complex sentences (High Burstiness).
          2. **BANNED WORDS**: NEVER use: "delve", "tapestry", "landscape", "crucial", "paramount", "underscores", "realm", "facilitate", "harness". If you see them, delete or replace with simple words.
          3. **Grandma Test**: Do not sound like a professor. Sound like you are explaining it to a smart friend. Use active voice.
          4. **Imperfections**: It is okay to start sentences with "And" or "But".
          `
        },
        { role: "user", content: `Rewrite this text to pass AI detection:\n\n${text}` }
      ],
      temperature: 1.0, // МАКСИМАЛЬНАЯ ХАОТИЧНОСТЬ
      presence_penalty: 0.2, // Штраф за повторы
      frequency_penalty: 0.3
    });

    return NextResponse.json({ result: completion.choices[0].message.content });
  } catch (error) {
    console.error("OpenAI Error:", error);
    return NextResponse.json({ error: 'Server Error' }, { status: 500 });
  }
}
EOL

echo "✅ ЯДЕРНЫЙ ПРОМПТ ЗАГРУЖЕН!"
echo "Отправляем на GitHub..."

git add .
git commit -m "Update AI Logic: Max Stealth Mode"
git push -u origin main --force
