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
  { label: 'Claude', y: 28 },
  { label: 'GPT-4o', y: 68 },
  { label: 'Gemini', y: 108 },
  { label: 'DeepSeek', y: 148 },
  { label: 'Qwen', y: 188 },
]
</script>

<template>
  <svg
    ref="svgRef"
    viewBox="0 0 520 220"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-label="Multiple LLM providers connect through Lurus API gateway to your app"
    style="width:100%;height:100%"
  >
    <!-- Background glow under gateway -->
    <ellipse
      v-if="isVisible"
      cx="265" cy="110" rx="60" ry="50"
      fill="#4A9EFF" opacity="0.06"
    />

    <!-- Left: LLM model nodes -->
    <g v-for="(model, i) in models" :key="model.label">
      <rect
        x="12" :y="model.y - 13" width="80" height="26" rx="6"
        fill="#1C1916" stroke="#4A9EFF" stroke-width="1.2" stroke-opacity="0.5"
        :class="isVisible ? 'animate-draw' : ''"
        :style="{ animationDelay: `${i * 80}ms` }"
      />
      <text
        x="52" :y="model.y + 5" text-anchor="middle"
        font-size="10" font-family="ui-monospace,monospace" fill="#A89B8B"
      >{{ model.label }}</text>

      <!-- Connector line to gateway -->
      <line
        x1="94" :y1="model.y"
        x2="220" y2="110"
        stroke="#4A9EFF" stroke-width="1" stroke-dasharray="4 3" stroke-opacity="0.4"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${200 + i * 80}ms` }"
      />

      <!-- Flowing particle -->
      <circle r="2.5" fill="#4A9EFF" opacity="0.85">
        <animateMotion
          v-if="isVisible"
          :dur="`${2.2 + i * 0.18}s`"
          repeatCount="indefinite"
          :path="`M94,${model.y} L220,110`"
        />
      </circle>
    </g>

    <!-- Center: API Gateway -->
    <rect
      x="205" y="76" width="120" height="68" rx="12"
      fill="#141210" stroke="#4A9EFF" stroke-width="2"
      :class="isVisible ? 'animate-draw' : ''"
      style="animation-delay:550ms"
    />
    <!-- Gateway inner glow ring -->
    <rect
      v-if="isVisible"
      x="209" y="80" width="112" height="60" rx="9"
      fill="none" stroke="#4A9EFF" stroke-width="0.5" stroke-opacity="0.3"
    />
    <text x="265" y="108" text-anchor="middle" font-size="12" font-weight="600" font-family="ui-monospace,monospace" fill="#F5F0E8">Lurus API</text>
    <text x="265" y="124" text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#4A9EFF" fill-opacity="0.85">Gateway</text>

    <!-- Pulsing center dot -->
    <circle
      v-if="isVisible"
      cx="265" cy="96" r="3"
      fill="#4A9EFF" opacity="0.9"
      class="pulse-gateway"
    />

    <!-- Right: arrow -->
    <line
      x1="326" y1="110" x2="408" y2="110"
      stroke="#4A9EFF" stroke-width="1.5" stroke-dasharray="5 3" stroke-opacity="0.6"
      :class="isVisible ? 'animate-draw-line' : ''"
      style="animation-delay:750ms"
    />
    <polygon
      v-if="isVisible"
      points="408,104 420,110 408,116"
      fill="#4A9EFF" opacity="0.7"
    />

    <!-- Output particle -->
    <circle r="3" fill="#4A9EFF" opacity="0.9">
      <animateMotion
        v-if="isVisible"
        dur="1.8s" repeatCount="indefinite"
        path="M326,110 L408,110"
      />
    </circle>

    <!-- Right: Your App -->
    <rect
      x="418" y="82" width="86" height="56" rx="10"
      fill="#141210" stroke="#D4A827" stroke-width="1.8"
      :class="isVisible ? 'animate-draw' : ''"
      style="animation-delay:900ms"
    />
    <text x="461" y="110" text-anchor="middle" font-size="11" font-weight="600" font-family="ui-monospace,monospace" fill="#F5F0E8">Your</text>
    <text x="461" y="125" text-anchor="middle" font-size="11" font-weight="600" font-family="ui-monospace,monospace" fill="#D4A827">App</text>
  </svg>
</template>

<style scoped>
.animate-draw {
  stroke-dashoffset: 300;
  stroke-dasharray: 300;
  animation: draw-line 0.8s ease-out forwards;
}

.animate-draw-line {
  stroke-dashoffset: 250;
  stroke-dasharray: 250;
  animation: draw-line 0.65s ease-out forwards;
}

.pulse-gateway {
  animation: pulse-gw 2s ease-in-out infinite;
}

@keyframes draw-line {
  from { stroke-dashoffset: 300; opacity: 0; }
  to   { stroke-dashoffset: 0;   opacity: 1; }
}

@keyframes pulse-gw {
  0%, 100% { r: 3; opacity: 0.9; }
  50%       { r: 5; opacity: 0.4; }
}

@media (prefers-reduced-motion: reduce) {
  .animate-draw,
  .animate-draw-line {
    animation: none;
    stroke-dashoffset: 0;
    opacity: 1;
  }
  .pulse-gateway { animation: none; }
}
</style>
