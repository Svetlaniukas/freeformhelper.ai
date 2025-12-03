import { NextResponse } from 'next/server';
import OpenAI from 'openai';

export const dynamic = 'force-dynamic';

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };
}

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
          content: `You are an expert Ghostwriter. 
          OBJECTIVE: Rewrite the text to be 100% Undetectable by AI detectors.
          
          CRITICAL RULES:
          1. **LANGUAGE**: DETECT the language of the input. If input is Russian -> Output Russian. If English -> Output English. NEVER translate.
          2. **STYLE**: Use varied sentence length (Burstiness) and natural vocabulary.
          3. **BANNED**: Do not use "delve", "tapestry", "crucial".`
        },
        { role: "user", content: `Rewrite this text (keep the same language):\n\n${text}` }
      ],
      temperature: 1.0, 
    });

    return NextResponse.json(
      { result: completion.choices[0].message.content },
      { headers: corsHeaders() }
    );

  } catch (error) {
    return NextResponse.json({ error: 'Server Error' }, { status: 500 }, { headers: corsHeaders() });
  }
}
