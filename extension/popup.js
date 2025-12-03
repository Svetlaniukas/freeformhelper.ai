document.addEventListener('DOMContentLoaded', () => {
  const input = document.getElementById('textInput');
  const btn = document.getElementById('actionBtn');

  // 1. Пытаемся взять выделенный текст со страницы
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

  // 2. При нажатии кнопки - копируем текст и открываем сайт
  btn.addEventListener('click', () => {
    const text = input.value;
    if(text) {
      navigator.clipboard.writeText(text).then(() => {
        // Открываем сайт. Пользователь просто нажмет Ctrl+V
        chrome.tabs.create({ url: "https://freeformhelper-ai.onrender.com" });
      });
    } else {
      chrome.tabs.create({ url: "https://freeformhelper-ai.onrender.com" });
    }
  });
});
