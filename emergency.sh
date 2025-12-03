#!/bin/bash

echo "🚑 ЗАПУСК АВАРИЙНОГО ИСПРАВЛЕНИЯ..."

# 1. ЧИНИМ API HUMANIZE (Добавляем force-dynamic)
cat > src/app/api/humanize/route.js << 'EOL'
import { NextResponse } from 'next/server';
import OpenAI from 'openai';

export const dynamic = 'force-dynamic'; // <--- ВОТ ЭТО СПАСЕТ СБОРКУ

export async function POST(req) {
  try {
    const { text } = await req.json();
    if (!text) return NextResponse.json({ error: 'No text' }, { status: 400 });

    const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

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
    return NextResponse.json({ error: 'Server Error' }, { status: 500 });
  }
}
EOL

# 2. ЧИНИМ API CHECKOUT
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

# 3. ЧИНИМ API VERIFY
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

# 4. ЧИНИМ API PARSE
cat > src/app/api/parse/route.js << 'EOL'
import { NextResponse } from 'next/server';
import pdf from 'pdf-parse';
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
      const data = await pdf(buffer);
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

# 5. ЧИНИМ СТИЛИ (TAILWIND)
cat > tailwind.config.js << 'EOL'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: { extend: {} },
  plugins: [],
};
EOL

cat > postcss.config.js << 'EOL'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOL

echo "✅ ФАЙЛЫ ИСПРАВЛЕНЫ. ОТПРАВЛЯЕМ НА GITHUB..."

# 6. ПРИНУДИТЕЛЬНАЯ ОТПРАВКА (ЧТОБЫ РЕШИТЬ КОНФЛИКТ GIT)
git add .
git commit -m "Emergency Fix: Force dynamic APIs and Styles"
git push -u origin main --force

echo "🚀 УСПЕХ! Проверяй Render через 2 минуты."#!/bin/bash

echo "🚑 ЗАПУСК АВАРИЙНОГО ИСПРАВЛЕНИЯ..."

# 1. ЧИНИМ API HUMANIZE (Добавляем force-dynamic)
cat > src/app/api/humanize/route.js << 'EOL'
import { NextResponse } from 'next/server';
import OpenAI from 'openai';

export const dynamic = 'force-dynamic'; // <--- ВОТ ЭТО СПАСЕТ СБОРКУ

export async function POST(req) {
  try {
    const { text } = await req.json();
    if (!text) return NextResponse.json({ error: 'No text' }, { status: 400 });

    const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

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
    return NextResponse.json({ error: 'Server Error' }, { status: 500 });
  }
}
EOL

# 2. ЧИНИМ API CHECKOUT
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

# 3. ЧИНИМ API VERIFY
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

# 4. ЧИНИМ API PARSE
cat > src/app/api/parse/route.js << 'EOL'
import { NextResponse } from 'next/server';
import pdf from 'pdf-parse';
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
      const data = await pdf(buffer);
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

# 5. ЧИНИМ СТИЛИ (TAILWIND)
cat > tailwind.config.js << 'EOL'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: { extend: {} },
  plugins: [],
};
EOL

cat > postcss.config.js << 'EOL'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOL

echo "✅ ФАЙЛЫ ИСПРАВЛЕНЫ. ОТПРАВЛЯЕМ НА GITHUB..."

# 6. ПРИНУДИТЕЛЬНАЯ ОТПРАВКА (ЧТОБЫ РЕШИТЬ КОНФЛИКТ GIT)
git add .
git commit -m "Emergency Fix: Force dynamic APIs and Styles"
git push -u origin main --force

echo "🚀 УСПЕХ! Проверяй Render через 2 минуты.#!/bin/bash

echo "🚑 ЗАПУСК АВАРИЙНОГО ИСПРАВЛЕНИЯ..."

# 1. ЧИНИМ API HUMANIZE (Добавляем force-dynamic)
cat > src/app/api/humanize/route.js << 'EOL'
import { NextResponse } from 'next/server';
import OpenAI from 'openai';

export const dynamic = 'force-dynamic'; // <--- ВОТ ЭТО СПАСЕТ СБОРКУ

export async function POST(req) {
  try {
    const { text } = await req.json();
    if (!text) return NextResponse.json({ error: 'No text' }, { status: 400 });

    const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

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
    return NextResponse.json({ error: 'Server Error' }, { status: 500 });
  }
}
EOL

# 2. ЧИНИМ API CHECKOUT
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

# 3. ЧИНИМ API VERIFY
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

# 4. ЧИНИМ API PARSE
cat > src/app/api/parse/route.js << 'EOL'
import { NextResponse } from 'next/server';
import pdf from 'pdf-parse';
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
      const data = await pdf(buffer);
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

# 5. ЧИНИМ СТИЛИ (TAILWIND)
cat > tailwind.config.js << 'EOL'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: { extend: {} },
  plugins: [],
};
EOL

cat > postcss.config.js << 'EOL'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOL

echo "✅ ФАЙЛЫ ИСПРАВЛЕНЫ. ОТПРАВЛЯЕМ НА GITHUB..."

# 6. ПРИНУДИТЕЛЬНАЯ ОТПРАВКА (ЧТОБЫ РЕШИТЬ КОНФЛИКТ GIT)
git add .
git commit -m "Emergency Fix: Force dynamic APIs and Styles"
git push -u origin main --force

echo "🚀 УСПЕХ! Проверяй Render через 2 минуты."
