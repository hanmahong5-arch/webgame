<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

interface Milestone {
  year: string
  event: string
}

defineProps<{
  milestones: Milestone[]
}>()

const timelineRef = ref<HTMLElement | null>(null)
const isVisible = ref(false)
let observer: IntersectionObserver | null = null

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
    { threshold: 0.15, rootMargin: '0px 0px -50px 0px' }
  )
  if (timelineRef.value) observer.observe(timelineRef.value)
})

onUnmounted(() => {
  observer?.disconnect()
  observer = null
})
</script>

<template>
  <section id="timeline" class="py-20 section-dark">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
      <h2 class="text-phi-2xl font-bold text-[var(--color-text-primary)] mb-10 text-center reveal-fade-up">
        发展历程
      </h2>
      <div
        ref="timelineRef"
        class="relative"
        :class="{ 'is-visible': isVisible }"
        data-testid="animated-timeline"
      >
        <!-- Vertical draw line -->
        <svg
          class="absolute left-[6.5rem] top-0 h-full w-4"
          aria-hidden="true"
        >
          <line
            x1="8"
            y1="0"
            x2="8"
            y2="100%"
            stroke="var(--color-ochre)"
            stroke-width="2"
            stroke-dasharray="4 3"
            class="timeline-line"
          />
        </svg>

        <div class="space-y-fib-4">
          <div
            v-for="(m, idx) in milestones"
            :key="idx"
            class="flex gap-5 items-start timeline-item"
            :style="{ transitionDelay: `${idx * 150}ms` }"
          >
            <div class="flex-shrink-0 w-24 text-right">
              <span class="font-bold text-ochre text-phi-lg">{{ m.year }}</span>
            </div>
            <div class="flex-shrink-0 w-3 h-3 mt-2 rounded-full bg-ochre border-2 border-[var(--color-surface-base)] ring-2 ring-ochre/30 relative z-10 timeline-dot"></div>
            <p class="text-[var(--color-text-secondary)] flex-1">{{ m.event }}</p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

.timeline-line {
  stroke-dashoffset: 600;
  transition: stroke-dashoffset 1.5s ease-out;
}

.is-visible .timeline-line {
  stroke-dashoffset: 0;
}

.timeline-item {
  opacity: 0;
  transform: translateY(16px);
  transition: opacity 0.5s ease-out, transform 0.5s ease-out;
}

.is-visible .timeline-item {
  opacity: 1;
  transform: translateY(0);
}

.timeline-dot {
  box-shadow: 0 0 0 0 rgba(201, 162, 39, 0);
  transition: box-shadow 0.4s ease;
}

.is-visible .timeline-dot {
  animation: pulse-dot 2s ease-in-out 1;
}

@keyframes pulse-dot {
  0%, 100% { box-shadow: 0 0 0 0 rgba(201, 162, 39, 0); }
  50% { box-shadow: 0 0 0 8px rgba(201, 162, 39, 0.25); }
}

@media (prefers-reduced-motion: reduce) {
  .timeline-line {
    stroke-dashoffset: 0;
    transition: none;
  }
  .timeline-item {
    opacity: 1;
    transform: none;
    transition: none;
  }
  .timeline-dot {
    animation: none;
  }
}
</style>
