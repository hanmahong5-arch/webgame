<script setup lang="ts">
import { ref } from 'vue'

interface Props {
  question: string
  answer: string
}

defineProps<Props>()

const open = ref(false)
</script>

<template>
  <div class="border-sketchy bg-cream-100">
    <button
      @click="open = !open"
      class="w-full px-6 py-4 flex items-center justify-between text-left"
    >
      <span class="font-medium text-ink-900">{{ question }}</span>
      <svg
        class="w-5 h-5 text-ink-500 transition-transform duration-200 flex-shrink-0 ml-3"
        :class="{ 'rotate-180': open }"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>
    <div v-if="open" class="px-6 pb-4 text-ink-500">
      {{ answer }}
    </div>
  </div>
</template>
