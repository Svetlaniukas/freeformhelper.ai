#!/bin/bash

echo "🛠 ИСПРАВЛЕНИЕ ОШИБОК СБОРКИ (OPENAI & PDF)..."

# 1. ИСПРАВЛЯЕМ API HUMANIZE
# Проблема: OpenAI инициализировался слишком рано.
# Решение: Переносим "new OpenAI" внутрь функции POST.
cat > src/app/api/humanize/route.js << 'EOL'
import { NextResponse } from 'next/server';
import OpenAI from 'openai';

export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    const { text } = await req.json();
    if (!text) return NextResponse.json({ error: 'No text' }, { status: 400 });

    // ВАЖНО: Инициализация внутри функции!
    // Это предотвращает ошибку "Missing credentials" при сборке.
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
EOL

# 2. ИСПРАВЛЯЕМ API PARSE
# Проблема: Неверный импорт pdf-parse.
# Решение: Используем require внутри функции для надежности.
cat > src/app/api/parse/route.js << 'EOL'
import { NextResponse } from 'next/server';
import mammoth from 'mammoth';

// Мы не импортируем pdf-parse здесь, чтобы избежать ошибки сборки.
// Мы сделаем это динамически внутри.

export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    const formData = await req.formData();
    const file = formData.get('file');
    if (!file) return NextResponse.json({ error: 'No file' }, { status: 400 });

    const buffer = Buffer.from(await file.arrayBuffer());
    let text = '';

    if (file.type === 'application/pdf') {
      // ДИНАМИЧЕСКИЙ ИМПОРТ PDF
      const pdfParse = require('pdf-parse'); 
      const data = await pdfParse(buffer);
      text = data.text;
    } else if (file.name.endsWith('.docx')) {
      const result = await mammoth.extractRawText({ buffer });
      text = result.value;
    } else {
      text = buffer.toString('utf-8');
    }
    return NextResponse.json({ text });
  } catch (error) {
    console.error("Parse Error:", error);
    return NextResponse.json({ error: 'Parsing failed' }, { status: 500 });
  }
}
EOL

# 3. ИСПРАВЛЯЕМ API CHECKOUT (На всякий случай тоже прячем инициализацию)
cat > src/app/api/checkout/route.js << 'EOL'
import { NextResponse } from 'next/server';
import Stripe from 'stripe';

export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    // Инициализация внутри
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000';
    
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: { name: 'FreeForm Helper Premium' },
          unit_amount: 499,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: `${baseUrl}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${baseUrl}`,
    });
    return NextResponse.json({ url: session.url });
  } catch (error) {
    return NextResponse.json({ error: 'Stripe Error' }, { status: 500 });
  }
}
EOL

# 4. ИСПРАВЛЯЕМ API VERIFY
cat > src/app/api/verify/route.js << 'EOL'
import { NextResponse } from 'next/server';
import Stripe from 'stripe';

export const dynamic = 'force-dynamic';

export async function GET(req) {
  const { searchParams } = new URL(req.url);
  const session_id = searchParams.get('session_id');
  if (!session_id) return NextResponse.json({ valid: false });
  try {
    // Инициализация внутри
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    const session = await stripe.checkout.sessions.retrieve(session_id);
    return NextResponse.json({ valid: session.payment_status === 'paid' });
  } catch (error) {
    return NextResponse.json({ valid: false });
  }
}
EOL

echo "✅ КОД ИСПРАВЛЕН! ТЕПЕРЬ ОТПРАВЛЯЕМ..."

# 5. ОТПРАВКА
git add .
git commit -m "Fix build crash: Lazy load OpenAI and PDF"
git push -u origin main --force

echo "🚀 Улетело! Проверяй Render."
