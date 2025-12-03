import { NextResponse } from 'next/server';
import OpenAI from 'openai';

// Эта строка запрещает Next.js запускать этот файл при сборке
export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    const { text } = await req.json();
    if (!text) return NextResponse.json({ error: 'No text' }, { status: 400 });

    // ВАЖНО: Подключаемся ТОЛЬКО когда пришел запрос от пользователя
    const openai = new OpenAI({ 
      apiKey: process.env.OPENAI_API_KEY 
    });

    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: `You are an expert ghostwriter. Rewrite to be 100% human. 
          Use varied sentence length and unpredictable vocabulary. 
          Do NOT use: "delve", "tapestry", "crucial".`
        },
        { role: "user", content: `Rewrite this:\n\n${text}` }
      ],
      temperature: 1.0, 
    });

    return NextResponse.json({ result: completion.choices[0].message.content });
  } catch (error) {
    console.error("OpenAI Error:", error);
    return NextResponse.json({ error: 'Server Error' }, { status: 500 });
  }
}
