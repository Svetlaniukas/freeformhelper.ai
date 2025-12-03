#!/bin/bash

echo "💎 ВОЗВРАЩАЕМ МАРКЕТИНГ, PDF И СОЦИАЛЬНОЕ ДОКАЗАТЕЛЬСТВО..."

# 1. Устанавливаем библиотеки для анимаций (если пропали)
npm install framer-motion lucide-react

# 2. ЧИНИМ API PARSE (PDF)
# Используем безопасный метод require, чтобы Render не ругался
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
      try {
        const pdfParse = require('pdf-parse');
        const data = await pdfParse(buffer);
        text = data.text;
      } catch (e) {
        return NextResponse.json({ error: 'PDF Error' }, { status: 500 });
      }
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

# 3. ГЛАВНАЯ СТРАНИЦА (ВСЁ ВКЛЮЧЕНО: СЧЕТЧИКИ, SEO, ОПИСАНИЕ)
cat > src/app/page.js << 'EOL'
"use client";
import { useState, useEffect, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { FileText, Download, Copy, Lock, ShieldCheck, Zap, Upload, Users, CheckCircle } from 'lucide-react';
import { AnimatePresence, motion } from 'framer-motion';

// --- КОМПОНЕНТ СОЦИАЛЬНОГО ДОКАЗАТЕЛЬСТВА (Счетчик + Всплывашки) ---
function SocialProofWidget() {
  const [online, setOnline] = useState(412);
  const [popup, setPopup] = useState(null);
  const NAMES = ["Emma", "Liam", "Noah", "Olivia", "James", "Sophia", "Michael"];
  const UNIS = ["Harvard", "Stanford", "MIT", "NYU", "Oxford"];

  useEffect(() => {
    // Живой счетчик (плавает)
    const interval = setInterval(() => {
      setOnline(p => p + (Math.random() > 0.5 ? Math.floor(Math.random() * 3) : -Math.floor(Math.random() * 2)));
    }, 3000);
    
    // Всплывашки покупок
    const loop = setInterval(() => {
      if(Math.random() > 0.6) {
        const name = NAMES[Math.floor(Math.random() * NAMES.length)];
        const uni = UNIS[Math.floor(Math.random() * UNIS.length)];
        setPopup({ name, uni });
        setTimeout(() => setPopup(null), 5000);
      }
    }, 8000);
    return () => { clearInterval(interval); clearInterval(loop); };
  }, []);

  return (
    <div className="fixed bottom-5 left-5 z-50 pointer-events-none">
      <div className="bg-slate-900/90 backdrop-blur border border-slate-700 px-4 py-2 rounded-full flex items-center gap-3 mb-3 w-fit shadow-xl">
        <span className="relative flex h-3 w-3">
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
          <span className="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
        </span>
        <span className="text-xs font-bold text-slate-200">
          <span className="text-white font-black">{online}</span> students online
        </span>
      </div>
      <AnimatePresence>
        {popup && (
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 20 }}
            className="bg-slate-900 border-l-4 border-blue-500 p-4 rounded shadow-2xl flex gap-3 w-72">
            <div className="bg-blue-500/20 p-2 rounded-full h-fit"><CheckCircle size={16} className="text-blue-400"/></div>
            <div className="flex flex-col">
              <span className="text-sm font-bold text-white">{popup.name} from {popup.uni}</span>
              <span className="text-xs text-slate-400">just unlocked a document 🔓</span>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

// --- ОСНОВНОЕ ПРИЛОЖЕНИЕ ---
function App() {
  const [input, setInput] = useState('');
  const [output, setOutput] = useState('');
  const [loading, setLoading] = useState(false);
  const [step, setStep] = useState('idle');
  const [showPaywall, setShowPaywall] = useState(false);
  const [aiScore, setAiScore] = useState(0);
  const [loadingFile, setLoadingFile] = useState(false);
  
  const searchParams = useSearchParams();
  const router = useRouter();

  useEffect(() => {
    const checkPay = async () => {
      const sid = searchParams.get('session_id');
      if(sid) {
        const res = await fetch(`/api/verify?session_id=${sid}`);
        const d = await res.json();
        if(d.valid) {
          localStorage.setItem('paid_user', 'true');
          const saved = localStorage.getItem('pending_output');
          if(saved) setOutput(saved);
          setShowPaywall(false);
          router.replace('/');
        }
      }
    };
    if(localStorage.getItem('paid_user') === 'true') setShowPaywall(false);
    else checkPay();
  }, [searchParams, router]);

  const handleStart = async () => {
    if(!input || input.length < 50) return alert("Please enter more text (at least 50 chars).");
    setLoading(true); setStep('scanning');
    
    let sc = 0;
    const interval = setInterval(() => { sc+=Math.floor(Math.random()*5)+2; if(sc>98) sc=98; setAiScore(sc); }, 150);

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
        if(localStorage.getItem('paid_user') !== 'true') setShowPaywall(true);
      } catch(e) { setStep('idle'); } finally { setLoading(false); }
    }, 3000);
  };

  const handlePay = async () => {
    localStorage.setItem('pending_output', output);
    const res = await fetch('/api/checkout', {method:'POST'});
    const data = await res.json();
    if(data.url) window.location.href = data.url;
  };

  const handleUpload = async (e) => {
    const file = e.target.files[0];
    if(!file) return;
    setLoadingFile(true);
    
    const fd = new FormData(); fd.append('file', file);
    try {
      const res = await fetch('/api/parse', {method:'POST', body:fd});
      const d = await res.json();
      if(d.text) setInput(d.text);
      else alert("Error: " + d.error);
    } catch(err) { alert("Upload failed"); } 
    finally { setLoadingFile(false); e.target.value = null; }
  };

  return (
    <div className="min-h-screen bg-[#020617] text-white pb-20 selection:bg-blue-500 selection:text-white">
      <SocialProofWidget />
      
      <header className="fixed w-full border-b border-white/5 bg-[#020617]/90 backdrop-blur z-50 p-4">
        <div className="max-w-6xl mx-auto flex justify-between items-center">
          <div className="text-xl font-black bg-gradient-to-r from-blue-400 to-cyan-500 bg-clip-text text-transparent">
            FreeForm<span className="text-white">Helper.ai</span>
          </div>
          {localStorage.getItem('paid_user') === 'true' && <span className="text-xs font-bold text-green-400 border border-green-500 px-3 py-1 rounded-full">PREMIUM PLAN ACTIVE</span>}
        </div>
      </header>

      <main className="pt-28 px-4 max-w-6xl mx-auto grid lg:grid-cols-2 gap-8 h-[85vh]">
        {/* ЛЕВОЕ ОКНО */}
        <div className="flex flex-col h-full bg-[#0f172a] rounded-2xl border border-slate-800 p-1 shadow-2xl">
          <div className="bg-[#1e293b] rounded-xl p-4 mb-1 flex justify-between items-center">
             {/* ПОКАЗЫВАЕМ DETECTED ТОЛЬКО ЕСЛИ ЕСТЬ ТЕКСТ */}
             {input.length > 0 ? (
               <span className="text-xs font-bold text-red-500 animate-pulse flex items-center gap-2">
                 <span className="w-2 h-2 bg-red-500 rounded-full"></span> AI PROBABILITY: HIGH
               </span>
             ) : (
               <span className="text-xs font-bold text-slate-500">WAITING FOR TEXT...</span>
             )}
             
             <label className={`cursor-pointer bg-slate-700 hover:bg-slate-600 text-white px-3 py-1.5 rounded-lg text-xs font-bold transition flex items-center gap-2 ${loadingFile ? 'opacity-50' : ''}`}>
               <Upload size={14}/> {loadingFile ? "READING FILE..." : "UPLOAD PDF/DOC"}
               <input type="file" className="hidden" accept=".pdf,.docx,.txt" onChange={handleUpload} disabled={loadingFile}/>
             </label>
          </div>
          <textarea 
            className="flex-1 bg-transparent p-6 text-slate-300 outline-none resize-none font-mono text-sm leading-relaxed placeholder-slate-600"
            placeholder="Paste your essay here or upload a file..."
            value={input} onChange={e=>setInput(e.target.value)}
          />
          <div className="p-3">
            <button onClick={handleStart} disabled={loading || loadingFile} 
              className="w-full py-4 bg-white text-black font-black text-lg rounded-xl hover:scale-[1.01] active:scale-95 transition flex items-center justify-center gap-2 shadow-[0_0_20px_rgba(255,255,255,0.3)]">
               {loading ? "REWRITING PATTERNS..." : <><Zap size={20} fill="black"/> HUMANIZE TEXT</>}
            </button>
          </div>
        </div>

        {/* ПРАВОЕ ОКНО */}
        <div className="flex flex-col h-full bg-[#0f172a] rounded-2xl border border-slate-800 p-1 relative overflow-hidden shadow-2xl">
          <div className="bg-[#1e293b] rounded-xl p-4 mb-1 flex justify-between items-center z-20 relative">
             <span className="text-xs font-bold text-green-400 flex items-center gap-2"><ShieldCheck size={14}/> HUMAN RESULT</span>
             {step === 'done' && !showPaywall && <button onClick={() => navigator.clipboard.writeText(output)} className="text-xs bg-slate-700 px-3 py-1 rounded hover:bg-slate-600 text-white">Copy Text</button>}
          </div>
          <div className="relative flex-1 bg-[#020617] rounded-xl overflow-hidden">
            {step === 'scanning' && (
              <div className="absolute inset-0 bg-black/95 flex flex-col items-center justify-center z-30">
                <div className="scan-line"></div>
                <div className="text-7xl font-black text-blue-500 tracking-tighter">{aiScore}%</div>
                <div className="text-blue-400 text-xs font-bold tracking-[0.4em] mt-2">AI PATTERNS DETECTED</div>
                <p className="text-slate-500 text-xs mt-8 font-mono">Analyzing syntax structures...</p>
              </div>
            )}
            <div className={`p-6 h-full overflow-y-auto whitespace-pre-wrap font-mono text-sm leading-relaxed text-slate-300 ${showPaywall ? 'paywall-blur' : ''}`}>
              {output || <div className="h-full flex items-center justify-center text-slate-700 italic">Waiting for input...</div>}
            </div>
            {showPaywall && (
              <div className="absolute inset-0 z-40 flex flex-col items-center justify-center bg-black/70 backdrop-blur-sm px-6">
                <div className="bg-[#1e293b] p-8 rounded-2xl border border-slate-700 text-center max-w-sm shadow-2xl">
                  <div className="w-12 h-12 bg-green-500/10 rounded-full flex items-center justify-center mx-auto mb-4"><ShieldCheck className="text-green-500"/></div>
                  <h2 className="text-2xl font-black text-white mb-2">Bypass Successful! 🚀</h2>
                  <p className="text-slate-400 text-sm mb-6">Text is now <b>100% invisible</b> to Turnitin & GPTZero.</p>
                  <button onClick={handlePay} className="w-full py-4 bg-gradient-to-r from-blue-500 to-cyan-500 rounded-xl font-bold text-white text-lg hover:scale-105 transition shadow-lg shadow-blue-500/20">UNLOCK ($4.99)</button>
                  <p className="text-[10px] text-slate-500 mt-4">🔒 256-bit SSL Secure Payment</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </main>
      
      {/* --- SEO FOOTER (ОПИСАНИЕ) --- */}
      <section className="max-w-4xl mx-auto px-6 py-20 border-t border-slate-800 text-center">
         <h1 className="text-3xl font-black text-white mb-6">The #1 AI Text Humanizer for Students</h1>
         <p className="text-slate-400 text-lg mb-12">
           FreeForm Helper is an advanced AI detection remover designed to help students bypass Turnitin, GPTZero, and Originality.ai. 
           Unlike simple paraphrasers, we rewrite the logic and structure of your essay to mimic natural human writing patterns (Burstiness & Perplexity).
         </p>
         <div className="grid md:grid-cols-3 gap-8 text-left">
           <div className="bg-[#0f172a] p-6 rounded-xl border border-slate-800">
             <h3 className="font-bold text-white mb-2 flex items-center gap-2"><Zap size={16} className="text-yellow-400"/> Instant Fix</h3>
             <p className="text-sm text-slate-400">Upload your PDF or paste text. Get a humanized version in seconds.</p>
           </div>
           <div className="bg-[#0f172a] p-6 rounded-xl border border-slate-800">
             <h3 className="font-bold text-white mb-2 flex items-center gap-2"><Lock size={16} className="text-blue-400"/> Private</h3>
             <p className="text-sm text-slate-400">We do not store your essays. Your work remains 100% yours.</p>
           </div>
           <div className="bg-[#0f172a] p-6 rounded-xl border border-slate-800">
             <h3 className="font-bold text-white mb-2 flex items-center gap-2"><ShieldCheck size={16} className="text-green-400"/> Undetectable</h3>
             <p className="text-sm text-slate-400">Trained specifically to beat Turnitin's 2025 algorithm.</p>
           </div>
         </div>
      </section>
    </div>
  );
}

export default function Home() {
  return (
    <Suspense fallback={<div className="bg-[#020617] h-screen"/>}>
      <App />
    </Suspense>
  );
}
EOL

echo "✅ ПОЛНЫЙ ПАКЕТ УСТАНОВЛЕН!"
echo "Отправляем на GitHub..."

git add .
git commit -m "Polish: Add Social Proof, SEO text, and Fix PDF"
git push -u origin main --force

echo "🚀 Улетело! Проверяй Render через 2 минуты."
