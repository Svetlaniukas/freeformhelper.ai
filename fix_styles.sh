#!/bin/bash

echo "🎨 ЧИНИМ ДИЗАЙН (TAILWIND CSS)..."

# 1. Создаем tailwind.config.js (Инструкция, где искать стили)
cat > tailwind.config.js << 'EOL'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-conic":
          "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
      },
    },
  },
  plugins: [],
};
EOL

# 2. Создаем postcss.config.js (Чтобы стили собирались)
cat > postcss.config.js << 'EOL'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOL

echo "✅ КОНФИГУРАЦИЯ СТИЛЕЙ ВОССТАНОВЛЕНА!"
echo "Теперь сделай:"
echo "1. git add ."
echo "2. git commit -m 'Fix Tailwind styles'"
echo "3. git push origin main"
