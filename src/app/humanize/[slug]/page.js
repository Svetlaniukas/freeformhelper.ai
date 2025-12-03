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
