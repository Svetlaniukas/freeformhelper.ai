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
