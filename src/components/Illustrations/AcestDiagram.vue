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

const metrics = [
  { label: '< 8MB RAM', x: 290, y: 45 },
  { label: '0 GC Pause', x: 290, y: 90 },
  { label: '< 50ms Wake', x: 290, y: 135 },
]
</script>

<template>
  <svg
    ref="svgRef"
    class="w-full h-full"
    viewBox="0 0 400 190"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-label="ACEST Desktop: Rust-native performance with minimal memory usage"
  >
    <!-- Desktop outline -->
    <rect
      x="30" y="25" width="180" height="120" rx="8"
      stroke="#5C7A8B" stroke-width="2" fill="#1C1916"
      :class="isVisible ? 'animate-draw' : ''"
    />
    <!-- Screen area -->
    <rect
      x="40" y="35" width="160" height="85" rx="4"
      stroke="#A89B8B" stroke-width="1" stroke-dasharray="3 2" fill="#141210"
      :class="isVisible ? 'animate-draw' : ''"
      style="animation-delay: 200ms"
    />
    <!-- Stand -->
    <line x1="90" y1="145" x2="150" y2="145" stroke="#5C7A8B" stroke-width="2" />
    <line x1="120" y1="145" x2="120" y2="160" stroke="#5C7A8B" stroke-width="2" />
    <line x1="95" y1="160" x2="145" y2="160" stroke="#5C7A8B" stroke-width="2" />

    <!-- Hotkey ripple in the screen -->
    <circle
      cx="120" cy="77" r="8"
      stroke="#C9A227" stroke-width="1.5" fill="none"
      :class="isVisible ? 'ripple-1' : ''"
      style="animation-delay: 500ms"
    />
    <circle
      cx="120" cy="77" r="18"
      stroke="#C9A227" stroke-width="1" fill="none" opacity="0.5"
      :class="isVisible ? 'ripple-2' : ''"
      style="animation-delay: 700ms"
    />
    <circle
      cx="120" cy="77" r="28"
      stroke="#C9A227" stroke-width="0.8" fill="none" opacity="0.3"
      :class="isVisible ? 'ripple-3' : ''"
      style="animation-delay: 900ms"
    />

    <!-- Rust badge inside screen -->
    <text
      x="120" y="55" text-anchor="middle"
      class="text-[10px] fill-[var(--color-text-muted)] font-mono"
      :class="isVisible ? 'animate-fade-in' : ''"
      style="animation-delay: 400ms"
    >Rust Native</text>

    <!-- Hotkey label -->
    <text
      x="120" y="105" text-anchor="middle"
      class="text-[10px] fill-ochre font-mono"
      :class="isVisible ? 'animate-fade-in' : ''"
      style="animation-delay: 600ms"
    >Ctrl + Space</text>

    <!-- Performance metrics floating to the right -->
    <g v-for="(metric, i) in metrics" :key="metric.label">
      <!-- Connector from desktop -->
      <line
        x1="212" :y1="77"
        :x2="metric.x - 10" :y2="metric.y"
        stroke="#5C7A8B" stroke-width="1" stroke-dasharray="4 3" opacity="0.5"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${600 + i * 150}ms` }"
      />
      <!-- Metric pill -->
      <rect
        :x="metric.x - 10" :y="metric.y - 12" width="100" height="24" rx="12"
        stroke="#5C7A8B" stroke-width="1.5" fill="#1C1916"
        :class="isVisible ? 'animate-draw' : ''"
        :style="{ animationDelay: `${700 + i * 150}ms` }"
      />
      <text
        :x="metric.x + 40" :y="metric.y + 4" text-anchor="middle"
        class="text-[10px] fill-[var(--color-text-secondary)] font-mono font-semibold"
      >{{ metric.label }}</text>

      <!-- Pulsing dot -->
      <circle
        :cx="metric.x - 4" :cy="metric.y" r="3"
        fill="#5C7A8B"
        :class="isVisible ? 'pulse-dot' : ''"
        :style="{ animationDelay: `${800 + i * 200}ms` }"
      />
    </g>
  </svg>
</template>

<style scoped>
.animate-draw {
  stroke-dashoffset: 400;
  stroke-dasharray: 400;
  animation: draw-line 0.8s ease-out forwards;
}

.animate-draw-line {
  stroke-dashoffset: 200;
  stroke-dasharray: 200;
  animation: draw-line 0.6s ease-out forwards;
}

.animate-fade-in {
  opacity: 0;
  animation: fade-in 0.5s ease-out forwards;
}

.ripple-1,
.ripple-2,
.ripple-3 {
  animation: ripple 2.5s ease-out infinite;
}

.ripple-2 { animation-delay: 0.3s; }
.ripple-3 { animation-delay: 0.6s; }

.pulse-dot {
  animation: pulse-node 2s ease-in-out infinite;
}

@keyframes draw-line {
  from { stroke-dashoffset: 200; opacity: 0; }
  to { stroke-dashoffset: 0; opacity: 1; }
}

@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes ripple {
  0% { transform-origin: center; transform: scale(0.8); opacity: 0.6; }
  100% { transform-origin: center; transform: scale(1.4); opacity: 0; }
}

@keyframes pulse-node {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.3); opacity: 0.7; }
}

@media (prefers-reduced-motion: reduce) {
  .animate-draw,
  .animate-draw-line,
  .animate-fade-in {
    animation: none;
    stroke-dashoffset: 0;
    opacity: 1;
  }
  .ripple-1, .ripple-2, .ripple-3, .pulse-dot {
    animation: none;
  }
}
</style>
