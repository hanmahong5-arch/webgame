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

// Hexagon center
const hexCx = 265
const hexCy = 120
const hexR  = 44

// WAL log entries (newest on top)
const walEntries = [
  { label: 'WAL[003] Execute', y: 48 },
  { label: 'WAL[002] Plan',    y: 80 },
  { label: 'WAL[001] Init',    y: 112 },
  { label: 'WAL[000] Start',   y: 144 },
]

// Satellite nodes at fixed positions around the hexagon
// (no orbit animation — avoids global SVG ID conflict with animateMotion + mpath)
const satellites = [
  { label: 'Plan',    color: '#E0C8FF', angleDeg: -90 },
  { label: 'Execute', color: '#B08EFF', angleDeg:  30 },
  { label: 'Review',  color: '#C4A8FF', angleDeg: 150 },
]

// Orbit ellipse radii for satellite positions (slightly outside the decorative ring)
const SAT_RX = 104
const SAT_RY = 56

// Direct inline path for animateMotion: no external <defs> ID needed
// Ellipse: center (265,120), rx=90, ry=50
const ORBIT_PATH = 'M 355,120 A 90,50 0 1,1 354.9999,120'

function hexPoints(cx: number, cy: number, r: number): string {
  return Array.from({ length: 6 }, (_, i) => {
    const a = (Math.PI / 3) * i - Math.PI / 6
    return `${cx + r * Math.cos(a)},${cy + r * Math.sin(a)}`
  }).join(' ')
}

function satPos(angleDeg: number) {
  const a = (angleDeg * Math.PI) / 180
  return { x: hexCx + SAT_RX * Math.cos(a), y: hexCy + SAT_RY * Math.sin(a) }
}
</script>

<template>
  <svg
    ref="svgRef"
    viewBox="0 0 520 240"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-label="Kova: WAL-backed persistent Agent Loop with Plan, Execute, Review cycle"
    style="width:100%;height:100%"
  >
    <!-- Background glow -->
    <ellipse v-if="isVisible" :cx="hexCx" :cy="hexCy" rx="70" ry="60" fill="#B08EFF" opacity="0.07" />

    <!-- WAL log stack (left) -->
    <g v-for="(entry, i) in walEntries" :key="entry.label">
      <rect
        x="12" :y="entry.y - 12" width="136" height="24" rx="5"
        fill="#1C1916" stroke="#B08EFF" stroke-width="1" stroke-opacity="0.45"
        :class="isVisible ? 'animate-draw' : ''"
        :style="{ animationDelay: `${i * 100}ms` }"
      />
      <text x="20" :y="entry.y + 4" font-size="9.5" font-family="ui-monospace,monospace" fill="#A89B8B">
        {{ entry.label }}
      </text>
      <!-- WAL → hexagon connector -->
      <line
        x1="150" :y1="entry.y"
        :x2="hexCx - hexR - 2" :y2="hexCy"
        stroke="#B08EFF" stroke-width="0.8" stroke-dasharray="3 3" stroke-opacity="0.35"
        :class="isVisible ? 'animate-draw-line' : ''"
        :style="{ animationDelay: `${350 + i * 80}ms` }"
      />
      <!-- WAL replay particle (inline path — no external ID) -->
      <circle r="2.2" fill="#B08EFF" opacity="0.8">
        <animateMotion
          v-if="isVisible"
          :dur="`${2.8 + i * 0.3}s`"
          repeatCount="indefinite"
          :begin="`${i * 0.4}s`"
          :path="`M150,${entry.y} L${hexCx - hexR - 2},${hexCy}`"
        />
      </circle>
    </g>

    <!-- Decorative orbit ellipse -->
    <ellipse
      v-if="isVisible"
      :cx="hexCx" :cy="hexCy" rx="90" ry="50"
      fill="none" stroke="#B08EFF" stroke-width="0.6" stroke-dasharray="4 4" stroke-opacity="0.2"
    />

    <!-- 3 orbit particles (inline path, staggered begin — no <defs> IDs needed) -->
    <circle
      v-for="(sat, i) in satellites"
      :key="`orb-${i}`"
      r="3.5"
      :fill="sat.color"
      opacity="0.85"
    >
      <animateMotion
        v-if="isVisible"
        dur="8s"
        repeatCount="indefinite"
        :begin="`${(i * 8 / 3).toFixed(2)}s`"
        :path="ORBIT_PATH"
      />
    </circle>

    <!-- Satellite label nodes at fixed positions -->
    <g
      v-for="(sat, i) in satellites"
      :key="`node-${sat.label}`"
      :style="{ opacity: isVisible ? 1 : 0, transition: `opacity 0.4s ${0.7 + i * 0.15}s` }"
    >
      <rect
        :x="satPos(sat.angleDeg).x - 26"
        :y="satPos(sat.angleDeg).y - 12"
        width="52" height="24" rx="12"
        fill="#1C1916" :stroke="sat.color" stroke-width="1.2"
      />
      <text
        :x="satPos(sat.angleDeg).x"
        :y="satPos(sat.angleDeg).y + 4"
        text-anchor="middle"
        font-size="10" font-family="ui-monospace,monospace" :fill="sat.color"
      >{{ sat.label }}</text>
    </g>

    <!-- Center: Agent Loop hexagon (drawn last so it appears on top) -->
    <polygon
      :points="hexPoints(hexCx, hexCy, hexR)"
      fill="#141210" stroke="#B08EFF" stroke-width="2"
      :class="isVisible ? 'animate-draw' : ''"
      style="animation-delay:500ms"
    />
    <polygon
      v-if="isVisible"
      :points="hexPoints(hexCx, hexCy, hexR - 6)"
      fill="none" stroke="#B08EFF" stroke-width="0.5" stroke-opacity="0.3"
    />
    <text :x="hexCx" :y="hexCy - 6"  text-anchor="middle" font-size="11" font-weight="700" font-family="ui-monospace,monospace" fill="#F5F0E8">Agent</text>
    <text :x="hexCx" :y="hexCy + 10" text-anchor="middle" font-size="11" font-weight="700" font-family="ui-monospace,monospace" fill="#B08EFF">Loop</text>
  </svg>
</template>

<style scoped>
.animate-draw {
  stroke-dashoffset: 400;
  stroke-dasharray: 400;
  animation: draw-line 0.85s ease-out forwards;
}

.animate-draw-line {
  stroke-dashoffset: 200;
  stroke-dasharray: 200;
  animation: draw-line 0.6s ease-out forwards;
}

@keyframes draw-line {
  from { stroke-dashoffset: 400; opacity: 0; }
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
