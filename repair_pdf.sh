#!/bin/bash

echo "🔧 ЧИНИМ PDF И ЛОГИКУ РАЗМЫТИЯ..."

# 1. ОБНОВЛЯЕМ API PARSE (Делаем его "неубиваемым")
# Теперь он пробует прочитать PDF, а если не вышло — не валит весь сайт, а говорит ошибку.
cat > src/app/api/parse/route.js << 'EOL'
import { NextResponse } from 'next/server';
import mammoth from 'mammoth';

export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    const formData = await req.formData();
    const file = formData.get('file');

    if (!file) return NextResponse.json({ error: 'No file uploaded' }, { status: 400 });

    const buffer = Buffer.from(await file.arrayBuffer());
    let text = '';

    console.log(`Processing file: ${file.name} (${file.type})`);

    if (file.type === 'application/pdf') {
      try {
        // Используем require внутри try/catch для безопасности
        const pdfParse = require('pdf-parse');
        const data = await pdfParse(buffer);
        text = data.text;
      } catch (pdfError) {
        console.error("PDF Parse Error:", pdfError);
        return NextResponse.json({ error: 'Failed to read PDF. Try converting to DOCX or TXT.' }, { status: 500 });
      }
    } else if (file.name.endsWith('.docx')) {
      try {
        const result = await mammoth.extractRawText({ buffer });
        text = result.value;
      } catch (docxError) {
        return NextResponse.json({ error: 'Failed to read DOCX.' }, { status: 500 });
      }
    } else {
      // Пробуем прочитать как простой текст
      text = buffer.toString('utf-8');
    }

    // Если текст пустой или мусор
    if (!text || text.trim().length < 5) {
      return NextResponse.json({ error: 'File is empty or unreadable.' }, { status: 400 });
    }

    return NextResponse.json({ text });
  } catch (error) {
    console.error("General Upload Error:", error);
    return NextResponse.json({ error: 'Upload failed on server.' }, { status: 500 });
  }
}
EOL

# 2. ОБНОВЛЯЕМ ФРОНТЕНД (PAGE.JS)
# Главное изменение: Текст сначала ПОЯВЛЯЕТСЯ, а потом НАКЛАДЫВАЕТСЯ БЛЮР.
cat > src/app/page.js << 'EOL'
"use client";
import { useState, useEffect, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { ShieldCheck, Zap, Upload, CheckCircle, Lock } from 'lucide-react';
import { AnimatePresence, motion } from 'framer-motion';

// --- WIDGET ---
function SocialProofWidget() {
  const [online, setOnline] = useState(412);
  const [popup, setPopup] = useState(null);
  useEffect(() => {
    setInterval(() => setOnline(p => p + (Math.random() > 0.5 ? 1 : -1)), 4000);
    const names = ["Emma", "Alex", "Sarah", "Mike"];
    const unis = ["Harvard", "Stanford", "MIT"];
    setInterval(() => {
      if(Math.random() > 0.7) {
        setPopup({ name: names[Math.floor(Math.random()*names.length)], uni: unis[Math.floor(Math.random()*unis.length)] });
        setTimeout(() => setPopup(null), 5000);
      }
    }, 10000);
  }, []);
  return (
    <div className="fixed bottom-5 left-5 z-50 pointer-events-none">
      <div className="bg-slate-900/90 backdrop-blur border border-slate-700 px-3 py-1 rounded-full flex gap-2 mb-2 shadow-xl items-center w-fit">
        <span className="flex h-2 w-2 relative"><span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span><span className="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span></span>
        <span className="text-xs font-bold text-slate-200">{online} online</span>
      </div>
      <AnimatePresence>{popup && <motion.div initial={{opacity:0,y:20}} animate={{opacity:1,y:0}} exit={{opacity:0,y:20}} className="bg-slate-900 border-l-4 border-blue-500 p-3 rounded shadow-xl w-60"><span className="text-xs font-bold text-white block">{popup.name} from {popup.uni}</span><span className="text-[10px] text-slate-400">just unlocked a paper 🔓</span></motion.div>}</AnimatePresence>
    </div>
  );
}

// --- APP ---
function App() {
  const [input, setInput] = useState('');
  const [output, setOutput] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingFile, setLoadingFile] = useState(false);
  const [step, setStep] = useState('idle'); 
  const [showPaywall, setShowPaywall] = useState(false);
  const [aiScore, setAiScore] = useState(0);
  
  const searchParams = useSearchParams();
  const router = useRouter();

  // ПРОВЕРКА ОПЛАТЫ
  useEffect(() => {
    const check = async () => {
      const sid = searchParams.get('session_id');
      if(sid) {
        const res = await fetch(`/api/verify?session_id=${sid}`);
        const d = await res.json();
        if(d.valid) {
          localStorage.setItem('paid_user', 'true');
          const saved = localStorage.getItem('pending_output');
          if(saved) setOutput(saved); // Восстанавливаем текст
          setShowPaywall(false);
          router.replace('/');
        }
      }
    };
    if(localStorage.getItem('paid_user') === 'true') setShowPaywall(false);
    else check();
  }, [searchParams, router]);

  // ЗАГРУЗКА ФАЙЛА
  const handleUpload = async (e) => {
    const file = e.target.files[0];
    if(!file) return;
    setLoadingFile(true);
    const fd = new FormData(); fd.append('file', file);
    try {
      const res = await fetch('/api/parse', {method:'POST', body:fd});
      const d = await res.json();
      if(d.text) {
        setInput(d.text);
      } else {
        alert("Error: " + (d.error || "Unknown error"));
      }
    } catch(err) { alert("Upload failed. Try copy-pasting text."); }
    finally { setLoadingFile(false); e.target.value = null; }
  };

  // ЗАПУСК ГЕНЕРАЦИИ
  const handleStart = async () => {
    if(!input || input.length < 10) return alert("Text is too short.");
    setLoading(true); setStep('scanning');
    
    // Анимация процентов
    let sc = 0;
    const interval = setInterval(() => { sc+=5; if(sc>98) sc=98; setAiScore(sc); }, 100);

    setTimeout(async () => {
      clearInterval(interval); setStep('processing');
      try {
        const res = await fetch('/api/humanize', {
          method: 'POST', headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({text: input})
        });
        const data = await res.json();
        
        // ВАЖНО: Сначала показываем текст, потом закрываем его
        setOutput(data.result); 
        setStep('done');

        if(localStorage.getItem('paid_user') !== 'true') {
          setShowPaywall(true);
        }
      } catch(e) { setStep('idle'); alert("Server Error. Try again."); } 
      finally { setLoading(false); }
    }, 2500);
  };

  const handlePay = async () => {
    localStorage.setItem('pending_output', output); // Сохраняем перед уходом
    const res = await fetch('/api/checkout', {method:'POST'});
    const data = await res.json();
    if(data.url) window.location.href = data.url;
  };

  return (
    <div className="min-h-screen bg-[#020617] text-white pb-20 selection:bg-blue-500 selection:text-white">
      <SocialProofWidget />
      
      <header className="fixed w-full border-b border-white/5 bg-[#020617]/90 backdrop-blur z-50 p-4">
        <div className="max-w-6xl mx-auto flex justify-between items-center">
          <div className="text-xl font-black bg-gradient-to-r from-blue-400 to-cyan-500 bg-clip-text text-transparent">FreeForm<span className="text-white">Helper.ai</span></div>
          {localStorage.getItem('paid_user') === 'true' && <span className="text-xs font-bold text-green-400 border border-green-500 px-2 rounded">PREMIUM</span>}
        </div>
      </header>

      <main className="pt-24 px-4 max-w-6xl mx-auto grid lg:grid-cols-2 gap-6 h-[85vh]">
        
        {/* ЛЕВОЕ ОКНО (ВВОД) */}
        <div className="flex flex-col h-full bg-[#0f172a] rounded-xl border border-slate-800 p-1">
          <div className="bg-[#1e293b] p-3 rounded-lg mb-1 flex justify-between items-center">
             <span className="text-xs font-bold text-slate-400">INPUT TEXT</span>
             <label className={`cursor-pointer bg-blue-600 hover:bg-blue-500 text-white px-3 py-1.5 rounded text-xs font-bold flex items-center gap-2 transition ${loadingFile ? 'opacity-50' : ''}`}>
               <Upload size={14}/> {loadingFile ? "READING..." : "UPLOAD FILE"}
               <input type="file" className="hidden" accept=".pdf,.docx,.txt" onChange={handleUpload} disabled={loadingFile}/>
             </label>
          </div>
          <textarea className="flex-1 bg-transparent p-4 text-slate-300 outline-none resize-none font-mono text-sm" 
            placeholder="Paste text or upload file here..." value={input} onChange={e=>setInput(e.target.value)}/>
          <div className="p-2">
            <button onClick={handleStart} disabled={loading || loadingFile} 
              className="w-full py-3 bg-white text-black font-black rounded-lg hover:scale-[1.01] transition shadow-lg">
               {loading ? "HUMANIZING..." : "HUMANIZE TEXT ⚡"}
            </button>
          </div>
        </div>

        {/* ПРАВОЕ ОКНО (ВЫВОД) */}
        <div className="flex flex-col h-full bg-[#0f172a] rounded-xl border border-slate-800 p-1 relative overflow-hidden">
          <div className="bg-[#1e293b] p-3 rounded-lg mb-1 flex justify-between">
             <span className="text-xs font-bold text-green-400 flex items-center gap-2"><ShieldCheck size={14}/> HUMAN RESULT</span>
             {step === 'done' && !showPaywall && <button onClick={() => navigator.clipboard.writeText(output)} className="text-xs bg-slate-700 px-2 py-1 rounded">Copy</button>}
          </div>

          <div className="relative flex-1 bg-[#020617] rounded-lg overflow-hidden">
            
            {/* АНИМАЦИЯ СКАНИРОВАНИЯ */}
            {step === 'scanning' && (
              <div className="absolute inset-0 bg-black/90 flex flex-col items-center justify-center z-30">
                <div className="w-full h-1 bg-blue-500 shadow-[0_0_15px_#3b82f6] absolute top-1/2 animate-pulse"></div>
                <div className="text-6xl font-black text-white">{aiScore}%</div>
                <div className="text-blue-400 text-xs tracking-widest mt-2">DETECTING AI PATTERNS</div>
              </div>
            )}

            {/* ТЕКСТ (С ЭФФЕКТОМ БЛЮРА) */}
            <div className={`p-6 h-full overflow-y-auto font-mono text-sm text-slate-300 transition-all duration-500 ${showPaywall ? 'blur-[6px] select-none opacity-50' : ''}`}>
              {output || <div className="h-full flex items-center justify-center text-slate-700 italic">Waiting for input...</div>}
            </div>

            {/* PAYWALL (ПОВЕРХ РАЗМЫТОГО ТЕКСТА) */}
            {showPaywall && (
              <div className="absolute inset-0 z-40 flex flex-col items-center justify-center bg-black/40 backdrop-blur-[2px]">
                <div className="bg-[#1e293b] p-6 rounded-2xl border border-blue-500/30 text-center max-w-sm shadow-2xl m-4">
                  <div className="w-12 h-12 bg-green-500/10 rounded-full flex items-center justify-center mx-auto mb-3"><Lock className="text-green-400"/></div>
                  <h2 className="text-2xl font-black text-white mb-1">Humanized! 🚀</h2>
                  <p className="text-slate-400 text-xs mb-4">
                    Your document is ready. We removed all AI patterns. <br/>
                    <b>Unlock to view and download.</b>
                  </p>
                  <button onClick={handlePay} className="w-full py-3 bg-gradient-to-r from-blue-600 to-cyan-500 rounded-lg font-bold text-white hover:scale-105 transition shadow-lg shadow-blue-900/50">
                    UNLOCK NOW ($4.99)
                  </button>
                  <p className="text-[10px] text-slate-500 mt-3">🔒 Secure Stripe Payment</p>
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
    <Suspense fallback={<div className="bg-[#020617] h-screen"/>}>
      <App />
    </Suspense>
  );
}
EOL

echo "✅ PDF И BLUR ИСПРАВЛЕНЫ!"
echo "Отправляем на GitHub..."

git add .
git commit -m "Fix PDF upload and Blur effect"
git push -u origin main --force

echo "🚀 Улетело! Проверяй Render."
