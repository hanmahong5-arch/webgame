<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const graphRef = ref<HTMLElement | null>(null)
const isVisible = ref(false)
let observer: IntersectionObserver | null = null

const CENTER = { x: 200, y: 150 }
const NODES = [
  { id: 'api', label: 'API', color: '#6B8BA4', x: 70, y: 50 },
  { id: 'lucrum', label: 'Lucrum', color: '#7D8B6A', x: 330, y: 50 },
  { id: 'mail', label: 'Mail', color: '#8B6B7D', x: 70, y: 250 },
  { id: 'switch', label: 'Switch', color: '#C67B5C', x: 330, y: 250 },
]

function bezierPath(from: { x: number; y: number }, to: { x: number; y: number }): string {
  const mx = (from.x + to.x) / 2
  const my = (from.y + to.y) / 2
  const offset = 12
  return `M${from.x},${from.y} Q${mx + offset},${my - offset} ${to.x},${to.y}`
}

onMounted(() => {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    isVisible.value = true
    return
  }
  observer = new IntersectionObserver(
    ([entry]) => {
      if (entry.isIntersecting) {
        isVisible.value = true
        observer?.disconnect()
      }
    },
    { threshold: 0.2 }
  )
  if (graphRef.value) observer.observe(graphRef.value)
})

onUnmounted(() => {
  observer?.disconnect()
  observer = null
})
</script>

<template>
  <div ref="graphRef" class="w-full max-w-lg mx-auto" data-testid="ecosystem-graph">
    <svg
      viewBox="0 0 400 300"
      class="w-full"
      :class="{ 'is-visible': isVisible }"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label="Lurus product ecosystem connection graph"
    >
      <!-- Connection lines with draw animation -->
      <g v-for="(node, idx) in NODES" :key="'line-' + node.id">
        <path
          :d="bezierPath(node, CENTER)"
          stroke="currentColor"
          class="text-[var(--color-text-muted)] ecosystem-line"
          stroke-width="1.5"
          stroke-dasharray="4 3"
          :style="{ animationDelay: `${idx * 200}ms` }"
        />
        <!-- Data flow particle using SMIL -->
        <circle
          r="3"
          :fill="node.color"
          opacity="0.7"
          class="ecosystem-particle"
        >
          <animateMotion
            :dur="`${2.5 + idx * 0.3}s`"
            repeatCount="indefinite"
            :begin="`${idx * 0.5}s`"
            :path="bezierPath(node, CENTER)"
          />
        </circle>
      </g>

      <!-- Center node -->
      <circle
        :cx="CENTER.x"
        :cy="CENTER.y"
        r="32"
        stroke="#C9A227"
        stroke-width="2"
        stroke-dasharray="4 3"
        class="ecosystem-center-node"
      />
      <text
        :x="CENTER.x"
        :y="CENTER.y + 4"
        text-anchor="middle"
        fill="#C9A227"
        font-size="14"
        font-weight="600"
        class="font-semibold"
      >
        Lurus
      </text>

      <!-- Product nodes -->
      <g v-for="node in NODES" :key="'node-' + node.id">
        <circle
          :cx="node.x"
          :cy="node.y"
          r="22"
          :stroke="node.color"
          stroke-width="2"
        />
        <text
          :x="node.x"
          :y="node.y + 4"
          text-anchor="middle"
          :fill="node.color"
          font-size="10"
          font-weight="500"
        >
          {{ node.label }}
        </text>
      </g>
    </svg>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.ecosystem-line {
  stroke-dashoffset: 200;
  opacity: 0;
}

.is-visible .ecosystem-line {
  animation: draw-line 1s ease-out forwards;
}

.ecosystem-particle {
  opacity: 0;
}

.is-visible .ecosystem-particle {
  opacity: 0.7;
  transition: opacity 0.5s ease 1s;
}

.ecosystem-center-node {
  transform-origin: v-bind('`${CENTER.x}px ${CENTER.y}px`');
  animation: pulse-node 4s ease-in-out infinite;
}

@media (prefers-reduced-motion: reduce) {
  .ecosystem-line {
    stroke-dashoffset: 0;
    opacity: 1;
    animation: none !important;
  }
  .ecosystem-particle {
    opacity: 0.7;
    transition: none;
  }
  .ecosystem-center-node {
    animation: none;
  }
}
</style>
