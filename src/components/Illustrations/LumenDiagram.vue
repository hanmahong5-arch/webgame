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

// Agent execution flamechart — each node: label, depth, y-center, bar-width, duration
const nodes = [
  { label: 'Agent.run',     depth: 0, y: 28,  barW: 440, dur: '342ms' },
  { label: 'Plan.generate', depth: 1, y: 68,  barW: 200, dur: '145ms' },
  { label: 'LLM.call',      depth: 2, y: 108, barW: 165, dur: '128ms' },
  { label: 'Execute.step',  depth: 1, y: 148, barW: 140, dur: '67ms'  },
  { label: 'Tool.search',   depth: 2, y: 188, barW: 120, dur: '45ms'  },
]

// X position from depth level (18px indent per level)
function nx(depth: number) { return 10 + depth * 18 }

// Tree connector line segments (L-shaped elbows)
const treeLines = [
  // Main trunk: Agent.run → Execute.step (passes through Plan.generate level)
  { x1: 22, y1: 28,  x2: 22, y2: 148 },
  // Elbows to depth-1 children
  { x1: 22, y1: 68,  x2: 28, y2: 68  },
  { x1: 22, y1: 148, x2: 28, y2: 148 },
  // Sub-trunk: Plan.generate → LLM.call
  { x1: 40, y1: 68,  x2: 40, y2: 108 },
  { x1: 40, y1: 108, x2: 46, y2: 108 },
  // Sub-trunk: Execute.step → Tool.search
  { x1: 40, y1: 148, x2: 40, y2: 188 },
  { x1: 40, y1: 188, x2: 46, y2: 188 },
]

// Particles travel down connector paths (parent → child)
const particles = [
  { path: 'M22,28 L22,68 L28,68',    dur: '1.4s', begin: '0s'    },
  { path: 'M40,68 L40,108 L46,108',  dur: '1.2s', begin: '0.3s'  },
  { path: 'M22,79 L22,148 L28,148',  dur: '1.4s', begin: '0.55s' },
  { path: 'M40,148 L40,188 L46,188', dur: '1.2s', begin: '0.8s'  },
]
</script>

<template>
  <svg
    ref="svgRef"
    viewBox="0 0 490 210"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-label="Lumen: Agent execution trace flamechart showing Plan, Execute and tool call timing"
    style="width:100%;height:100%"
  >
    <!-- Background glow -->
    <ellipse v-if="isVisible" cx="200" cy="108" rx="150" ry="80" fill="#FFE566" opacity="0.04" />

    <!-- Tree connector lines (behind bars) -->
    <g v-if="isVisible" stroke="#FFE566" stroke-width="0.9" stroke-opacity="0.22">
      <line
        v-for="(ln, i) in treeLines"
        :key="i"
        :x1="ln.x1" :y1="ln.y1" :x2="ln.x2" :y2="ln.y2"
      />
    </g>

    <!-- Connector particles flowing parent → child -->
    <circle
      v-for="(p, i) in particles"
      :key="`cp-${i}`"
      r="2"
      fill="#FFE566"
      opacity="0.6"
    >
      <animateMotion
        v-if="isVisible"
        :dur="p.dur"
        repeatCount="indefinite"
        :begin="p.begin"
        :path="p.path"
      />
    </circle>

    <!-- Trace bars -->
    <g v-for="(node, i) in nodes" :key="node.label">
      <rect
        :x="nx(node.depth)" :y="node.y - 11"
        :width="node.barW" height="22" rx="4"
        fill="#141210"
        :stroke="'#FFE566'"
        :stroke-width="node.depth === 0 ? 1.5 : 1"
        :stroke-opacity="node.depth === 0 ? 0.7 : 0.4"
        :class="isVisible ? 'animate-draw' : ''"
        :style="{ animationDelay: `${i * 140}ms` }"
      />
      <!-- Label -->
      <text
        :x="nx(node.depth) + 8" :y="node.y + 4"
        font-size="9.5" font-family="ui-monospace,monospace"
        :fill="node.depth === 0 ? '#F5F0E8' : '#A89B8B'"
        :font-weight="node.depth === 0 ? '600' : '400'"
      >{{ node.label }}</text>
      <!-- Duration -->
      <text
        :x="nx(node.depth) + node.barW - 6" :y="node.y + 4"
        text-anchor="end" font-size="8.5" font-family="ui-monospace,monospace"
        fill="#FFE566" :fill-opacity="node.depth === 0 ? 0.9 : 0.6"
      >{{ node.dur }}</text>
      <!-- Scan particle along bar -->
      <circle r="2" fill="#FFE566" opacity="0.7">
        <animateMotion
          v-if="isVisible"
          :dur="`${1.6 + i * 0.18}s`"
          repeatCount="indefinite"
          :begin="`${i * 0.25 + 0.1}s`"
          :path="`M${nx(node.depth)},${node.y} L${nx(node.depth) + node.barW},${node.y}`"
        />
      </circle>
    </g>
  </svg>
</template>

<style scoped>
.animate-draw {
  stroke-dashoffset: 600;
  stroke-dasharray: 600;
  animation: draw-bar 0.7s ease-out forwards;
}

@keyframes draw-bar {
  from { stroke-dashoffset: 600; opacity: 0; }
  to   { stroke-dashoffset: 0;   opacity: 1; }
}

@media (prefers-reduced-motion: reduce) {
  .animate-draw {
    animation: none;
    stroke-dashoffset: 0;
    opacity: 1;
  }
}
</style>
