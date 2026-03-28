import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

const PLAN_LIMITS = {
  free: 300,
  pro: 20000,
  premium: -1,
};

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };
}

export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders() });
}

export async function POST(req) {
  try {
    const { text, plan = 'free' } = await req.json();
    if (!text) {
      return NextResponse.json({ error: 'No text provided' }, { status: 400, headers: corsHeaders() });
    }

    const wordCount = text.trim().split(/\s+/).length;
    const limit = PLAN_LIMITS[plan] || PLAN_LIMITS.free;

    if (limit !== -1 && wordCount > limit) {
      return NextResponse.json({
        error: 'word_limit',
        message: `Free plan allows ${limit} words. You submitted ${wordCount}.`,
        wordCount,
        limit,
        upgrade: true,
      }, { status: 403, headers: corsHeaders() });
    }

    // Use DeepSeek (10x cheaper than OpenAI, same quality for rewriting)
    const apiKey = process.env.DEEPSEEK_API_KEY || process.env.OPENAI_API_KEY;
    const isDeepSeek = !!process.env.DEEPSEEK_API_KEY;
    const baseURL = isDeepSeek ? 'https://api.deepseek.com' : 'https://api.openai.com/v1';
    const model = isDeepSeek ? 'deepseek-chat' : 'gpt-4o-mini';

    const response = await fetch(`${baseURL}/chat/completions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: 'system',
            content: `You are an expert academic writer and editor.
OBJECTIVE: Rewrite the text so it reads as naturally human-written. It must pass AI detection tools (Turnitin, GPTZero, Originality.AI).

RULES:
1. LANGUAGE: Detect the input language. Output in the SAME language. Never translate.
2. STYLE: Vary sentence length naturally. Mix short punchy sentences with longer ones.
3. VOCABULARY: Use natural, contextually appropriate words. Avoid AI-typical phrases.
4. STRUCTURE: Keep the original meaning and argument structure intact.
5. BANNED WORDS: Never use "delve", "tapestry", "crucial", "landscape", "multifaceted", "moreover", "furthermore", "utilize", "leverage".
6. OUTPUT: Return ONLY the rewritten text. No explanations, no meta-commentary.`,
          },
          { role: 'user', content: text },
        ],
        temperature: 1.0,
        max_tokens: Math.min(wordCount * 3, 4000),
      }),
    });

    const data = await response.json();

    if (!data.choices || !data.choices[0]) {
      console.error('AI response error:', JSON.stringify(data).slice(0, 200));
      return NextResponse.json({ error: 'AI processing failed' }, { status: 500, headers: corsHeaders() });
    }

    const result = data.choices[0].message.content;

    return NextResponse.json({
      result,
      words_in: wordCount,
      words_out: result.trim().split(/\s+/).length,
      plan,
      provider: isDeepSeek ? 'deepseek' : 'openai',
    }, { headers: corsHeaders() });

  } catch (error) {
    console.error('Humanize error:', error.message);
    return NextResponse.json(
      { error: 'Processing failed. Please try again.' },
      { status: 500, headers: corsHeaders() }
    );
  }
}
