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

// 5 pipeline stages: evenly spaced
const stages = [
  { label: '输入视频', icon: '▶', x: 52 },
  { label: 'yt-dlp',   icon: '⬇', x: 152 },
  { label: 'Whisper',  icon: '🎙', x: 255 },
  { label: 'LLM 编辑', icon: '✦', x: 358 },
  { label: '发布',     icon: '⇥', x: 458 },
]

const pipelineY = 100

// Three publish targets fanning out from stage 5
const publishTargets = [
  { label: 'YouTube',      x: 510, y: 50  },
  { label: '微信视频号',    x: 510, y: 100 },
  { label: '抖音',          x: 510, y: 150 },
]
</script>

<template>
  <svg
    ref="svgRef"
    viewBox="0 0 560 200"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-label="Lurus Creator pipeline: video input → yt-dlp → Whisper → LLM → multi-platform publish"
    style="width:100%;height:100%"
  >
    <!-- Pipeline connectors (drawn first) -->
    <g v-for="(stage, i) in stages.slice(0, -1)" :key="`conn-${i}`">
      <line
        :x1="stage.x + 34" :y1="pipelineY"
        :x2="stages[i + 1].x - 34" :y2="pipelineY"
        stroke="#FFB86C" stroke-width="1.5" stroke-dasharray="5 3" stroke-opacity="0.5"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${200 + i * 150}ms` }"
      />
      <!-- Particle flowing right -->
      <circle r="3" fill="#FFB86C" opacity="0.9">
        <animateMotion
          v-if="isVisible"
          :dur="`${1.8 + i * 0.1}s`"
          repeatCount="indefinite"
          :begin="`${i * 0.3}s`"
          :path="`M${stage.x + 34},${pipelineY} L${stages[i + 1].x - 34},${pipelineY}`"
        />
      </circle>
    </g>

    <!-- Pipeline stage boxes -->
    <g v-for="(stage, i) in stages" :key="stage.label">
      <rect
        :x="stage.x - 34" :y="pipelineY - 28" width="68" height="56" rx="10"
        fill="#141210" stroke="#FFB86C" stroke-width="1.5" stroke-opacity="0.7"
        :class="isVisible ? 'animate-draw' : ''"
        :style="{ animationDelay: `${i * 120}ms` }"
      />
      <text
        :x="stage.x" :y="pipelineY - 8"
        text-anchor="middle" font-size="16" fill="#FFB86C"
      >{{ stage.icon }}</text>
      <text
        :x="stage.x" :y="pipelineY + 14"
        text-anchor="middle" font-size="9.5" font-family="ui-monospace,monospace" fill="#A89B8B"
      >{{ stage.label }}</text>
    </g>

    <!-- Fan-out lines from last stage to publish targets -->
    <g v-for="(target, i) in publishTargets" :key="target.label">
      <line
        :x1="stages[4].x + 34" :y1="pipelineY"
        :x2="target.x - 44" :y2="target.y"
        stroke="#FFB86C" stroke-width="1" stroke-dasharray="4 3" stroke-opacity="0.45"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${750 + i * 100}ms` }"
      />
      <!-- Fanout particle -->
      <circle r="2.5" fill="#FFB86C" opacity="0.8">
        <animateMotion
          v-if="isVisible"
          :dur="`${2 + i * 0.2}s`"
          repeatCount="indefinite"
          :begin="`${i * 0.35 + 0.5}s`"
          :path="`M${stages[4].x + 34},${pipelineY} L${target.x - 44},${target.y}`"
        />
      </circle>

      <!-- Publish target pill -->
      <rect
        :x="target.x - 44" :y="target.y - 12" width="88" height="24" rx="12"
        fill="#1C1916" stroke="#FFB86C" stroke-width="1.2" stroke-opacity="0.55"
        :style="{ opacity: isVisible ? 1 : 0, transition: `opacity 0.35s ${0.8 + i * 0.1}s` }"
      />
      <text
        :x="target.x" :y="target.y + 4"
        text-anchor="middle" font-size="10" font-family="ui-monospace,monospace" fill="#A89B8B"
      >{{ target.label }}</text>
    </g>

    <!-- Step numbers below boxes -->
    <g v-if="isVisible">
      <g v-for="(stage, i) in stages" :key="`step-${i}`">
        <text
          :x="stage.x" :y="pipelineY + 42"
          text-anchor="middle" font-size="9" font-family="ui-monospace,monospace" fill="#6B5D4D"
        >{{ String(i + 1).padStart(2, '0') }}</text>
      </g>
    </g>
  </svg>
</template>

<style scoped>
.animate-draw {
  stroke-dashoffset: 300;
  stroke-dasharray: 300;
  animation: draw-line 0.75s ease-out forwards;
}

.animate-draw-line {
  stroke-dashoffset: 200;
  stroke-dasharray: 200;
  animation: draw-line 0.55s ease-out forwards;
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
