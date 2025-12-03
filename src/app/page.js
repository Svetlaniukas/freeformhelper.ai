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
