<script setup lang="ts">
import type { ProductPricing, BillingCycle } from '../../types/pricing'

defineProps<{
  product: ProductPricing
  billingCycle: BillingCycle
}>()

const formatPrice = (price: number | null): string => {
  if (price === null) return '定制'
  if (price === 0) return '免费'
  return `¥${price}`
}
</script>

<template>
  <div
    class="border-sketchy p-fib-5 transition-all hover:shadow-paper-hover flex flex-col"
    :class="[
      product.status === 'coming_soon'
        ? 'border-dashed border-ink-200 bg-cream-50/50'
        : product.popular
          ? 'bg-cream-200 border-ochre'
          : 'bg-cream-100'
    ]"
  >
    <!-- Coming soon badge -->
    <div v-if="product.status === 'coming_soon'" class="mb-fib-3">
      <span class="text-xs font-hand font-bold text-ink-300 bg-cream-200 px-2 py-0.5 border-sketchy">
        即将推出
      </span>
    </div>

    <!-- Popular badge -->
    <div v-if="product.popular && product.status !== 'coming_soon'" class="mb-fib-3">
      <span class="text-xs font-hand font-bold text-ochre bg-ochre/10 px-2 py-0.5 border-sketchy">
        推荐
      </span>
    </div>

    <!-- Product name -->
    <h3 class="text-phi-lg font-hand font-bold text-ink-900 mb-fib-2">{{ product.name }}</h3>
    <p class="text-sm text-ink-400 mb-fib-4">{{ product.description }}</p>

    <!-- Price -->
    <div class="mb-fib-4">
      <span class="text-phi-2xl font-hand font-bold text-ink-900">
        {{ formatPrice(billingCycle === 'yearly' ? product.yearlyPrice : product.monthlyPrice) }}
      </span>
      <span v-if="product.monthlyPrice !== null && product.monthlyPrice > 0" class="text-sm text-ink-400">
        /{{ product.unit }}
      </span>
    </div>

    <!-- Features -->
    <ul class="space-y-2 mt-auto">
      <li
        v-for="feature in product.features"
        :key="feature"
        class="flex items-start gap-2 text-sm"
        :class="product.status === 'coming_soon' ? 'text-ink-300' : 'text-ink-500'"
      >
        <svg class="w-4 h-4 mt-0.5 flex-shrink-0 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
        </svg>
        <span>{{ feature }}</span>
      </li>
    </ul>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
