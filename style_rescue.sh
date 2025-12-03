#!/bin/bash

echo "🎨 ЗАПУСК РЕАНИМАЦИИ СТИЛЕЙ (STYLE RESCUE)..."

# 1. ПЕРЕЗАПИСЫВАЕМ tailwind.config.js (Указываем, где искать стили)
cat > tailwind.config.js << 'EOL'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
      },
    },
  },
  plugins: [],
};
EOL

# 2. ПЕРЕЗАПИСЫВАЕМ postcss.config.js (Движок стилей)
cat > postcss.config.js << 'EOL'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOL

# 3. ПЕРЕЗАПИСЫВАЕМ globals.css (Сами цвета и неоновый стиль)
cat > src/app/globals.css << 'EOL'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --background: #020617; /* Темно-синий космос */
  --foreground: #ffffff;
}

body {
  color: var(--foreground);
  background: var(--background);
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Анимация сканера */
@keyframes scan {
  0% { top: 0%; opacity: 0; box-shadow: 0 0 2px rgba(56, 189, 248, 0); }
  15% { opacity: 1; box-shadow: 0 0 15px rgba(56, 189, 248, 0.8); }
  85% { opacity: 1; box-shadow: 0 0 15px rgba(56, 189, 248, 0.8); }
  100% { top: 100%; opacity: 0; }
}
.scan-line {
  position: absolute;
  width: 100%;
  height: 3px;
  background: #38bdf8;
  animation: scan 2.5s cubic-bezier(0.4, 0, 0.2, 1) infinite;
  z-index: 10;
}

/* Размытие */
.paywall-blur {
  filter: blur(8px);
  user-select: none;
  pointer-events: none;
}
EOL

# 4. ПЕРЕЗАПИСЫВАЕМ layout.js (ГЛАВНОЕ: Подключаем файл стилей!)
# Если этой строчки 'import ./globals.css' нет, сайт будет голым.
cat > src/app/layout.js << 'EOL'
import './globals.css'; // <--- ВОТ ЭТО ДЕЛАЕТ САЙТ КРАСИВЫМ
import Protection from './components/Protection';

export const metadata = {
  title: 'FreeForm Helper - AI Humanizer',
  description: 'Bypass Turnitin and GPTZero instantly.',
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="antialiased select-none">
        <Protection />
        {children}
      </body>
    </html>
  )
}
EOL

echo "✅ СТИЛИ ВОССТАНОВЛЕНЫ!"
echo "Отправляем на GitHub..."

# 5. ОТПРАВЛЯЕМ ИЗМЕНЕНИЯ
git add .
git commit -m "Fix broken styles: Re-link globals.css"
git push -u origin main --force

echo "🚀 ГОТОВО! Жди 2 минуты, пока Render обновится."#!/bin/bash

echo "🎨 ЗАПУСК РЕАНИМАЦИИ СТИЛЕЙ (STYLE RESCUE)..."

# 1. ПЕРЕЗАПИСЫВАЕМ tailwind.config.js (Указываем, где искать стили)
cat > tailwind.config.js << 'EOL'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
      },
    },
  },
  plugins: [],
};
EOL

# 2. ПЕРЕЗАПИСЫВАЕМ postcss.config.js (Движок стилей)
cat > postcss.config.js << 'EOL'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOL

# 3. ПЕРЕЗАПИСЫВАЕМ globals.css (Сами цвета и неоновый стиль)
cat > src/app/globals.css << 'EOL'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --background: #020617; /* Темно-синий космос */
  --foreground: #ffffff;
}

body {
  color: var(--foreground);
  background: var(--background);
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Анимация сканера */
@keyframes scan {
  0% { top: 0%; opacity: 0; box-shadow: 0 0 2px rgba(56, 189, 248, 0); }
  15% { opacity: 1; box-shadow: 0 0 15px rgba(56, 189, 248, 0.8); }
  85% { opacity: 1; box-shadow: 0 0 15px rgba(56, 189, 248, 0.8); }
  100% { top: 100%; opacity: 0; }
}
.scan-line {
  position: absolute;
  width: 100%;
  height: 3px;
  background: #38bdf8;
  animation: scan 2.5s cubic-bezier(0.4, 0, 0.2, 1) infinite;
  z-index: 10;
}

/* Размытие */
.paywall-blur {
  filter: blur(8px);
  user-select: none;
  pointer-events: none;
}
EOL

# 4. ПЕРЕЗАПИСЫВАЕМ layout.js (ГЛАВНОЕ: Подключаем файл стилей!)
# Если этой строчки 'import ./globals.css' нет, сайт будет голым.
cat > src/app/layout.js << 'EOL'
import './globals.css'; // <--- ВОТ ЭТО ДЕЛАЕТ САЙТ КРАСИВЫМ
import Protection from './components/Protection';

export const metadata = {
  title: 'FreeForm Helper - AI Humanizer',
  description: 'Bypass Turnitin and GPTZero instantly.',
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="antialiased select-none">
        <Protection />
        {children}
      </body>
    </html>
  )
}
EOL

echo "✅ СТИЛИ ВОССТАНОВЛЕНЫ!"
echo "Отправляем на GitHub..."

# 5. ОТПРАВЛЯЕМ ИЗМЕНЕНИЯ
git add .
git commit -m "Fix broken styles: Re-link globals.css"
git push -u origin main --force

echo "🚀 ГОТОВО! Жди 2 минуты, пока Render обновится."
