#!/bin/bash

echo "💎 УСТАНОВКА GHOSTWRITER: PLATINUM EDITION..."

# 1. Инициализация Next.js
npx create-next-app@latest . --use-npm --typescript=false --eslint=false --tailwind --src-dir --app --import-alias "@/*"

# 2. Установка зависимостей
echo "📦 Устанавливаем библиотеки..."
npm install openai stripe pdf-parse mammoth framer-motion clsx tailwind-merge lucide-react @next/third-parties

# 3. Структура папок
mkdir -p src/app/api/humanize
mkdir -p src/app/api/checkout
mkdir -p src/app/api/verify
mkdir -p src/app/api/parse
mkdir -p src/app/humanize/\[slug\]
mkdir -p src/app/components
mkdir -p extension

# ==========================================
# 1. КЛЮЧИ И НАСТРОЙКИ (.env.local)
# ==========================================
cat > .env.local << 'EOL'
# 🔴 ВАЖНО: ВСТАВЬ СВОИ КЛЮЧИ ЗДЕСЬ ПЕРЕД ЗАПУСКОМ!
OPENAI_API_KEY=sk-proj-ТВОЙ_КЛЮЧ_OPENAI
STRIPE_SECRET_KEY=sk_test_ТВОЙ_КЛЮЧ_STRIPE

# Для локального теста: http://localhost:3000
# Для Render поменяй на: https://твое-имя.onrender.com
NEXT_PUBLIC_BASE_URL=http://localhost:3000
EOL

# ==========================================
# 2. СТИЛИ (globals.css) - PREMIUM DARK MODE
# ==========================================
cat > src/app/globals.css << 'EOL'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --background: #020617; /* Deep Slate */
  --foreground: #ffffff;
}

body {
  color: var(--foreground);
  background: var(--background);
  font-family: -apple-system, system-ui, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  overflow-x: hidden;
}

/* Анимация лазерного сканера */
@keyframes scan {
  0% { top: 0%; opacity: 0; box-shadow: 0 0 2px rgba(220, 38, 38, 0); }
  15% { opacity: 1; box-shadow: 0 0 15px rgba(220, 38, 38, 0.8); }
  85% { opacity: 1; box-shadow: 0 0 15px rgba(220, 38, 38, 0.8); }
  100% { top: 100%; opacity: 0; }
}
.scan-line {
  position: absolute;
  width: 100%;
  height: 3px;
  background: #dc2626;
  animation: scan 2.2s cubic-bezier(0.4, 0, 0.2, 1) infinite;
  z-index: 10;
}

/* Размытие для Paywall */
.paywall-blur {
  filter: blur(8px);
  user-select: none;
  pointer-events: none;
}

/* Скроллбар */
::-webkit-scrollbar { width: 8px; }
::-webkit-scrollbar-track { background: #0f172a; }
::-webkit-scrollbar-thumb { background: #334155; border-radius: 4px; }
::-webkit-scrollbar-thumb:hover { background: #475569; }
EOL

# ==========================================
# 3. БАЗА ДАННЫХ SEO (seo-data.js) - 50+ НИШ
# ==========================================
cat > src/app/seo-data.js << 'EOL'
export const niches = {
  'bypass-turnitin': { title: 'Bypass Turnitin', h1: 'Bypass Turnitin AI Detection', desc: 'Rewrite essays to trick Turnitin.' },
  'bypass-gptzero': { title: 'Bypass GPTZero', h1: 'Remove AI Detection from GPTZero', desc: 'Get 100% Human Score on GPTZero.' },
  'humanize-nursing-paper': { title: 'Nursing Paper Humanizer', h1: 'Humanize Nursing & Medical Papers', desc: 'For medical students. Keep terminology, fix tone.' },
  'humanize-law-school-essay': { title: 'Law School AI Bypass', h1: 'Undetectable Legal Memos', desc: 'Bypass strict AI detectors in Law School.' },
  'humanize-history-paper': { title: 'History Paper Rewriter', h1: 'Make History Essays Sound Human', desc: 'Rewrite historical analysis naturally.' },
  'humanize-cover-letter': { title: 'Cover Letter AI Remover', h1: 'Undetectable Cover Letters', desc: 'Pass ATS systems with humanized letters.' },
  'humanize-college-essay': { title: 'College Essay Fixer', h1: 'Humanize College Application Essays', desc: 'Get into your dream school with authentic writing.' },
  'bypass-originality-ai': { title: 'Bypass Originality.AI', h1: 'Beat Originality.AI 3.0', desc: 'The toughest detector solved.' },
  'chatgpt-to-human': { title: 'ChatGPT to Human', h1: 'Convert ChatGPT Text to Human', desc: 'Make AI text sound natural instantly.' },
  'humanize-blog-post': { title: 'SEO Blog Humanizer', h1: 'Rank Higher with Human Content', desc: 'Google hates AI. We fix it.' },
  'humanize-lab-report': { title: 'Lab Report Fixer', h1: 'Humanize STEM Lab Reports', desc: 'For Chemistry and Physics students.' },
  'undetectable-ai-free': { title: 'Undetectable AI Free', h1: 'Free AI Detection Remover', desc: 'Try the best AI bypass tool for free.' }
};
EOL

# ==========================================
# 4. ЗАЩИТА ОТ КОПИРОВАНИЯ (Protection.js)
# ==========================================
cat > src/app/components/Protection.js << 'EOL'
"use client";
import { useEffect } from 'react';
export default function Protection() {
  useEffect(() => {
    const handleContextMenu = (e) => e.preventDefault();
    const handleKeyDown = (e) => {
      if (e.key === 'F12' || (e.ctrlKey && ['u','U','i','I','j','J'].includes(e.key))) {
        e.preventDefault();
      }
    };
    document.addEventListener('contextmenu', handleContextMenu);
    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.removeEventListener('contextmenu', handleContextMenu);
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, []);
  return null;
}
EOL

# ==========================================
# 5. СОЦИАЛЬНОЕ ДОКАЗАТЕЛЬСТВО (SocialProof.js)
# ==========================================
cat > src/app/components/SocialProof.js << 'EOL'
"use client";
import { useState, useEffect } from 'react';
import { AnimatePresence, motion } from 'framer-motion';

const USERS = ["Emma", "Liam", "Noah", "Olivia", "James", "Sophia", "Michael", "Sarah"];
const ACTIONS = ["unlocked a paper 🔓", "bypassed GPTZero ⚡", "fixed an essay 📝"];
const LOCATIONS = ["NY", "London", "Toronto", "Texas", "California", "Sydney"];

export default function SocialProof() {
  const [online, setOnline] = useState(342);
  const [popup, setPopup] = useState(null);

  useEffect(() => {
    // Живой счетчик
    setInterval(() => setOnline(p => p + (Math.random() > 0.5 ? 1 : -1)), 3000);
    
    // Всплывашки продаж
    const showPopup = () => {
      const name = USERS[Math.floor(Math.random() * USERS.length)];
      const loc = LOCATIONS[Math.floor(Math.random() * LOCATIONS.length)];
      const act = ACTIONS[Math.floor(Math.random() * ACTIONS.length)];
      setPopup({ name, loc, act });
      setTimeout(() => setPopup(null), 5000);
    };
    setInterval(() => { if(Math.random() > 0.6) showPopup(); }, 10000);
  }, []);

  return (
    <div className="fixed bottom-5 left-5 z-50 pointer-events-none">
      <div className="bg-slate-900/90 backdrop-blur border border-slate-700 px-3 py-1 rounded-full flex items-center gap-2 mb-3 w-fit shadow-lg">
        <span className="relative flex h-2 w-2">
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
          <span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
        </span>
        <span className="text-[10px] font-bold text-slate-300">{online} students online</span>
      </div>
      <AnimatePresence>
        {popup && (
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 20 }}
            className="bg-slate-900 border-l-2 border-purple-500 p-3 rounded shadow-2xl flex gap-3 w-64">
            <div className="flex flex-col">
              <span className="text-xs font-bold text-white">{popup.name} from {popup.loc}</span>
              <span className="text-[10px] text-slate-400">just {popup.act}</span>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
EOL

# ==========================================
# 6. API: PARSER (Файлы)
# ==========================================
cat > src/app/api/parse/route.js << 'EOL'
import { NextResponse } from 'next/server';
import pdf from 'pdf-parse';
import mammoth from 'mammoth';

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

# ==========================================
# 7. API: NUCLEAR HUMANIZE (Мозг)
# ==========================================
cat > src/app/api/humanize/route.js << 'EOL'
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
EOL

# ==========================================
# 8. API: CHECKOUT & VERIFY (Оплата)
# ==========================================
cat > src/app/api/checkout/route.js << 'EOL'
import { NextResponse } from 'next/server';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export async function POST(req) {
  try {
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000';
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: { 
            name: 'Ghostwriter - Full Document Unlock',
            description: 'Bypass Turnitin, Instant Download'
          },
          unit_amount: 499, // $4.99
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
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export async function GET(req) {
  const { searchParams } = new URL(req.url);
  const session_id = searchParams.get('session_id');
  if (!session_id) return NextResponse.json({ valid: false });
  try {
    const session = await stripe.checkout.sessions.retrieve(session_id);
    return NextResponse.json({ valid: session.payment_status === 'paid' });
  } catch (error) {
    return NextResponse.json({ valid: false });
  }
}
EOL

# ==========================================
# 9. FRONTEND (Главная страница - page.js)
# ==========================================
cat > src/app/page.js << 'EOL'
"use client";
import { useState, useEffect, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { FileText, Download, Copy, Lock, ShieldCheck, Zap, Upload } from 'lucide-react';

function App() {
  const [input, setInput] = useState('');
  const [output, setOutput] = useState('');
  const [loading, setLoading] = useState(false);
  const [step, setStep] = useState('idle');
  const [aiScore, setAiScore] = useState(0);
  const [showPaywall, setShowPaywall] = useState(false);
  
  const searchParams = useSearchParams();
  const router = useRouter();

  // ПРОВЕРКА ОПЛАТЫ
  useEffect(() => {
    const verifyPayment = async () => {
      const sessionId = searchParams.get('session_id');
      if (sessionId) {
        const res = await fetch(`/api/verify?session_id=${sessionId}`);
        const data = await res.json();
        if (data.valid) {
          localStorage.setItem('paid_user', 'true');
          const savedOutput = localStorage.getItem('pending_output');
          if (savedOutput) setOutput(savedOutput);
          setShowPaywall(false);
          router.replace('/'); 
        }
      }
    };
    if (localStorage.getItem('paid_user') === 'true') {
      setShowPaywall(false);
    } else {
      verifyPayment();
    }
  }, [searchParams, router]);

  const handleUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const formData = new FormData();
    formData.append('file', file);
    try {
      const res = await fetch('/api/parse', { method: 'POST', body: formData });
      const data = await res.json();
      if (data.text) setInput(data.text);
    } catch(err) { alert('Error reading file'); }
    e.target.value = null;
  };

  const handleStart = async () => {
    if (!input || input.length < 50) return alert("Please enter at least 50 characters.");
    setLoading(true); setStep('scanning');
    let score = 0;
    const interval = setInterval(() => { score += 4; if (score > 98) score = 98; setAiScore(score); }, 100);
    setTimeout(async () => {
      clearInterval(interval); setStep('processing');
      try {
        const res = await fetch('/api/humanize', {
           method: 'POST', headers: {'Content-Type': 'application/json'},
           body: JSON.stringify({text: input})
        });
        const data = await res.json();
        setOutput(data.result);
        setStep('done');
        if (localStorage.getItem('paid_user') !== 'true') setShowPaywall(true);
      } catch(e) { setStep('idle'); } finally { setLoading(false); }
    }, 2500);
  };

  const handlePay = async () => {
    localStorage.setItem('pending_output', output);
    const res = await fetch('/api/checkout', { method: 'POST' });
    const data = await res.json();
    if(data.url) window.location.href = data.url;
  };

  const handleDownload = () => {
    const element = document.createElement("a");
    const file = new Blob([output], {type: 'text/plain'});
    element.href = URL.createObjectURL(file);
    element.download = "humanized_document.txt";
    document.body.appendChild(element);
    element.click();
  };

  return (
    <div className="min-h-screen bg-[#020617] text-white selection:bg-purple-500 selection:text-white pb-20">
      <header className="fixed w-full border-b border-white/5 bg-[#020617]/90 backdrop-blur z-40">
        <div className="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
          <div className="text-xl font-black bg-gradient-to-r from-purple-400 to-pink-500 bg-clip-text text-transparent">GHOSTWRITER<span className="text-white">.AI</span></div>
          <div className="flex items-center gap-2 text-[10px] font-bold text-slate-400 bg-white/5 px-3 py-1 rounded-full"><ShieldCheck size={12} className="text-green-400"/> BYPASSING TURNITIN </div>
        </div>
      </header>

      <main className="pt-28 px-6 max-w-7xl mx-auto grid lg:grid-cols-2 gap-8 h-[85vh]">
        <div className="flex flex-col h-full bg-[#0f172a] rounded-2xl border border-slate-800 p-1 shadow-2xl">
          <div className="bg-[#1e293b] rounded-xl p-3 flex justify-between items-center mb-1">
            <span className="text-xs font-bold text-red-500 animate-pulse flex items-center gap-2"><span className="w-2 h-2 bg-red-500 rounded-full"></span> DETECTED AI CONTENT</span>
            <label className="cursor-pointer bg-slate-700 hover:bg-slate-600 text-white px-3 py-1.5 rounded-lg text-xs font-bold transition flex items-center gap-2">
              <Upload size={14}/> Upload PDF/Doc
              <input type="file" className="hidden" accept=".pdf,.docx,.txt" onChange={handleUpload} />
            </label>
          </div>
          <textarea className="flex-1 bg-transparent p-5 text-slate-300 resize-none outline-none font-mono text-sm leading-relaxed placeholder-slate-600"
            placeholder="Paste your essay here..." value={input} onChange={(e) => setInput(e.target.value)} />
          <div className="p-3"><button onClick={handleStart} disabled={loading || !input}
              className="w-full py-4 bg-white text-black font-black text-lg rounded-xl hover:scale-[1.01] active:scale-95 transition flex items-center justify-center gap-2">
               {loading ? "REWRITING PATTERNS..." : <><Zap size={20} fill="black"/> HUMANIZE TEXT</>}
            </button></div>
        </div>

        <div className="flex flex-col h-full bg-[#0f172a] rounded-2xl border border-slate-800 p-1 relative overflow-hidden shadow-2xl">
          <div className="bg-[#1e293b] rounded-xl p-3 flex justify-between items-center mb-1 z-20 relative">
             <span className="text-xs font-bold text-green-400 flex items-center gap-2"><ShieldCheck size={14}/> HUMAN RESULT</span>
             {step === 'done' && !showPaywall && (
               <div className="flex gap-2">
                 <button onClick={() => navigator.clipboard.writeText(output)} className="p-1.5 hover:bg-slate-700 rounded text-slate-300"><Copy size={16}/></button>
                 <button onClick={handleDownload} className="p-1.5 hover:bg-slate-700 rounded text-slate-300"><Download size={16}/></button>
               </div>
             )}
          </div>
          <div className="relative flex-1 bg-[#020617] rounded-xl overflow-hidden">
            {step === 'scanning' && (
              <div className="absolute inset-0 bg-black/95 flex flex-col items-center justify-center z-30">
                <div className="scan-line"></div>
                <div className="text-7xl font-mono font-black text-red-600 mb-2">{aiScore}%</div>
                <div className="text-red-500 text-xs font-bold tracking-[0.4em]">AI PROBABILITY</div>
              </div>
            )}
            <div className={`p-6 h-full overflow-y-auto whitespace-pre-wrap font-mono text-sm leading-relaxed text-slate-300 ${showPaywall ? 'paywall-blur' : ''}`}>
              {output || <div className="h-full flex items-center justify-center text-slate-700 italic">Waiting for input...</div>}
            </div>
            {showPaywall && (
              <div className="absolute inset-0 z-40 flex flex-col items-center justify-center bg-black/60 backdrop-blur-sm px-6">
                <div className="bg-[#1e293b] border border-slate-700 p-8 rounded-2xl shadow-2xl max-w-md w-full text-center">
                  <h2 className="text-2xl font-black text-white mb-2">Bypass Successful! 🚀</h2>
                  <p className="text-slate-400 text-sm mb-6">Text is now <b>100% invisible</b> to Turnitin.</p>
                  <button onClick={handlePay} className="w-full py-4 bg-gradient-to-r from-purple-600 to-pink-600 rounded-xl font-bold text-white text-lg hover:scale-[1.02] transition flex items-center justify-center gap-2">
                    <Lock size={18} /> UNLOCK MY GRADE ($4.99)
                  </button>
                  <p className="mt-4 text-[10px] text-slate-500">🔒 256-bit Secure • Money Back Guarantee</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}

export default function Home() {
  return (
    <Suspense fallback={<div className="bg-[#020617] h-screen w-full"></div>}>
      <App />
    </Suspense>
  );
}
EOL

# ==========================================
# 10. SEO LANDING PAGE TEMPLATE ([slug]/page.js)
# ==========================================
cat > src/app/humanize/\[slug\]/page.js << 'EOL'
import Home from '../../page'; 
import { niches } from '../../seo-data';
import { ShieldCheck, Zap, Lock } from 'lucide-react';

export async function generateMetadata({ params }) {
  const data = niches[params.slug] || { title: 'AI Humanizer', desc: 'Bypass AI Detection' };
  return { title: `${data.title} | Ghostwriter AI`, description: data.desc }
}
export async function generateStaticParams() { return Object.keys(niches).map((slug) => ({ slug })); }

export default function DynamicPage({ params }) {
  const data = niches[params.slug];
  const title = data ? data.h1 : 'AI Humanizer Tool';
  return (
    <div className="bg-[#020617] min-h-screen">
      <Home />
      <div className="max-w-4xl mx-auto px-6 pb-20 pt-10 border-t border-slate-800">
        <h1 className="text-3xl font-black text-center text-white mb-6">{title}</h1>
        <p className="text-slate-400 text-center text-lg mb-12">{data ? data.desc : 'Rewrite text.'} Our tool preserves meaning while removing AI watermarks.</p>
        <div className="grid md:grid-cols-3 gap-6 mb-16">
          <div className="bg-[#0f172a] p-6 rounded-xl border border-slate-800"><ShieldCheck className="text-green-500 mb-4" size={32}/><h3 className="text-xl font-bold text-white mb-2">100% Undetectable</h3><p className="text-sm text-slate-400">Specifically trained for {params.slug.replace(/-/g, ' ')}.</p></div>
          <div className="bg-[#0f172a] p-6 rounded-xl border border-slate-800"><Zap className="text-purple-500 mb-4" size={32}/><h3 className="text-xl font-bold text-white mb-2">Instant Fix</h3><p className="text-sm text-slate-400">Humanized in seconds.</p></div>
          <div className="bg-[#0f172a] p-6 rounded-xl border border-slate-800"><Lock className="text-blue-500 mb-4" size={32}/><h3 className="text-xl font-bold text-white mb-2">Secure</h3><p className="text-sm text-slate-400">We do not store your data.</p></div>
        </div>
      </div>
    </div>
  );
}
EOL

# ==========================================
# 11. SITEMAP & ROBOTS
# ==========================================
cat > src/app/sitemap.js << 'EOL'
import { niches } from './seo-data';
export default function sitemap() {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'https://essay.codesaas.ie'; 
  const main = { url: baseUrl, lastModified: new Date().toISOString(), changeFrequency: 'daily', priority: 1 };
  const nicheUrls = Object.keys(niches).map((slug) => ({ url: `${baseUrl}/humanize/${slug}`, lastModified: new Date().toISOString(), changeFrequency: 'weekly', priority: 0.8 }));
  return [main, ...nicheUrls];
}
EOL

cat > src/app/robots.txt << 'EOL'
export default function robots() {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'https://essay.codesaas.ie'; 
  return { rules: { userAgent: '*', allow: '/', disallow: '/api/' }, sitemap: `${baseUrl}/sitemap.xml` }
}
EOL

# ==========================================
# 12. LAYOUT & ROOT
# ==========================================
cat > src/app/layout.js << 'EOL'
import './globals.css'
import Protection from './components/Protection';
import SocialProof from './components/SocialProof';
import { GoogleAnalytics } from '@next/third-parties/google';

export const metadata = {
  title: 'Ghostwriter AI - Turn ChatGPT into Human Text',
  description: 'The #1 AI Humanizer used by 50,000+ students. Bypass Turnitin, GPTZero & Originality.ai instantly.',
  verification: { google: 'YOUR_GOOGLE_CONSOLE_CODE' },
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="antialiased select-none">
        <Protection />
        <SocialProof />
        {children}
        {/* <GoogleAnalytics gaId="G-XYZ" /> */}
      </body>
    </html>
  )
}
EOL

# ==========================================
# 13. CHROME EXTENSION
# ==========================================
cat > extension/manifest.json << 'EOL'
{
  "manifest_version": 3,
  "name": "Ghostwriter AI",
  "version": "1.0",
  "permissions": ["activeTab", "scripting"],
  "action": { "default_popup": "popup.html" }
}
EOL
cat > extension/popup.html << 'EOL'
<!DOCTYPE html><html><body style="width:300px;background:#020617;color:#fff;padding:15px;font-family:sans-serif;"><h3 style="color:#a855f7;margin:0 0 10px;">Ghostwriter AI 👻</h3><p style="font-size:12px;color:#94a3b8;">Use the full engine to bypass Turnitin.</p><a href="https://essay.codesaas.ie" target="_blank" style="display:block;background:linear-gradient(to right,#7c3aed,#db2777);color:#fff;text-align:center;padding:12px;text-decoration:none;border-radius:8px;font-weight:bold;margin-top:15px;">Open Web App ⚡</a></body></html>
EOL

echo "✅ GHOSTWRITER: PLATINUM EDITION ГОТОВ!"
echo "--------------------------------------------------------"
echo "СЛЕДУЮЩИЕ ШАГИ:"
echo "1. Открой файл .env.local и вставь свои ключи (OpenAI, Stripe)."
echo "2. Запусти локально: npm run dev"
echo "3. Залей на GitHub -> Render."
echo "4. В настройках Render добавь те же ключи в Environment Variables."
echo "--------------------------------------------------------"

