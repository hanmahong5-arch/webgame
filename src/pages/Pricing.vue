<script setup lang="ts">
import { ref, computed } from 'vue'
import type { BillingCycle, AudienceTierCode } from '../types/pricing'
import {
  AUDIENCE_TIERS,
  AUDIENCE_PRODUCTS,
  COMPARISON_FEATURES,
  PRICING_FAQ,
} from '../config/pricing'
import BillingToggle from '../components/Pricing/BillingToggle.vue'
import AudienceTierSelector from '../components/Pricing/AudienceTierSelector.vue'
import ProductPricingGrid from '../components/Pricing/ProductPricingGrid.vue'
import ComparisonTable from '../components/Pricing/ComparisonTable.vue'
import PaymentMethods from '../components/Pricing/PaymentMethods.vue'
import PricingFaq from '../components/Pricing/PricingFaq.vue'
import EnterpriseCTA from '../components/Pricing/EnterpriseCTA.vue'

const billingCycle = ref<BillingCycle>('monthly')
const selectedAudience = ref<AudienceTierCode>('personal')

const currentProducts = computed(() => AUDIENCE_PRODUCTS[selectedAudience.value])
</script>

<template>
  <div>
    <!-- Page Header -->
    <section class="py-fib-7 bg-cream-100 relative overflow-hidden">
      <div class="absolute inset-0 opacity-[0.02]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>
      <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h1 class="text-phi-3xl sm:text-phi-4xl font-hand font-bold text-ink-900 mb-fib-3">
          定价方案
        </h1>
        <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto mb-fib-5">
          选择适合你的方案，从免费开始
        </p>

        <!-- Billing Toggle -->
        <BillingToggle v-model="billingCycle" />
      </div>
    </section>

    <!-- Audience Tier Selector -->
    <section class="py-fib-6 bg-cream-50">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-phi-xl font-hand font-bold text-ink-900 mb-fib-4 text-center">
          你是哪类用户？
        </h2>
        <AudienceTierSelector
          v-model="selectedAudience"
          :tiers="AUDIENCE_TIERS"
        />
      </div>
    </section>

    <!-- Product Pricing Grid -->
    <section class="py-fib-6 bg-cream-100">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <ProductPricingGrid
          :products="currentProducts"
          :billing-cycle="billingCycle"
        />
      </div>
    </section>

    <!-- Top-up CTA -->
    <section class="py-fib-5 bg-cream-50">
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <div class="border-sketchy bg-cream-100 p-fib-5">
          <h3 class="text-phi-xl font-hand font-bold text-ink-900 mb-fib-3">需要更多 Token？随时充值</h3>
          <p class="text-ink-500 mb-fib-4">套餐配额不够用？可以在控制台直接充值，按需补充额度，即充即用。</p>
          <a
            href="https://api.lurus.cn/console/topup"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-hand btn-hand-primary inline-flex items-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            前往充值
          </a>
        </div>
      </div>
    </section>

    <!-- Comparison Table -->
    <section class="py-fib-6 bg-cream-100">
      <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-phi-2xl font-hand font-bold text-ink-900 mb-fib-5 text-center">
          功能对比
        </h2>
        <ComparisonTable :features="COMPARISON_FEATURES" />
      </div>
    </section>

    <!-- Payment Methods -->
    <PaymentMethods />

    <!-- FAQ -->
    <PricingFaq :faqs="PRICING_FAQ" />

    <!-- Enterprise CTA -->
    <EnterpriseCTA />
  </div>
</template>
