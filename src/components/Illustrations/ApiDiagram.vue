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

const models = [
  { label: 'Claude', y: 30 },
  { label: 'GPT', y: 70 },
  { label: 'Gemini', y: 110 },
  { label: 'DeepSeek', y: 150 },
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
    aria-label="Multiple AI models converge through Lurus API gateway to your app"
  >
    <!-- Left: Model nodes -->
    <g v-for="(model, i) in models" :key="model.label">
      <rect
        :x="10" :y="model.y - 12" width="70" height="26" rx="5"
        stroke="#A89B8B" stroke-width="1.5" stroke-dasharray="4 3" fill="#FEF9E7"
        :class="isVisible ? 'animate-draw' : ''"
        :style="{ animationDelay: `${i * 100}ms` }"
      />
      <text
        x="45" :y="model.y + 4" text-anchor="middle"
        class="text-[10px] fill-ink-700 font-mono"
      >{{ model.label }}</text>

      <!-- Connector to gateway -->
      <line
        x1="82" :y1="model.y"
        x2="160" y2="95"
        stroke="#6B8BA4" stroke-width="1.2" stroke-dasharray="5 4"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${200 + i * 100}ms` }"
      />

      <!-- Flowing particle -->
      <circle r="2.5" :fill="isVisible ? '#6B8BA4' : 'transparent'" opacity="0.7">
        <animateMotion
          v-if="isVisible"
          :dur="`${2.5 + i * 0.2}s`" repeatCount="indefinite"
          :path="`M82,${model.y} L160,95`"
        />
      </circle>
    </g>

    <!-- Center: API Gateway box -->
    <rect
      x="145" y="65" width="90" height="60" rx="10"
      stroke="#6B8BA4" stroke-width="2" fill="#FEF9E7"
      :class="isVisible ? 'animate-draw' : ''"
      style="animation-delay: 500ms"
    />
    <text x="190" y="90" text-anchor="middle" class="text-[11px] fill-ink-900 font-semibold">Lurus API</text>
    <text x="190" y="106" text-anchor="middle" class="text-[10px] fill-ink-500">Gateway</text>

    <!-- Right arrow -->
    <line
      x1="238" y1="95" x2="310" y2="95"
      stroke="#6B8BA4" stroke-width="1.5" stroke-dasharray="6 4"
      :class="isVisible ? 'animate-draw-line' : ''"
      style="animation-delay: 700ms"
    />
    <polygon points="310,89 322,95 310,101" fill="#6B8BA4" opacity="0.7" />

    <!-- Flowing particle on output -->
    <circle r="3" :fill="isVisible ? '#6B8BA4' : 'transparent'" opacity="0.8">
      <animateMotion
        v-if="isVisible"
        dur="2s" repeatCount="indefinite"
        path="M238,95 L310,95"
      />
    </circle>

    <!-- Right: Your App -->
    <rect
      x="320" y="72" width="70" height="46" rx="8"
      stroke="#C9A227" stroke-width="2" fill="#FEF9E7"
      :class="isVisible ? 'animate-draw' : ''"
      style="animation-delay: 850ms"
    />
    <text x="355" y="98" text-anchor="middle" class="text-[11px] fill-ink-900 font-semibold">Your App</text>
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
}
</style>
