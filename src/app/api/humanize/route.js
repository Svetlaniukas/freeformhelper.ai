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
    const { text, plan = 'free', profile = {} } = await req.json();
    if (!text) {
      return NextResponse.json({ error: 'No text provided' }, { status: 400, headers: corsHeaders() });
    }

    const wordCount = text.trim().split(/\s+/).length;
    const limit = PLAN_LIMITS[plan] || PLAN_LIMITS.free;

    // Build personalization context from user profile
    const age = profile.age || 22;
    const subject = profile.subject || 'general';
    const level = profile.level || 'college';

    const STYLE_MAP = {
      // Age-based writing style
      young: age < 23
        ? 'Write like a university student in their early 20s. Use casual academic tone, some slang is OK, shorter sentences, simple vocabulary. Avoid sounding too polished or professorial.'
        : age < 30
        ? 'Write like a young professional or graduate student. Confident but not overly formal. Natural vocabulary, occasional contractions.'
        : 'Write like an experienced professional. Clear, direct, mature vocabulary. No slang.',

      // Subject-specific terminology
      terms: {
        nursing: 'Keep all medical/nursing terminology (vitals, assessment, intervention, patient care). These are expected and NOT AI markers.',
        law: 'Keep all legal terminology (precedent, statute, liability, jurisdiction). These are expected.',
        history: 'Use narrative style. Include specific dates and names. Write like telling a story, not analyzing data.',
        science: 'Keep scientific terminology and methodology language. Focus on making the analysis sound personal, not the terms.',
        business: 'Keep business terms (ROI, KPI, market share) but make analysis sound like personal observation, not report.',
        general: '',
      },

      // Level calibration
      level: {
        school: 'High school level. Simple sentences. Basic vocabulary. Some grammatical imperfections are natural.',
        college: 'Undergraduate level. Mix of simple and complex sentences. Show understanding but not mastery.',
        masters: 'Graduate level. Strong analytical voice. More sophisticated vocabulary but still human.',
        phd: 'Doctoral level. Expert tone. Dense but clear. Original insights expected.',
      },
    };

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
            content: `You are ghostwriting as a REAL PERSON — not an AI assistant.

WRITER PROFILE:
- Age: ${age} years old
- Subject: ${subject}
- Academic level: ${level}
- Style: ${STYLE_MAP.young}
- ${STYLE_MAP.terms[subject] || STYLE_MAP.terms.general}
- ${STYLE_MAP.level[level] || STYLE_MAP.level.college}

OBJECTIVE: Rewrite the text as if THIS SPECIFIC PERSON wrote it themselves. The text must pass Turnitin, GPTZero, and Originality.AI.

CRITICAL RULES:
1. LANGUAGE: Detect input language → output SAME language. Never translate.
2. PERSONA: Write as the person described above. A ${age}-year-old ${level} student writes differently than a 35-year-old PhD.
3. IMPERFECTIONS: Real humans make small mistakes. Occasionally start a sentence with "But" or "And". Use contractions naturally. Not every paragraph needs a topic sentence.
4. SENTENCE RHYTHM: Vary dramatically. Some sentences very short. Others longer, with natural pauses and asides — the kind a real person would write when thinking through an idea.
5. VOCABULARY: Match the age and level. A 20-year-old says "a lot" not "a plethora". A PhD student uses precise terms, not flowery ones.
6. BANNED: Never use "delve", "tapestry", "crucial", "landscape", "multifaceted", "moreover", "furthermore", "utilize", "leverage", "in conclusion", "it is worth noting", "plays a crucial role".
7. OUTPUT: Return ONLY the rewritten text. No meta-commentary.`,
          },
          { role: 'user', content: `Rewrite this as if you are the person described above:\n\n${text}` },
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
