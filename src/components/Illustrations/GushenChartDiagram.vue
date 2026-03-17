<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const svgRef = ref<SVGSVGElement | null>(null)
const isVisible = ref(false)
let observer: IntersectionObserver | null = null

onMounted(() => {
  if (!svgRef.value) return
  observer = new IntersectionObserver(
    ([entry]) => { if (entry.isIntersecting) isVisible.value = true },
    { threshold: 0.3 }
  )
  observer.observe(svgRef.value)
})

onUnmounted(() => { observer?.disconnect() })

// 10 candlesticks: each has x, open, close, high, low
// Chart area: x from 40 to 460, y from 30 to 190
// Alternating red/green
const candles = [
  { x: 60,  open: 150, close: 130, high: 125, low: 158, green: false },
  { x: 100, open: 132, close: 112, high: 108, low: 140, green: false },
  { x: 140, open: 114, close: 130, high: 106, low: 136, green: true  },
  { x: 180, open: 128, close: 108, high: 104, low: 134, green: false },
  { x: 220, open: 110, close: 125, high: 102, low: 128, green: true  },
  { x: 260, open: 123, close: 108, high: 102, low: 130, green: false },
  { x: 300, open: 110, close: 92,  high: 88,  low: 116, green: false },
  { x: 340, open: 94,  close: 110, high: 86,  low: 116, green: true  },
  { x: 380, open: 108, close: 88,  high: 84,  low: 114, green: false },
  { x: 420, open: 90,  close: 72,  high: 68,  low: 96,  green: false },
]

// MA line points (simplified)
const maPoints = '60,145 100,138 140,128 180,122 220,118 260,115 300,108 340,100 380,95 420,88'

// Buy signal position (on candle index 7 = green candle at x=340)
const signalX = 340
const signalY = 86
</script>

<template>
  <svg
    ref="svgRef"
    viewBox="0 0 520 240"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-label="GuShen AI quantitative trading: candlestick chart with AI buy signal"
    style="width:100%;height:100%"
  >
    <!-- Chart frame -->
    <rect
      x="30" y="20" width="450" height="185" rx="8"
      fill="#0D0B09" stroke="#2A2520" stroke-width="1"
    />

    <!-- Grid lines -->
    <line v-for="y in [60, 100, 140, 180]" :key="y" :x1="30" :y1="y" :x2="480" :y2="y" stroke="#2A2520" stroke-width="0.5" />

    <!-- MA line -->
    <polyline
      :points="maPoints"
      stroke="#4A9EFF" stroke-width="1.2" stroke-opacity="0.6" fill="none"
      :class="isVisible ? 'animate-ma-line' : ''"
    />

    <!-- Candlesticks (drawn in sequence) -->
    <g v-for="(candle, i) in candles" :key="candle.x">
      <!-- Wick (high-low) -->
      <line
        :x1="candle.x" :y1="candle.high"
        :x2="candle.x" :y2="candle.low"
        :stroke="candle.green ? '#7AFF89' : '#FF6B6B'"
        stroke-width="1.5"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${i * 60}ms` }"
      />
      <!-- Body (open-close) -->
      <rect
        :x="candle.x - 10"
        :y="candle.green ? candle.open : candle.close"
        width="20"
        :height="Math.abs(candle.close - candle.open)"
        :fill="candle.green ? '#7AFF89' : '#FF6B6B'"
        :fill-opacity="candle.green ? '0.85' : '0.7'"
        rx="2"
        :class="isVisible ? 'animate-fade-in' : ''"
        :style="{ animationDelay: `${i * 60 + 100}ms` }"
      />
    </g>

    <!-- AI Buy Signal: ripple rings -->
    <g v-if="isVisible">
      <circle :cx="signalX" :cy="signalY" r="8"  stroke="#7AFF89" stroke-width="1.5" fill="none" class="ripple-1" />
      <circle :cx="signalX" :cy="signalY" r="16" stroke="#7AFF89" stroke-width="1"   fill="none" class="ripple-2" />
      <circle :cx="signalX" :cy="signalY" r="24" stroke="#7AFF89" stroke-width="0.7" fill="none" class="ripple-3" />
      <!-- Signal label -->
      <rect :x="signalX - 16" :y="signalY - 32" width="32" height="16" rx="4" fill="#141210" stroke="#7AFF89" stroke-width="1" />
      <text :x="signalX" :y="signalY - 20" text-anchor="middle" font-size="8.5" font-family="ui-monospace,monospace" fill="#7AFF89">AI 买入</text>
    </g>

    <!-- Legend -->
    <g v-if="isVisible" style="opacity:0.75">
      <line x1="36" y1="208" x2="56" y2="208" stroke="#4A9EFF" stroke-width="1.5" />
      <text x="60" y="212" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D">MA5</text>
      <rect x="90" y="202" width="8" height="12" rx="1" fill="#7AFF89" fill-opacity="0.8" />
      <text x="102" y="212" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D">买入</text>
      <rect x="130" y="202" width="8" height="12" rx="1" fill="#FF6B6B" fill-opacity="0.7" />
      <text x="142" y="212" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D">卖出</text>
    </g>
  </svg>
</template>

<style scoped>
.animate-draw-line {
  stroke-dashoffset: 60;
  stroke-dasharray: 60;
  animation: draw-line 0.4s ease-out forwards;
}

.animate-fade-in {
  opacity: 0;
  animation: fade-in 0.3s ease-out forwards;
}

.animate-ma-line {
  stroke-dashoffset: 600;
  stroke-dasharray: 600;
  animation: draw-line 1.4s ease-out forwards 0.3s;
}

.ripple-1 { animation: ripple-out 2.2s ease-out infinite 0.7s; }
.ripple-2 { animation: ripple-out 2.2s ease-out infinite 1s; }
.ripple-3 { animation: ripple-out 2.2s ease-out infinite 1.3s; }

@keyframes draw-line {
  from { stroke-dashoffset: 600; opacity: 0; }
  to   { stroke-dashoffset: 0;   opacity: 1; }
}

@keyframes fade-in {
  from { opacity: 0; }
  to   { opacity: 1; }
}

@keyframes ripple-out {
  0%   { transform: scale(0.6); opacity: 0.8; transform-origin: 340px 86px; }
  100% { transform: scale(1.5); opacity: 0;   transform-origin: 340px 86px; }
}

@media (prefers-reduced-motion: reduce) {
  .animate-draw-line,
  .animate-fade-in,
  .animate-ma-line {
    animation: none;
    stroke-dashoffset: 0;
    opacity: 1;
  }
  .ripple-1, .ripple-2, .ripple-3 { animation: none; }
}
</style>
