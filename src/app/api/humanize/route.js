import { NextResponse } from 'next/server';
import OpenAI from 'openai';

export const dynamic = 'force-dynamic';

// Функция для добавления заголовков CORS
function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*', // Разрешаем всем (включая расширение)
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };
}

// Обработка предварительного запроса (OPTIONS)
export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders() });
}

export async function POST(req) {
  try {
    const { text } = await req.json();
    if (!text) return NextResponse.json({ error: 'No text' }, { status: 400 }, { headers: corsHeaders() });

    const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: `You are an expert Ghostwriter. Rewrite to be 100% human. 
          Use varied sentence length and unpredictable vocabulary. 
          Do NOT use: "delve", "tapestry", "crucial".`
        },
        { role: "user", content: `Rewrite this:\n\n${text}` }
      ],
      temperature: 1.0, 
    });

    return NextResponse.json(
      { result: completion.choices[0].message.content },
      { headers: corsHeaders() } // Отдаем ответ с разрешающими заголовками
    );

  } catch (error) {
    console.error("OpenAI Error:", error);
    return NextResponse.json({ error: 'Server Error' }, { status: 500 }, { headers: corsHeaders() });
  }
}
