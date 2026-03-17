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

// Center: YOU node
const cx = 250
const cy = 115

// 6 memory nodes around the center
const memNodes = [
  { label: '工作记忆', angle: -90, r: 82 },
  { label: '偏好设置', angle: -30, r: 88 },
  { label: '项目上下文', angle: 30, r: 82 },
  { label: '代码片段', angle: 90, r: 80 },
  { label: '历史对话', angle: 150, r: 88 },
  { label: '知识库', angle: 210, r: 82 },
]

function nodePos(angle: number, r: number) {
  const a = (angle * Math.PI) / 180
  return { x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) }
}

// Timeline at bottom: memory injection points
const timelineY = 210
const timelineNodes = [80, 160, 240, 320, 400, 480]
</script>

<template>
  <svg
    ref="svgRef"
    viewBox="0 0 520 240"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-label="MemX: cross-session persistent AI memory graph with semantic retrieval"
    style="width:100%;height:100%"
  >
    <!-- Center glow -->
    <circle v-if="isVisible" :cx="cx" :cy="cy" r="55" fill="#4AFFCB" opacity="0.06" />

    <!-- Memory node connectors -->
    <g v-for="(node, i) in memNodes" :key="node.label">
      <line
        :x1="cx" :y1="cy"
        :x2="nodePos(node.angle, node.r).x"
        :y2="nodePos(node.angle, node.r).y"
        stroke="#4AFFCB" stroke-width="0.9" stroke-dasharray="4 3" stroke-opacity="0.35"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${300 + i * 80}ms` }"
      />
      <!-- Flowing particle along edge -->
      <circle r="2" fill="#4AFFCB" opacity="0.7">
        <animateMotion
          v-if="isVisible"
          :dur="`${3 + i * 0.3}s`"
          repeatCount="indefinite"
          :begin="`${i * 0.5}s`"
          :path="`M${nodePos(node.angle, node.r).x},${nodePos(node.angle, node.r).y} L${cx},${cy}`"
        />
      </circle>
    </g>

    <!-- Memory node circles + labels -->
    <g v-for="(node, i) in memNodes" :key="`label-${node.label}`">
      <circle
        :cx="nodePos(node.angle, node.r).x"
        :cy="nodePos(node.angle, node.r).y"
        r="22"
        fill="#141210" stroke="#4AFFCB" stroke-width="1.2" stroke-opacity="0.6"
        :class="isVisible ? 'animate-pulse-node' : ''"
        :style="{ animationDelay: `${0.5 + i * 0.15}s`, opacity: isVisible ? 1 : 0, transition: `opacity 0.4s ${0.4 + i * 0.1}s` }"
      />
      <text
        :x="nodePos(node.angle, node.r).x"
        :y="nodePos(node.angle, node.r).y + 4"
        text-anchor="middle"
        font-size="8.5" font-family="ui-monospace,monospace" fill="#A89B8B"
      >{{ node.label }}</text>
    </g>

    <!-- Center: YOU node -->
    <circle
      :cx="cx" :cy="cy" r="32"
      fill="#1C1916" stroke="#4AFFCB" stroke-width="2"
      :class="isVisible ? 'animate-draw' : ''"
      style="animation-delay:100ms"
    />
    <circle
      v-if="isVisible"
      :cx="cx" :cy="cy" r="26"
      fill="none" stroke="#4AFFCB" stroke-width="0.5" stroke-opacity="0.3"
    />
    <text :x="cx" :y="cy - 3" text-anchor="middle" font-size="13" font-weight="700" font-family="ui-monospace,monospace" fill="#F5F0E8">YOU</text>
    <text :x="cx" :y="cy + 13" text-anchor="middle" font-size="8" font-family="ui-monospace,monospace" fill="#4AFFCB">AI 记忆中心</text>

    <!-- Timeline at bottom (session history) -->
    <line
      x1="60" :y1="timelineY"
      x2="460" :y2="timelineY"
      stroke="#2A2520" stroke-width="1.5"
    />
    <g v-for="(tx, i) in timelineNodes" :key="tx">
      <!-- Timeline dot -->
      <circle
        :cx="tx" :cy="timelineY" r="3.5"
        fill="#1C1916" stroke="#4AFFCB" stroke-width="1.2" stroke-opacity="0.5"
        :class="isVisible ? 'timeline-dot' : ''"
        :style="{ animationDelay: `${0.9 + i * 0.1}s`, opacity: isVisible ? 1 : 0, transition: `opacity 0.3s ${0.8 + i * 0.1}s` }"
      />
      <!-- Particle rising from timeline to center -->
      <circle r="1.8" fill="#4AFFCB" opacity="0.6">
        <animateMotion
          v-if="isVisible"
          :dur="`${2.5 + i * 0.25}s`"
          repeatCount="indefinite"
          :begin="`${i * 0.4}s`"
          :path="`M${tx},${timelineY} L${cx},${cy + 32}`"
        />
      </circle>
    </g>
    <text x="60" :y="timelineY + 14" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D">历史会话</text>
    <text x="420" :y="timelineY + 14" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D" text-anchor="end">当前</text>
  </svg>
</template>

<style scoped>
.animate-draw {
  stroke-dashoffset: 250;
  stroke-dasharray: 250;
  animation: draw-line 0.7s ease-out forwards;
}

.animate-draw-line {
  stroke-dashoffset: 180;
  stroke-dasharray: 180;
  animation: draw-line 0.55s ease-out forwards;
}

.animate-pulse-node {
  animation: pulse-node 2.8s ease-in-out infinite;
}

.timeline-dot {
  animation: pulse-node 3s ease-in-out infinite;
}

@keyframes draw-line {
  from { stroke-dashoffset: 250; opacity: 0; }
  to   { stroke-dashoffset: 0;   opacity: 1; }
}

@keyframes pulse-node {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0.5; }
}

@media (prefers-reduced-motion: reduce) {
  .animate-draw,
  .animate-draw-line {
    animation: none;
    stroke-dashoffset: 0;
    opacity: 1;
  }
  .animate-pulse-node, .timeline-dot { animation: none; }
}
</style>
