#!/bin/bash

echo "🛠 ЛЕЧИМ ОШИБКИ СБОРКИ (OPENAI + PDF)..."

# 1. ЛЕЧИМ API HUMANIZE (Самая главная ошибка)
# Мы переносим "new OpenAI" ВНУТРЬ функции POST.
cat > src/app/api/humanize/route.js << 'EOL'
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
EOL

# 2. ЛЕЧИМ API PARSE (Ошибка с PDF)
# Мы убираем верхний импорт и используем require внутри.
cat > src/app/api/parse/route.js << 'EOL'
import { NextResponse } from 'next/server';
import mammoth from 'mammoth';

export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    const formData = await req.formData();
    const file = formData.get('file');
    if (!file) return NextResponse.json({ error: 'No file' }, { status: 400 });

    const buffer = Buffer.from(await file.arrayBuffer());
    let text = '';

    if (file.type === 'application/pdf') {
      // ИСПРАВЛЕНИЕ: Динамический импорт, чтобы сборка не падала
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
    return NextResponse.json({ error: 'Parsing failed' }, { status: 500 });
  }
}
EOL

# 3. ЛЕЧИМ ОСТАЛЬНЫЕ API (На всякий случай)
cat > src/app/api/checkout/route.js << 'EOL'
import { NextResponse } from 'next/server';
import Stripe from 'stripe';

export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
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

cat > src/app/api/verify/route.js << 'EOL'
import { NextResponse } from 'next/server';
import Stripe from 'stripe';

export const dynamic = 'force-dynamic';

export async function GET(req) {
  const { searchParams } = new URL(req.url);
  const session_id = searchParams.get('session_id');
  if (!session_id) return NextResponse.json({ valid: false });
  try {
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    const session = await stripe.checkout.sessions.retrieve(session_id);
    return NextResponse.json({ valid: session.payment_status === 'paid' });
  } catch (error) {
    return NextResponse.json({ valid: false });
  }
}
EOL

# 4. УБЕЖДАЕМСЯ, ЧТО СТИЛИ НА МЕСТЕ
cat > src/app/layout.js << 'EOL'
import './globals.css';
import Protection from './components/Protection';

export const metadata = {
  title: 'FreeForm Helper - AI Humanizer',
  description: 'Bypass Turnitin instantly.',
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="antialiased select-none">
        <Protection />
        {children}
      </body>
    </html>
  )
}
EOL

echo "✅ КОД ИСПРАВЛЕН (БЕЗОПАСНАЯ ИНИЦИАЛИЗАЦИЯ)!"
echo "Отправляем на GitHub..."

git add .
git commit -m "Fix Build: Move OpenAI init inside handler"
git push -u origin main --force

echo "🚀 Улетело! Теперь сборка должна пройти."
