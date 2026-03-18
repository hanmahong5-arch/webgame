<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  count?: number
  colors?: string[]
}

const props = withDefaults(defineProps<Props>(), {
  count: 12,
  colors: () => ['#4A9EFF', '#B08EFF', '#7AFF89', '#FFB86C', '#FFE566', '#FF8C69', '#4AFFCB'],
})

const prefersReducedMotion =
  typeof window !== 'undefined' &&
  window.matchMedia('(prefers-reduced-motion: reduce)').matches

const isMobile =
  typeof window !== 'undefined' && window.innerWidth < 768

const particles = computed(() => {
  if (prefersReducedMotion) return []
  const effectiveCount = isMobile ? Math.ceil(props.count / 2) : props.count
  return Array.from({ length: effectiveCount }, (_, i) => {
    const size = 3 + Math.random() * 5
    const left = Math.random() * 100
    const delay = Math.random() * 8
    const duration = 10 + Math.random() * 14
    const drift = -40 + Math.random() * 80
    const color = props.colors[i % props.colors.length]
    return { size, left, delay, duration, drift, color }
  })
})
</script>

<template>
  <div class="particle-field" aria-hidden="true">
    <div
      v-for="(p, i) in particles"
      :key="i"
      class="particle"
      :style="{
        width: p.size + 'px',
        height: p.size + 'px',
        left: p.left + '%',
        bottom: '-10px',
        backgroundColor: p.color,
        animationDelay: p.delay + 's',
        animationDuration: p.duration + 's',
        '--drift': p.drift + 'px',
      }"
    />
  </div>
</template>

<style scoped>
.particle-field {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
  z-index: 0;
}

.particle {
  position: absolute;
  border-radius: 50%;
  opacity: 0;
  will-change: transform, opacity;
  animation: particle-rise linear infinite;
}
</style>
