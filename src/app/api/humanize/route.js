import { NextResponse } from 'next/server';
import OpenAI from 'openai';

export const dynamic = 'force-dynamic';

// Plan word limits (per month)
const PLAN_LIMITS = {
  free: 300,     // 300 words per request, 1 request/day
  pro: 20000,    // 20K words/month
  premium: -1,   // Unlimited
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

    // Enforce word limit for free users
    if (limit !== -1 && wordCount > limit) {
      return NextResponse.json({
        error: 'word_limit',
        message: `Free plan allows ${limit} words per request. You submitted ${wordCount} words.`,
        wordCount,
        limit,
        upgrade: true,
      }, { status: 403, headers: corsHeaders() });
    }

    const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

    const completion = await openai.chat.completions.create({
      model: 'gpt-4o',
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
5. BANNED WORDS: Never use "delve", "tapestry", "crucial", "landscape", "multifaceted", "moreover", "furthermore".
6. OUTPUT: Return ONLY the rewritten text. No explanations, no meta-commentary.`,
        },
        { role: 'user', content: text },
      ],
      temperature: 1.0,
      max_tokens: Math.min(wordCount * 3, 4000),
    });

    const result = completion.choices[0].message.content;
    const tokensUsed = completion.usage?.total_tokens || 0;

    return NextResponse.json({
      result,
      words_in: wordCount,
      words_out: result.trim().split(/\s+/).length,
      tokens_used: tokensUsed,
      plan,
    }, { headers: corsHeaders() });

  } catch (error) {
    console.error('Humanize error:', error.message);
    return NextResponse.json(
      { error: 'Processing failed. Please try again.' },
      { status: 500, headers: corsHeaders() }
    );
  }
}
