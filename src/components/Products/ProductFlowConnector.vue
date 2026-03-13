<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

defineProps<{
  fromColor: string
  toColor: string
}>()

const connectorRef = ref<SVGSVGElement | null>(null)
const isVisible = ref(false)
let observer: IntersectionObserver | null = null

onMounted(() => {
  if (!connectorRef.value) return
  observer = new IntersectionObserver(
    ([entry]) => { if (entry.isIntersecting) isVisible.value = true },
    { threshold: 0.5 }
  )
  observer.observe(connectorRef.value)
})

onUnmounted(() => { observer?.disconnect() })
</script>

<template>
  <div class="flex justify-center py-fib-3">
    <svg
      ref="connectorRef"
      class="w-8 h-16"
      viewBox="0 0 32 64"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
    >
      <!-- Dashed vertical path -->
      <path
        d="M16 4 C16 20, 16 44, 16 60"
        :stroke="fromColor"
        stroke-width="1.5"
        stroke-dasharray="4 4"
        stroke-linecap="round"
        :class="isVisible ? 'flow-line' : ''"
      />

      <!-- Flowing particle -->
      <circle
        r="3"
        :fill="toColor"
        opacity="0.8"
      >
        <animateMotion
          v-if="isVisible"
          dur="1.8s"
          repeatCount="indefinite"
          path="M16,4 C16,20 16,44 16,60"
        />
      </circle>

      <!-- Arrow tip -->
      <polygon
        :points="`12,56 16,64 20,56`"
        :fill="toColor"
        opacity="0.6"
      />
    </svg>
  </div>
</template>

<style scoped>
.flow-line {
  stroke-dashoffset: 80;
  animation: flow-dash 1s ease-out forwards;
}

@keyframes flow-dash {
  from { stroke-dashoffset: 80; opacity: 0; }
  to { stroke-dashoffset: 0; opacity: 1; }
}

@media (prefers-reduced-motion: reduce) {
  .flow-line {
    animation: none;
    stroke-dashoffset: 0;
    opacity: 1;
  }
}
</style>
