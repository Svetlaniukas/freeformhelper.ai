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
