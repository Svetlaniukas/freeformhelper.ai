"use client";
import { useState, useEffect, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { ShieldCheck, Zap, Upload, Lock, FileText, Check, ArrowRight, Sparkles } from 'lucide-react';
import { motion } from 'framer-motion';

/* ─── PLANS ─── */
const PLANS = [
  {
    id: 'free', name: 'Free', price: '€0', period: '',
    desc: '300 words per request',
    features: ['1 humanization/day', '300 word limit', 'Text input only'],
    cta: 'Current Plan', disabled: true,
  },
  {
    id: 'pro', name: 'Pro', price: '€9.99', period: '/mo',
    desc: '20,000 words per month',
    features: ['Unlimited requests', '20,000 words/month', 'PDF & DOCX upload', 'Priority processing', 'All languages'],
    cta: 'Upgrade to Pro', popular: true,
  },
  {
    id: 'premium', name: 'Premium', price: '€24.99', period: '/mo',
    desc: 'Unlimited everything',
    features: ['Everything in Pro', 'Unlimited words', 'Chrome Extension', 'API access', 'Priority support'],
    cta: 'Go Premium',
  },
];

/* ─── MAIN APP ─── */
function App() {
  const [input, setInput] = useState('');
  const [output, setOutput] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingFile, setLoadingFile] = useState(false);
  const [scanning, setScanning] = useState(false);
  const [scanProgress, setScanProgress] = useState(0);
  const [scanLabel, setScanLabel] = useState('');
  const [showPaywall, setShowPaywall] = useState(false);
  const [userPlan, setUserPlan] = useState('free');
  const [showPricing, setShowPricing] = useState(false);
  const [wordsUsedToday, setWordsUsedToday] = useState(0);

  const searchParams = useSearchParams();
  const router = useRouter();
  const wordCount = input.trim().split(/\s+/).filter(Boolean).length;

  // Check payment on return from Stripe
  useEffect(() => {
    const check = async () => {
      const sid = searchParams.get('session_id');
      const plan = searchParams.get('plan');
      if (sid) {
        const res = await fetch(`/api/verify?session_id=${sid}`);
        const d = await res.json();
        if (d.valid) {
          localStorage.setItem('ffh_plan', plan || 'pro');
          localStorage.setItem('ffh_session', sid);
          setUserPlan(plan || 'pro');
          setShowPaywall(false);
          router.replace('/');
        }
      }
    };
    const saved = localStorage.getItem('ffh_plan');
    if (saved && saved !== 'free') setUserPlan(saved);
    check();
  }, [searchParams, router]);

  // Track daily usage
  useEffect(() => {
    const today = new Date().toISOString().slice(0, 10);
    const usage = JSON.parse(localStorage.getItem('ffh_usage') || '{}');
    if (usage.date === today) setWordsUsedToday(usage.words || 0);
    else localStorage.setItem('ffh_usage', JSON.stringify({ date: today, words: 0 }));
  }, []);

  const handleUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setLoadingFile(true);
    const fd = new FormData();
    fd.append('file', file);
    try {
      const res = await fetch('/api/parse', { method: 'POST', body: fd });
      const d = await res.json();
      if (d.text) setInput(d.text);
      else alert(d.error || 'Could not read file');
    } catch { alert('Upload failed'); }
    finally { setLoadingFile(false); e.target.value = null; }
  };

  const handleHumanize = async () => {
    if (wordCount < 30) return alert(`Too short (${wordCount} words). Minimum 30 words.`);

    // Free plan: check daily limit
    if (userPlan === 'free') {
      if (wordsUsedToday > 0) {
        setShowPaywall(true);
        return;
      }
      if (wordCount > 300) {
        setShowPaywall(true);
        return;
      }
    }

    setLoading(true);
    setScanning(true);
    setScanProgress(0);

    // Scanning animation
    const steps = [
      'Analyzing writing patterns...',
      'Detecting AI signatures...',
      'Measuring perplexity & burstiness...',
      'Rewriting for human authenticity...',
    ];
    let progress = 0;
    const interval = setInterval(() => {
      progress += Math.random() * 5 + 2;
      if (progress > 95) progress = 95;
      setScanProgress(Math.floor(progress));
      setScanLabel(steps[Math.min(Math.floor(progress / 25), 3)]);
    }, 150);

    // Wait for animation then call API
    await new Promise(r => setTimeout(r, 2500));
    clearInterval(interval);
    setScanProgress(100);
    setScanLabel('Finalizing...');

    try {
      const res = await fetch('/api/humanize', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: input, plan: userPlan }),
      });
      const data = await res.json();

      if (data.error === 'word_limit') {
        setShowPaywall(true);
      } else if (data.result) {
        setOutput(data.result);
        // Track usage
        const today = new Date().toISOString().slice(0, 10);
        const newWords = wordsUsedToday + wordCount;
        setWordsUsedToday(newWords);
        localStorage.setItem('ffh_usage', JSON.stringify({ date: today, words: newWords }));
      } else {
        alert('Error processing text');
      }
    } catch { alert('Server error. Please try again.'); }
    finally { setLoading(false); setScanning(false); }
  };

  const handleCheckout = async (plan) => {
    const res = await fetch('/api/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ plan }),
    });
    const data = await res.json();
    if (data.url) window.location.href = data.url;
  };

  return (
    <div className="min-h-screen bg-[#020617] text-white selection:bg-blue-500/30">
      {/* NAV */}
      <nav className="fixed w-full border-b border-white/5 bg-[#020617]/95 backdrop-blur-xl z-50 px-4 py-3">
        <div className="max-w-5xl mx-auto flex justify-between items-center">
          <div className="text-lg font-black">
            <span className="bg-gradient-to-r from-blue-400 to-cyan-400 bg-clip-text text-transparent">FreeForm</span>
            <span className="text-white/90">Helper</span>
            <span className="text-blue-400">.ai</span>
          </div>
          <div className="flex items-center gap-3">
            {userPlan !== 'free' && (
              <span className="text-[10px] font-bold text-emerald-400 border border-emerald-500/30 bg-emerald-500/10 px-2 py-0.5 rounded-full uppercase">
                {userPlan}
              </span>
            )}
            <button
              onClick={() => setShowPricing(true)}
              className="text-xs font-medium text-slate-400 hover:text-white transition"
            >
              Pricing
            </button>
          </div>
        </div>
      </nav>

      {/* HERO */}
      <div className="pt-20 pb-6 px-4 text-center">
        <h1 className="text-2xl sm:text-3xl font-black tracking-tight mb-2">
          Make AI Text <span className="bg-gradient-to-r from-blue-400 to-cyan-400 bg-clip-text text-transparent">Undetectable</span>
        </h1>
        <p className="text-sm text-slate-500 max-w-md mx-auto">
          Bypass Turnitin, GPTZero & Originality.AI. Instant results.
        </p>
      </div>

      {/* WORKSPACE */}
      <main className="px-4 max-w-5xl mx-auto grid lg:grid-cols-2 gap-4" style={{ minHeight: '65vh' }}>
        {/* INPUT */}
        <div className="flex flex-col bg-slate-900/50 rounded-xl border border-slate-800 overflow-hidden">
          <div className="flex items-center justify-between px-4 py-2.5 border-b border-slate-800">
            <span className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider">Input</span>
            <div className="flex items-center gap-2">
              <span className="text-[11px] text-slate-600 tabular-nums">{wordCount} words</span>
              <label className="cursor-pointer bg-slate-800 hover:bg-slate-700 text-slate-300 px-2.5 py-1 rounded-lg text-[11px] font-medium flex items-center gap-1.5 transition">
                <Upload size={12} /> Upload
                <input type="file" className="hidden" accept=".pdf,.docx,.txt" onChange={handleUpload} disabled={loadingFile} />
              </label>
            </div>
          </div>
          <textarea
            className="flex-1 bg-transparent p-4 text-slate-300 outline-none resize-none text-sm leading-relaxed placeholder:text-slate-700"
            placeholder="Paste your AI-generated text here (min 30 words)..."
            value={input}
            onChange={e => setInput(e.target.value)}
          />
          <div className="p-3 border-t border-slate-800">
            <button
              onClick={handleHumanize}
              disabled={loading || wordCount < 30}
              className="w-full py-2.5 bg-white text-slate-900 font-bold text-sm rounded-lg hover:bg-slate-100 transition disabled:opacity-30 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {loading ? (
                <><Sparkles size={14} className="animate-pulse" /> Processing...</>
              ) : (
                <><Zap size={14} /> Humanize Text</>
              )}
            </button>
          </div>
        </div>

        {/* OUTPUT */}
        <div className="flex flex-col bg-slate-900/50 rounded-xl border border-slate-800 overflow-hidden relative">
          <div className="flex items-center justify-between px-4 py-2.5 border-b border-slate-800">
            <span className="text-[11px] font-semibold text-emerald-500 uppercase tracking-wider flex items-center gap-1.5">
              <ShieldCheck size={12} /> Result
            </span>
            {output && !showPaywall && (
              <button
                onClick={() => { navigator.clipboard.writeText(output); }}
                className="text-[11px] bg-slate-800 hover:bg-slate-700 text-slate-300 px-2.5 py-1 rounded-lg font-medium transition"
              >
                Copy
              </button>
            )}
          </div>

          <div className="relative flex-1">
            {/* Scanning overlay */}
            {scanning && (
              <div className="absolute inset-0 bg-slate-950/95 flex flex-col items-center justify-center z-30 p-6">
                <div className="w-full max-w-xs">
                  <div className="text-4xl font-black text-white text-center tabular-nums mb-2">{scanProgress}%</div>
                  <div className="h-1 bg-slate-800 rounded-full overflow-hidden mb-3">
                    <motion.div
                      className="h-full bg-blue-500 rounded-full"
                      animate={{ width: `${scanProgress}%` }}
                      transition={{ duration: 0.3 }}
                    />
                  </div>
                  <p className="text-[11px] text-blue-400 text-center font-medium tracking-wide">{scanLabel}</p>
                </div>
              </div>
            )}

            {/* Output text */}
            <div className={`p-4 h-full overflow-y-auto text-sm leading-relaxed text-slate-300 transition-all ${showPaywall ? 'blur-md select-none' : ''}`}>
              {output || <span className="text-slate-700 italic">Humanized text will appear here...</span>}
            </div>

            {/* Paywall */}
            {showPaywall && (
              <div className="absolute inset-0 z-40 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
                <div className="bg-slate-900 border border-slate-700 rounded-2xl p-6 max-w-sm w-full text-center">
                  <div className="w-10 h-10 bg-blue-500/10 rounded-full flex items-center justify-center mx-auto mb-3">
                    <Lock className="text-blue-400" size={18} />
                  </div>
                  <h3 className="text-lg font-bold text-white mb-1">Upgrade to Continue</h3>
                  <p className="text-xs text-slate-400 mb-5">
                    {userPlan === 'free' ? 'Free plan: 1 request per day, 300 words max.' : 'You\'ve reached your plan limit.'}
                  </p>
                  <button
                    onClick={() => handleCheckout('pro')}
                    className="w-full py-2.5 bg-blue-600 hover:bg-blue-500 text-white rounded-lg font-semibold text-sm transition mb-2"
                  >
                    Upgrade to Pro — €9.99/mo
                  </button>
                  <button
                    onClick={() => setShowPaywall(false)}
                    className="text-xs text-slate-500 hover:text-slate-300 transition"
                  >
                    Maybe later
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </main>

      {/* TRUST BAR */}
      <div className="flex items-center justify-center gap-6 py-8 text-[11px] text-slate-600">
        <span className="flex items-center gap-1"><ShieldCheck size={12} className="text-emerald-500" /> Bypasses Turnitin</span>
        <span className="flex items-center gap-1"><ShieldCheck size={12} className="text-emerald-500" /> Bypasses GPTZero</span>
        <span className="flex items-center gap-1"><ShieldCheck size={12} className="text-emerald-500" /> Bypasses Originality.AI</span>
      </div>

      {/* PRICING MODAL */}
      {showPricing && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setShowPricing(false)}>
          <div className="bg-slate-900 border border-slate-700 rounded-2xl p-6 max-w-3xl w-full" onClick={e => e.stopPropagation()}>
            <h2 className="text-xl font-bold text-center mb-1">Simple Pricing</h2>
            <p className="text-sm text-slate-400 text-center mb-6">Cancel anytime. No hidden fees.</p>
            <div className="grid sm:grid-cols-3 gap-4">
              {PLANS.map(plan => (
                <div key={plan.id} className={`rounded-xl border p-5 ${plan.popular ? 'border-blue-500 bg-blue-500/5' : 'border-slate-700'}`}>
                  {plan.popular && <span className="text-[9px] font-bold text-blue-400 uppercase tracking-wider">Most Popular</span>}
                  <h3 className="text-lg font-bold mt-1">{plan.name}</h3>
                  <div className="mt-2 mb-3">
                    <span className="text-2xl font-black">{plan.price}</span>
                    <span className="text-sm text-slate-400">{plan.period}</span>
                  </div>
                  <p className="text-xs text-slate-400 mb-4">{plan.desc}</p>
                  <ul className="space-y-2 mb-5">
                    {plan.features.map(f => (
                      <li key={f} className="text-xs text-slate-300 flex items-center gap-2">
                        <Check size={12} className="text-emerald-400 flex-shrink-0" /> {f}
                      </li>
                    ))}
                  </ul>
                  <button
                    onClick={() => !plan.disabled && handleCheckout(plan.id)}
                    disabled={plan.disabled}
                    className={`w-full py-2 rounded-lg text-sm font-semibold transition ${
                      plan.popular
                        ? 'bg-blue-600 hover:bg-blue-500 text-white'
                        : plan.disabled
                        ? 'bg-slate-800 text-slate-500 cursor-default'
                        : 'bg-slate-800 hover:bg-slate-700 text-slate-300'
                    }`}
                  >
                    {plan.id === userPlan ? 'Current Plan' : plan.cta}
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default function Home() {
  return (
    <Suspense fallback={<div className="bg-[#020617] h-screen" />}>
      <App />
    </Suspense>
  );
}
