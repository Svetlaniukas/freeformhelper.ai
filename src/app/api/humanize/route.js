import { NextResponse } from 'next/server';
import OpenAI from 'openai';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

export async function POST(req) {
  try {
    const { text } = await req.json();
    if (!text) return NextResponse.json({ error: 'No text' }, { status: 400 });

    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: `You are an elite academic ghostwriter. 
          OBJECTIVE: Rewrite the text to bypass AI detection (Turnitin, GPTZero).
          
          STRATEGY:
          1. **Burstiness**: Alternate between very short sentences (fragments ok) and long, winding, complex sentences.
          2. **Perplexity**: Use rare but natural synonyms.
          3. **Imperfections**: Use colloquial transitions ("Frankly,", "Here is the thing,").
          4. **Formatting**: Keep Markdown.
          
          BANNED WORDS: "delve", "tapestry", "landscape", "crucial", "paramount", "underscores", "realm".`
        },
        { role: "user", content: `Rewrite this to be 100% human:\n\n${text}` }
      ],
      temperature: 1.0, 
      presence_penalty: 0.2
    });

    return NextResponse.json({ result: completion.choices[0].message.content });
  } catch (error) {
    return NextResponse.json({ error: 'Server Error' }, { status: 500 });
  }
}
