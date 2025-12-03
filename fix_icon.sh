#!/bin/bash

echo "👻 ИСПРАВЛЯЕМ ОШИБКУ ЗАГРУЗКИ РАСШИРЕНИЯ..."

# 1. Скачиваем реальную иконку (Привидение)
# Используем публичный CDN иконок. Сохраняем как icon.png
curl -o extension/icon.png "https://img.icons8.com/ios-filled/100/ffffff/ghost.png"

# 2. Обновляем Manifest (на всякий случай, чтобы имена совпадали)
cat > extension/manifest.json << 'EOL'
{
  "manifest_version": 3,
  "name": "FreeForm Helper - AI Humanizer",
  "version": "2.0",
  "description": "Select text and humanize it instantly.",
  "permissions": ["activeTab", "scripting"],
  "host_permissions": ["<all_urls>"],
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "icon.png",
      "48": "icon.png",
      "128": "icon.png"
    }
  },
  "icons": {
    "16": "icon.png",
    "48": "icon.png",
    "128": "icon.png"
  }
}
EOL

echo "✅ ИКОНКА ЗАГРУЖЕНА!"
echo "👉 Теперь нажми кнопку 'Повторить' (Retry) или 'Обновить' в расширениях Chrome."
