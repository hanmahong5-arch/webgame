<script setup lang="ts">
import type { ProductPricing, BillingCycle } from '../../types/pricing'
import ProductPricingCard from './ProductPricingCard.vue'

defineProps<{
  products: ProductPricing[]
  billingCycle: BillingCycle
}>()
</script>

<template>
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-fib-4">
    <ProductPricingCard
      v-for="product in products"
      :key="product.id"
      :product="product"
      :billing-cycle="billingCycle"
    />
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
