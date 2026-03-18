<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

interface EcoNode {
  id: string
  name: string
  tagline: string
  color: string
  ring: 'inner' | 'outer'
  href: string
  angle: number
}

const nodes: EcoNode[] = [
  // Inner ring (infrastructure)
  { id: 'api', name: 'Lurus API', tagline: '50+ 模型网关', color: '#4A9EFF', ring: 'inner', href: 'https://api.lurus.cn', angle: 0 },
  { id: 'kova', name: 'Kova', tagline: 'Agent 引擎', color: '#B08EFF', ring: 'inner', href: '/for-builders', angle: 120 },
  { id: 'switch', name: 'Switch', tagline: '工具管理器', color: '#FF8C69', ring: 'inner', href: '/download', angle: 240 },
  // Outer ring (applications)
  { id: 'lucrum', name: 'Lucrum', tagline: 'AI 量化', color: '#7AFF89', ring: 'outer', href: 'https://gushen.lurus.cn', angle: 40 },
  { id: 'creator', name: 'Creator', tagline: '内容工厂', color: '#FFB86C', ring: 'outer', href: '/download', angle: 110 },
  { id: 'memx', name: 'MemX', tagline: 'AI 记忆', color: '#4AFFCB', ring: 'outer', href: '/download#memx', angle: 200 },
  { id: 'lumen', name: 'Lumen', tagline: '调试器', color: '#FFE566', ring: 'outer', href: '/for-builders', angle: 290 },
]

const connections = [
  { from: 'api', to: 'lucrum' },
  { from: 'api', to: 'creator' },
  { from: 'kova', to: 'lumen' },
  { from: 'kova', to: 'lucrum' },
  { from: 'switch', to: 'memx' },
  { from: 'switch', to: 'creator' },
  { from: 'api', to: 'memx' },
]

const cx = 300
const cy = 200
const innerRadius = 110
const outerRadius = 170

function getNodePos(node: EcoNode) {
  const r = node.ring === 'inner' ? innerRadius : outerRadius
  const rad = (node.angle - 90) * Math.PI / 180
  return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) }
}

function getConnPath(from: string, to: string) {
  const a = nodes.find(n => n.id === from)
  const b = nodes.find(n => n.id === to)
  if (!a || !b) return ''
  const pa = getNodePos(a)
  const pb = getNodePos(b)
  return `M${pa.x},${pa.y} L${pb.x},${pb.y}`
}

const visible = ref(false)
let observer: IntersectionObserver | null = null
const containerRef = ref<HTMLElement | null>(null)

onMounted(() => {
  if (!containerRef.value) return
  observer = new IntersectionObserver(
    ([entry]) => {
      if (entry.isIntersecting) {
        visible.value = true
        observer?.disconnect()
      }
    },
    { threshold: 0.3 }
  )
  observer.observe(containerRef.value)
})

onUnmounted(() => {
  observer?.disconnect()
})

function isExternal(href: string) {
  return href.startsWith('http')
}
</script>

<template>
  <div ref="containerRef" class="ecosystem-map">
    <svg viewBox="0 0 600 400" class="eco-svg" aria-label="Lurus product ecosystem map">
      <!-- Connection lines -->
      <g class="eco-connections" :class="{ 'eco-connections--visible': visible }">
        <path
          v-for="(conn, i) in connections"
          :key="`${conn.from}-${conn.to}`"
          :d="getConnPath(conn.from, conn.to)"
          stroke="var(--color-surface-border)"
          stroke-width="1"
          fill="none"
          stroke-dasharray="4 3"
          :style="{ animationDelay: `${0.3 + i * 0.1}s` }"
        />
      </g>

      <!-- Center hub -->
      <g class="eco-center" :class="{ 'eco-center--visible': visible }">
        <circle :cx="cx" :cy="cy" r="36" fill="var(--color-surface-overlay)" stroke="var(--color-ochre)" stroke-width="1.5" />
        <text :x="cx" :y="cy - 6" text-anchor="middle" fill="var(--color-ochre)" font-size="11" font-weight="700">Lurus</text>
        <text :x="cx" :y="cy + 10" text-anchor="middle" fill="var(--color-text-muted)" font-size="8">AI Ecosystem</text>
      </g>

      <!-- Product nodes -->
      <g
        v-for="(node, i) in nodes"
        :key="node.id"
        class="eco-node"
        :class="{ 'eco-node--visible': visible }"
        :style="{ animationDelay: `${0.2 + i * 0.08}s` }"
      >
        <component
          :is="isExternal(node.href) ? 'a' : 'g'"
          :href="isExternal(node.href) ? node.href : undefined"
          :target="isExternal(node.href) ? '_blank' : undefined"
          :rel="isExternal(node.href) ? 'noopener noreferrer' : undefined"
          class="eco-node-link"
        >
          <circle
            :cx="getNodePos(node).x"
            :cy="getNodePos(node).y"
            :r="node.ring === 'inner' ? 28 : 24"
            fill="var(--color-surface-raised)"
            :stroke="node.color"
            stroke-width="1.5"
          />
          <text
            :x="getNodePos(node).x"
            :y="getNodePos(node).y - 4"
            text-anchor="middle"
            :fill="node.color"
            font-size="9"
            font-weight="600"
          >{{ node.name }}</text>
          <text
            :x="getNodePos(node).x"
            :y="getNodePos(node).y + 8"
            text-anchor="middle"
            fill="var(--color-text-muted)"
            font-size="7"
          >{{ node.tagline }}</text>
        </component>
      </g>
    </svg>
  </div>
</template>

<style scoped>
.ecosystem-map {
  width: 100%;
  max-width: 600px;
  margin: 0 auto;
}

.eco-svg {
  width: 100%;
  height: auto;
}

.eco-center {
  opacity: 0;
  transform: scale(0.8);
  transition: opacity 0.6s ease, transform 0.6s ease;
}

.eco-center--visible {
  opacity: 1;
  transform: scale(1);
}

.eco-node {
  opacity: 0;
  transition: opacity 0.5s ease;
}

.eco-node--visible {
  opacity: 1;
  animation: eco-node-appear 0.5s ease both;
}

@keyframes eco-node-appear {
  from { opacity: 0; }
  to { opacity: 1; }
}

.eco-node-link {
  cursor: pointer;
}

.eco-node-link:hover circle {
  filter: brightness(1.2);
}

.eco-connections path {
  opacity: 0;
  transition: opacity 0.4s ease;
}

.eco-connections--visible path {
  opacity: 0.6;
  animation: draw-line 0.8s ease both;
}

@media (prefers-reduced-motion: reduce) {
  .eco-center,
  .eco-node,
  .eco-connections path {
    opacity: 1;
    animation: none;
    transition: none;
  }
}
</style>
