<script setup lang="ts">
import type { AudienceTier, AudienceTierCode } from '../../types/pricing'

defineProps<{
  tiers: AudienceTier[]
  modelValue: AudienceTierCode
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: AudienceTierCode): void
}>()
</script>

<template>
  <div class="grid grid-cols-1 sm:grid-cols-3 gap-fib-4">
    <button
      v-for="tier in tiers"
      :key="tier.code"
      class="border-sketchy p-fib-5 text-center transition-all hover:shadow-paper-hover cursor-pointer"
      :class="[
        modelValue === tier.code
          ? 'bg-cream-200 border-ochre shadow-paper'
          : 'bg-cream-100',
        tier.highlight ? 'ring-2 ring-ochre/30' : ''
      ]"
      @click="emit('update:modelValue', tier.code)"
    >
      <div class="text-2xl mb-fib-2">{{ tier.icon }}</div>
      <p class="text-ink-900 font-bold font-hand text-phi-lg mb-1">{{ tier.name }}</p>
      <p class="text-xs text-ink-400">{{ tier.tagline }}</p>
    </button>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
