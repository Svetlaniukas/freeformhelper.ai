#!/bin/bash

echo "🌍 ИСПРАВЛЯЕМ ЯЗЫК И КНОПКУ..."

# 1. ОБНОВЛЯЕМ МОЗГ (API) - ТЕПЕРЬ ОН ПОНИМАЕТ ЯЗЫКИ
cat > src/app/api/humanize/route.js << 'EOL'
import { NextResponse } from 'next/server';
import OpenAI from 'openai';

export const dynamic = 'force-dynamic';

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };
}

export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders() });
}

export async function POST(req) {
  try {
    const { text } = await req.json();
    if (!text) return NextResponse.json({ error: 'No text' }, { status: 400 }, { headers: corsHeaders() });

    const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: `You are an expert Ghostwriter. 
          OBJECTIVE: Rewrite the text to be 100% Undetectable by AI detectors.
          
          CRITICAL RULES:
          1. **LANGUAGE**: DETECT the language of the input. If input is Russian -> Output Russian. If English -> Output English. NEVER translate.
          2. **STYLE**: Use varied sentence length (Burstiness) and natural vocabulary.
          3. **BANNED**: Do not use "delve", "tapestry", "crucial".`
        },
        { role: "user", content: `Rewrite this text (keep the same language):\n\n${text}` }
      ],
      temperature: 1.0, 
    });

    return NextResponse.json(
      { result: completion.choices[0].message.content },
      { headers: corsHeaders() }
    );

  } catch (error) {
    return NextResponse.json({ error: 'Server Error' }, { status: 500 }, { headers: corsHeaders() });
  }
}
EOL

# 2. ОБНОВЛЯЕМ HTML РАСШИРЕНИЯ (Чистим кнопку)
cat > extension/popup.html << 'EOL'
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 340px; background: #020617; color: white; font-family: sans-serif; padding: 16px; margin: 0; }
    .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
    .logo { font-weight: 900; font-size: 16px; background: linear-gradient(to right, #60a5fa, #22d3ee); -webkit-background-clip: text; color: transparent; }
    .status { font-size: 10px; font-weight: bold; color: #4ade80; border: 1px solid #4ade80; padding: 2px 6px; border-radius: 4px; }
    
    label { font-size: 10px; color: #94a3b8; font-weight: bold; display: block; margin-bottom: 5px; }
    textarea { width: 100%; height: 100px; background: #0f172a; border: 1px solid #1e293b; color: #e2e8f0; border-radius: 8px; padding: 10px; box-sizing: border-box; resize: none; font-family: monospace; font-size: 11px; outline: none; }
    textarea:focus { border-color: #38bdf8; }
    
    button { width: 100%; border: none; padding: 12px; border-radius: 8px; font-weight: bold; cursor: pointer; margin-top: 12px; transition: 0.2s; font-size: 12px; }
    .btn-primary { background: white; color: black; }
    .btn-primary:hover { transform: scale(1.02); }
    .btn-primary:disabled { opacity: 0.5; cursor: wait; }
    
    .btn-secondary { background: #1e293b; color: #94a3b8; margin-top: 8px; border: 1px solid #334155; }
    .btn-secondary:hover { color: white; border-color: #64748b; }

    .result-area { display: none; margin-top: 15px; border-top: 1px solid #1e293b; padding-top: 15px; }
    .paywall-hint { font-size: 10px; color: #64748b; text-align: center; margin-top: 10px; }
    a { color: #38bdf8; text-decoration: none; }
  </style>
</head>
<body>
  <div class="header">
    <div class="logo">FreeFormHelper</div>
    <div class="status">READY</div>
  </div>

  <label>SELECTED TEXT</label>
  <textarea id="input" placeholder="Select text on page..."></textarea>
  
  <button id="humanizeBtn" class="btn-primary">HUMANIZE SELECTION</button>

  <div class="result-area" id="resultArea">
    <label style="color:#4ade80;">HUMANIZED RESULT</label>
    <textarea id="output" readonly></textarea>
    <button id="copyBtn" class="btn-secondary">COPY TO CLIPBOARD</button>
    <div class="paywall-hint">
      To bypass limits, <a href="https://freeformhelper-ai.onrender.com" target="_blank">Open Web App</a>
    </div>
  </div>

  <script src="popup.js"></script>
</body>
</html>
EOL

# 3. ОБНОВЛЯЕМ JS РАСШИРЕНИЯ (Чтобы текст кнопки не менялся на старый)
cat > extension/popup.js << 'EOL'
document.addEventListener('DOMContentLoaded', () => {
  const input = document.getElementById('input');
  const output = document.getElementById('output');
  const humanizeBtn = document.getElementById('humanizeBtn');
  const copyBtn = document.getElementById('copyBtn');
  const resultArea = document.getElementById('resultArea');

  // URL ТВОЕГО САЙТА (Автоматически берем с Render, если что поправь вручную)
  const API_URL = "https://freeformhelper-ai.onrender.com/api/humanize";

  chrome.tabs.query({active: true, currentWindow: true}, (tabs) => {
    chrome.scripting.executeScript({
      target: {tabId: tabs[0].id},
      func: () => window.getSelection().toString()
    }, (results) => {
      if (results && results[0] && results[0].result) {
        input.value = results[0].result;
      }
    });
  });

  humanizeBtn.addEventListener('click', async () => {
    const text = input.value;
    if(!text) return;

    humanizeBtn.disabled = true;
    humanizeBtn.innerText = "WORKING..."; // Простой текст при загрузке

    try {
      const res = await fetch(API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: text })
      });

      const data = await res.json();
      
      if(data.result) {
        output.value = data.result;
        resultArea.style.display = 'block';
        humanizeBtn.innerText = "DONE"; // Простой текст в конце
      } else {
        output.value = "Error: " + JSON.stringify(data);
        resultArea.style.display = 'block';
      }
    } catch (err) {
      output.value = "Connection failed. Check internet or Render site.";
      resultArea.style.display = 'block';
    } finally {
      humanizeBtn.disabled = false;
      if(humanizeBtn.innerText !== "DONE") humanizeBtn.innerText = "HUMANIZE SELECTION";
    }
  });

  copyBtn.addEventListener('click', () => {
    output.select();
    document.execCommand('copy');
    copyBtn.innerText = "COPIED";
    setTimeout(() => copyBtn.innerText = "COPY TO CLIPBOARD", 2000);
  });
});
EOL

echo "✅ ИСПРАВЛЕНО: ЯЗЫК (RU/EN) И КНОПКА (CLEAN)"
echo "Отправляем на GitHub..."

git add .
git commit -m "Fix language support and clean UI buttons"
git push -u origin main --force

echo "🚀 ГОТОВО!"
echo "ВАЖНО: Зайди в Chrome -> Расширения -> Нажми кнопку 'Обновить' (круговая стрелка) у FreeForm Helper."
