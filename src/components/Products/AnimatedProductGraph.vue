<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import type { Product } from '../../types/products'

defineProps<{
  products: Product[]
}>()

const graphRef = ref<HTMLElement | null>(null)
const isVisible = ref(false)
let observer: IntersectionObserver | null = null

const CENTER = { x: 140, y: 100 }
const POSITIONS = [
  { x: 50, y: 35 },
  { x: 230, y: 35 },
  { x: 50, y: 165 },
  { x: 230, y: 165 },
]

function bezierPath(from: { x: number; y: number }, to: { x: number; y: number }): string {
  const mx = (from.x + to.x) / 2
  const my = (from.y + to.y) / 2
  const offset = 8
  return `M${from.x},${from.y} Q${mx + offset},${my - offset} ${to.x},${to.y}`
}

const LABELS = ['API', 'Lucrum', 'Mail', 'Switch']

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
  <div ref="graphRef" data-testid="animated-product-graph" aria-hidden="true">
    <svg
      viewBox="0 0 280 200"
      class="w-full max-w-xs text-ink-300"
      :class="{ 'is-visible': isVisible }"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <!-- Connection lines -->
      <g v-for="(pos, idx) in POSITIONS" :key="'line-' + idx">
        <path
          :d="bezierPath(pos, CENTER)"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-dasharray="4 3"
          class="product-graph-line"
          :style="{ animationDelay: `${idx * 200}ms` }"
        />
        <circle
          r="2.5"
          :fill="products[idx]?.bgColor || '#A89B8B'"
          opacity="0.7"
          class="product-graph-particle"
        >
          <animateMotion
            :dur="`${2.5 + idx * 0.3}s`"
            repeatCount="indefinite"
            :begin="`${idx * 0.5}s`"
            :path="bezierPath(pos, CENTER)"
          />
        </circle>
      </g>

      <!-- Center node -->
      <circle
        :cx="CENTER.x"
        :cy="CENTER.y"
        r="28"
        stroke="#C9A227"
        stroke-width="2"
        stroke-dasharray="4 3"
        class="product-graph-center"
      />
      <text
        :x="CENTER.x"
        :y="CENTER.y + 4"
        text-anchor="middle"
        fill="#C9A227"
        font-size="12"
        font-weight="600"
        class="font-hand"
      >
        Lurus
      </text>

      <!-- Product nodes -->
      <g v-for="(pos, idx) in POSITIONS" :key="'node-' + idx">
        <circle
          :cx="pos.x"
          :cy="pos.y"
          r="20"
          :stroke="products[idx]?.bgColor || '#A89B8B'"
          stroke-width="2"
        />
        <text
          :x="pos.x"
          :y="pos.y + 4"
          text-anchor="middle"
          :fill="products[idx]?.bgColor || '#A89B8B'"
          font-size="9"
        >
          {{ LABELS[idx] }}
        </text>
      </g>
    </svg>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.product-graph-line {
  stroke-dashoffset: 200;
  opacity: 0;
}

.is-visible .product-graph-line {
  animation: draw-line 1s ease-out forwards;
}

.product-graph-particle {
  opacity: 0;
}

.is-visible .product-graph-particle {
  opacity: 0.7;
  transition: opacity 0.5s ease 1s;
}

.product-graph-center {
  transform-origin: v-bind('`${CENTER.x}px ${CENTER.y}px`');
  animation: pulse-node 4s ease-in-out infinite;
}

@media (prefers-reduced-motion: reduce) {
  .product-graph-line {
    stroke-dashoffset: 0;
    opacity: 1;
    animation: none !important;
  }
  .product-graph-particle {
    opacity: 0.7;
    transition: none;
  }
  .product-graph-center {
    animation: none;
  }
}
</style>
