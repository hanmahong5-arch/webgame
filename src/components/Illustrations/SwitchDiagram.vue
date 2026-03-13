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

const tools = [
  { label: 'Cursor', x: 40, y: 30 },
  { label: 'Claude', x: 40, y: 80 },
  { label: 'Gemini', x: 40, y: 130 },
  { label: 'Cline', x: 40, y: 180 },
]
</script>

<template>
  <svg
    ref="svgRef"
    class="w-full h-full"
    viewBox="0 0 400 220"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-label="Lurus Switch unifies multiple AI tools into one panel"
  >
    <!-- Tool icons on the left -->
    <g v-for="(tool, i) in tools" :key="tool.label">
      <rect
        :x="tool.x - 30" :y="tool.y - 14" width="60" height="28" rx="6"
        stroke="#A89B8B" stroke-width="1.5" stroke-dasharray="4 3" fill="#FEF9E7"
        :class="isVisible ? 'animate-draw' : ''"
        :style="{ animationDelay: `${i * 150}ms` }"
      />
      <text
        :x="tool.x" :y="tool.y + 4" text-anchor="middle"
        class="text-[11px] fill-ink-700 font-mono"
      >{{ tool.label }}</text>

      <!-- Dashed connector line to center panel -->
      <line
        :x1="tool.x + 32" :y1="tool.y"
        x2="200" :y2="110"
        stroke="#C67B5C" stroke-width="1.2" stroke-dasharray="6 4"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${300 + i * 120}ms` }"
      />

      <!-- Flowing particle along the path -->
      <circle r="3" :fill="isVisible ? '#C67B5C' : 'transparent'" opacity="0.8">
        <animateMotion
          v-if="isVisible"
          :dur="`${2 + i * 0.3}s`" repeatCount="indefinite"
          :path="`M${tool.x + 32},${tool.y} L200,110`"
        />
      </circle>
    </g>

    <!-- Central Lurus Switch panel -->
    <rect
      x="175" y="70" width="100" height="80" rx="10"
      stroke="#C67B5C" stroke-width="2" fill="#FEF9E7"
      :class="isVisible ? 'animate-draw' : ''"
      style="animation-delay: 600ms"
    />
    <text x="225" y="106" text-anchor="middle" class="text-[12px] fill-ink-900 font-semibold">Lurus</text>
    <text x="225" y="122" text-anchor="middle" class="text-[12px] fill-ink-900 font-semibold">Switch</text>

    <!-- Output arrow to right -->
    <line
      x1="278" y1="110" x2="350" y2="110"
      stroke="#C67B5C" stroke-width="1.5" stroke-dasharray="6 4"
      :class="isVisible ? 'animate-draw-line' : ''"
      style="animation-delay: 800ms"
    />
    <polygon
      points="350,104 362,110 350,116"
      fill="#C67B5C" opacity="0.7"
    />

    <!-- Right label -->
    <text x="360" y="106" class="text-[11px] fill-ink-500">Unified</text>
    <text x="360" y="120" class="text-[11px] fill-ink-500">Panel</text>
  </svg>
</template>

<style scoped>
.animate-draw {
  stroke-dashoffset: 200;
  stroke-dasharray: 200;
  animation: draw-line 0.8s ease-out forwards;
}

.animate-draw-line {
  stroke-dashoffset: 200;
  stroke-dasharray: 200;
  animation: draw-line 0.6s ease-out forwards;
}

@keyframes draw-line {
  from { stroke-dashoffset: 200; opacity: 0; }
  to { stroke-dashoffset: 0; opacity: 1; }
}

@media (prefers-reduced-motion: reduce) {
  .animate-draw,
  .animate-draw-line {
    animation: none;
    stroke-dashoffset: 0;
    opacity: 1;
  }
  circle animateMotion {
    display: none;
  }
}
</style>
