<script setup lang="ts">
import type { BillingCycle } from '../../types/pricing'

const props = defineProps<{
  modelValue: BillingCycle
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: BillingCycle): void
}>()

const toggle = () => {
  emit('update:modelValue', props.modelValue === 'monthly' ? 'yearly' : 'monthly')
}
</script>

<template>
  <div class="flex items-center justify-center gap-fib-3">
    <span
      class="text-sm font-medium transition-colors"
      :class="modelValue === 'monthly' ? 'text-ink-900' : 'text-ink-300'"
    >
      月付
    </span>

    <button
      @click="toggle"
      class="relative w-14 h-7 border-sketchy transition-colors"
      :class="modelValue === 'yearly' ? 'bg-ochre/20' : 'bg-cream-200'"
      role="switch"
      :aria-checked="modelValue === 'yearly'"
      aria-label="切换计费周期"
    >
      <span
        class="absolute top-0.5 left-0.5 w-6 h-6 bg-ochre rounded-full transition-transform shadow-sm"
        :class="modelValue === 'yearly' ? 'translate-x-7' : 'translate-x-0'"
      ></span>
    </button>

    <span
      class="text-sm font-medium transition-colors"
      :class="modelValue === 'yearly' ? 'text-ink-900' : 'text-ink-300'"
    >
      年付
    </span>

    <span
      v-if="modelValue === 'yearly'"
      class="text-xs font-hand font-bold text-ochre bg-ochre/10 px-2 py-0.5 border-sketchy"
    >
      省 20%
    </span>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
