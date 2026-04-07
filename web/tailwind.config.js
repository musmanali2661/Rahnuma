/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        urdu: ['Noto Nastaliq Urdu', 'serif'],
        sans: ['Inter', 'ui-sans-serif', 'system-ui'],
      },
      colors: {
        motorway: '#2E7D32',
        primary: '#FF9800',
        secondary: '#757575',
        residential: '#E0E0E0',
        unpaved: '#8D6E63',
        rahnuma: {
          50: '#e8f5e9',
          500: '#2E7D32',
          600: '#1b5e20',
        },
      },
    },
  },
  plugins: [],
};
