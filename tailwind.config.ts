import type { Config } from 'tailwindcss'

export default {
  content: [
    './index.html',
    './src/**/*.{vue,js,ts,jsx,tsx}'
  ],
  theme: {
    extend: {
      colors: {
        // Cream palette (warm paper tones)
        cream: {
          50: '#FFFDF7',
          100: '#FEF9E7',
          200: '#FCF4D6',
          300: '#F5E6B8'
        },
        // Ink palette (warm brown/gray tones)
        ink: {
          900: '#2C2416',
          700: '#4A3F2F',
          500: '#6B5D4D',
          300: '#A89B8B',
          100: '#D4CCC0'
        },
        // Accent color (ochre gold)
        ochre: '#C9A227',
        // Product-specific colors
        'product-api': '#6B8BA4',      // Slate blue
        'product-gushen': '#7D8B6A',   // Sage green
        'product-switch': '#C67B5C',   // Terracotta
        'product-docs': '#C9A227',     // Ochre gold
        'product-deaigc': '#8B6B7D'    // Plum
      },
      // Golden ratio (phi = 1.618) based font sizes
      fontSize: {
        'phi-sm':   ['10px',  { lineHeight: '1.9'  }],
        'phi-base': ['16px',  { lineHeight: '1.75' }],
        'phi-lg':   ['21px',  { lineHeight: '1.65' }],
        'phi-xl':   ['26px',  { lineHeight: '1.6'  }],
        'phi-2xl':  ['42px',  { lineHeight: '1.4'  }],
        'phi-3xl':  ['68px',  { lineHeight: '1.3'  }],
        'phi-4xl':  ['110px', { lineHeight: '1.1'  }]
      },
      // Fibonacci-based spacing system
      spacing: {
        'fib-1': '5px',
        'fib-2': '8px',
        'fib-3': '13px',
        'fib-4': '21px',
        'fib-5': '34px',
        'fib-6': '55px',
        'fib-7': '89px',
        'fib-8': '144px'
      },
      // Golden ratio aspect ratios
      aspectRatio: {
        'golden': '1.618 / 1',
        'golden-wide': '2.618 / 1'
      },
      // Hand-drawn style font family
      fontFamily: {
        'hand': ['Caveat', 'cursive'],
        'body': ['Noto Sans SC', 'Inter', '-apple-system', 'BlinkMacSystemFont', 'sans-serif']
      },
      // Border radius for sketchy feel
      borderRadius: {
        'sketchy': '4px 15px 8px 12px / 12px 8px 15px 4px',
        'sketchy-btn': '3px 10px 5px 12px / 12px 5px 10px 3px'
      },
      // Animations
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'wiggle': 'wiggle 3s ease-in-out infinite'
      },
      keyframes: {
        'float': {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-10px)' }
        },
        'wiggle': {
          '0%, 100%': { transform: 'rotate(-1deg)' },
          '50%': { transform: 'rotate(1deg)' }
        }
      },
      // Box shadows for paper effect
      boxShadow: {
        'paper': '3px 3px 0 #D4CCC0',
        'paper-hover': '5px 5px 0 #D4CCC0'
      }
    }
  },
  plugins: []
} satisfies Config
