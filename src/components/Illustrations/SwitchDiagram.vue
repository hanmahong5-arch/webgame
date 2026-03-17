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
  { label: 'Cursor',  y: 34  },
  { label: 'Claude',  y: 78  },
  { label: 'Gemini',  y: 122 },
  { label: 'Cline',   y: 166 },
]

const switchCx = 220
const switchCy = 110
</script>

<template>
  <svg
    ref="svgRef"
    viewBox="0 0 400 200"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-label="Lurus Switch: multiple AI tools unified into one panel"
    style="width:100%;height:100%"
  >
    <!-- Background glow -->
    <ellipse v-if="isVisible" :cx="switchCx" :cy="switchCy" rx="60" ry="50" fill="#FF8C69" opacity="0.06" />

    <!-- Tool nodes (left) -->
    <g v-for="(tool, i) in tools" :key="tool.label">
      <rect
        x="12" :y="tool.y - 13" width="72" height="26" rx="6"
        fill="#1C1916" stroke="#FF8C69" stroke-width="1.2" stroke-opacity="0.55"
        :class="isVisible ? 'animate-draw' : ''"
        :style="{ animationDelay: `${i * 120}ms` }"
      />
      <text
        x="48" :y="tool.y + 5"
        text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#A89B8B"
      >{{ tool.label }}</text>

      <!-- Connector line -->
      <line
        :x1="86" :y1="tool.y"
        :x2="switchCx - 36" :y2="switchCy"
        stroke="#FF8C69" stroke-width="1" stroke-dasharray="4 3" stroke-opacity="0.4"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${280 + i * 100}ms` }"
      />
      <!-- Particle -->
      <circle r="2.5" fill="#FF8C69" opacity="0.85">
        <animateMotion
          v-if="isVisible"
          :dur="`${1.8 + i * 0.25}s`"
          repeatCount="indefinite"
          :begin="`${i * 0.35}s`"
          :path="`M86,${tool.y} L${switchCx - 36},${switchCy}`"
        />
      </circle>
    </g>

    <!-- Central Switch node -->
    <rect
      :x="switchCx - 36" :y="switchCy - 34" width="72" height="68" rx="12"
      fill="#141210" stroke="#FF8C69" stroke-width="2"
      :class="isVisible ? 'animate-draw' : ''"
      style="animation-delay:500ms"
    />
    <!-- Inner ring -->
    <rect
      v-if="isVisible"
      :x="switchCx - 30" :y="switchCy - 28" width="60" height="56" rx="9"
      fill="none" stroke="#FF8C69" stroke-width="0.5" stroke-opacity="0.25"
    />
    <text :x="switchCx" :y="switchCy - 6"  text-anchor="middle" font-size="11" font-weight="700" font-family="ui-monospace,monospace" fill="#F5F0E8">Lurus</text>
    <text :x="switchCx" :y="switchCy + 10" text-anchor="middle" font-size="11" font-weight="700" font-family="ui-monospace,monospace" fill="#FF8C69">Switch</text>

    <!-- Output line + arrow -->
    <line
      :x1="switchCx + 36" :y1="switchCy"
      x2="344" :y2="switchCy"
      stroke="#FF8C69" stroke-width="1.5" stroke-dasharray="6 4" stroke-opacity="0.7"
      :class="isVisible ? 'animate-draw-line' : ''"
      style="animation-delay:700ms"
    />
    <polygon
      v-if="isVisible"
      :points="`344,${switchCy - 6} 356,${switchCy} 344,${switchCy + 6}`"
      fill="#FF8C69" opacity="0.75"
    />
    <!-- Output particle -->
    <circle r="2.5" fill="#FF8C69" opacity="0.9">
      <animateMotion
        v-if="isVisible"
        dur="1.4s"
        repeatCount="indefinite"
        begin="0.8s"
        :path="`M${switchCx + 36},${switchCy} L344,${switchCy}`"
      />
    </circle>

    <!-- Right label -->
    <text
      v-if="isVisible"
      x="363" :y="switchCy - 4"
      font-size="10" font-family="ui-monospace,monospace" fill="#A89B8B"
      :style="{ opacity: isVisible ? 1 : 0, transition: 'opacity 0.4s 1s' }"
    >One</text>
    <text
      v-if="isVisible"
      x="363" :y="switchCy + 10"
      font-size="10" font-family="ui-monospace,monospace" fill="#FF8C69"
      :style="{ opacity: isVisible ? 1 : 0, transition: 'opacity 0.4s 1s' }"
    >Panel</text>
  </svg>
</template>

<style scoped>
.animate-draw {
  stroke-dashoffset: 300;
  stroke-dasharray: 300;
  animation: draw-line 0.8s ease-out forwards;
}

.animate-draw-line {
  stroke-dashoffset: 200;
  stroke-dasharray: 200;
  animation: draw-line 0.6s ease-out forwards;
}

@keyframes draw-line {
  from { stroke-dashoffset: 300; opacity: 0; }
  to   { stroke-dashoffset: 0;   opacity: 1; }
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
