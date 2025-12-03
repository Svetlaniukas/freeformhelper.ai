#!/bin/bash

echo "🚑 ЛЕЧИМ ОШИБКУ СБОРКИ (AUTOPREFIXER)..."

# 1. Устанавливаем недостающие библиотеки для CSS
# Флаг --save запишет их в package.json, чтобы Render их увидел
npm install autoprefixer postcss --save

echo "✅ БИБЛИОТЕКИ УСТАНОВЛЕНЫ!"

# 2. Отправляем изменения на GitHub
git add .
git commit -m "Fix build: Install autoprefixer and postcss"
git push -u origin main --force

echo "🚀 Улетело! Теперь сборка на Render должна пройти успешно."
