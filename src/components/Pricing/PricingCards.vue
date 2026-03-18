<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  DEFAULT_PRICING_PLANS,
  PRICING_API_ENDPOINT,
  SUPPORT_EMAIL,
  type PricingPlan,
} from '../../config/pricing'

const plans = ref<PricingPlan[]>(DEFAULT_PRICING_PLANS)
const loading = ref(true)
const fetchError = ref(false)

onMounted(async () => {
  try {
    const res = await fetch(PRICING_API_ENDPOINT)
    if (res.ok) {
      const data = await res.json()
      if (data.success && Array.isArray(data.data) && data.data.length > 0) {
        plans.value = data.data
      }
    }
  } catch {
    fetchError.value = true
  } finally {
    loading.value = false
  }
})

const handleSubscribe = (planCode: string) => {
  window.location.href = `https://identity.lurus.cn?action=subscribe&plan=${planCode}`
}
</script>

<template>
  <section id="pricing" class="py-fib-7 bg-cream-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Section Header -->
      <div class="text-center mb-fib-6">
        <h2 class="text-phi-2xl sm:text-phi-3xl font-hand text-ink-900 mb-fib-3">
          简单透明的定价
        </h2>
        <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto">
          按需选择适合你的套餐，所有套餐均支持 Claude / GPT / Gemini 等主流模型
        </p>
      </div>

      <!-- Skeleton Loading -->
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-fib-4">
        <div
          v-for="i in 4"
          :key="i"
          class="border-sketchy bg-cream-100 p-6 animate-pulse"
        >
          <div class="h-6 bg-cream-200 rounded w-16 mb-4"></div>
          <div class="h-10 bg-cream-200 rounded w-24 mb-6"></div>
          <div class="space-y-3">
            <div class="h-4 bg-cream-200 rounded w-full"></div>
            <div class="h-4 bg-cream-200 rounded w-3/4"></div>
            <div class="h-4 bg-cream-200 rounded w-5/6"></div>
          </div>
          <div class="h-12 bg-cream-200 rounded mt-6"></div>
        </div>
      </div>

      <!-- Pricing Grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-fib-4">
        <div
          v-for="plan in plans"
          :key="plan.code"
          class="relative p-6 transition-all duration-300"
          :class="[
            plan.popular
              ? 'border-sketchy bg-cream-100 shadow-paper ring-2 ring-ochre'
              : 'border-sketchy bg-cream-50 hover:bg-cream-100'
          ]"
        >
          <!-- Popular Badge -->
          <div
            v-if="plan.popular"
            class="absolute -top-3 left-1/2 -translate-x-1/2 px-4 py-1 bg-ochre text-cream-50 text-sm font-hand font-bold border-sketchy"
          >
            最受欢迎
          </div>

          <!-- Plan Name -->
          <h3 class="text-phi-xl font-hand font-bold text-ink-900 mb-1">{{ plan.name }}</h3>
          <p class="text-ink-400 text-sm mb-fib-4">{{ plan.period }} 有效期</p>

          <!-- Price -->
          <div class="mb-fib-4">
            <span class="text-phi-2xl font-bold text-ink-900">¥{{ plan.price }}</span>
            <span class="text-ink-400 ml-1">/ {{ plan.period }}</span>
          </div>

          <!-- Quota Info -->
          <div class="space-y-2 mb-fib-4 p-3 border-sketchy-light bg-cream-100">
            <div class="flex justify-between text-sm">
              <span class="text-ink-400">日配额</span>
              <span class="text-ink-900 font-medium">{{ plan.dailyQuota }} Token</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-ink-400">总配额</span>
              <span class="text-ink-900 font-medium">{{ plan.totalQuota }} Token</span>
            </div>
          </div>

          <!-- Features -->
          <ul class="space-y-2 mb-fib-4">
            <li
              v-for="(feature, idx) in plan.features"
              :key="idx"
              class="flex items-start gap-2 text-sm text-ink-500"
            >
              <svg class="w-4 h-4 text-product-lucrum flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
              </svg>
              <span>{{ feature }}</span>
            </li>
          </ul>

          <!-- CTA Button -->
          <button
            @click="handleSubscribe(plan.code)"
            class="w-full py-3 px-4 font-hand font-bold text-lg transition-all duration-200"
            :class="[
              plan.popular
                ? 'btn-hand btn-hand-primary'
                : 'btn-hand'
            ]"
          >
            立即订阅
          </button>
        </div>
      </div>

      <!-- Help Link -->
      <div class="text-center mt-fib-5">
        <p class="text-ink-400">
          有疑问？
          <a :href="`mailto:${SUPPORT_EMAIL}`" class="text-ochre hover:underline font-medium">联系客服</a>
        </p>
      </div>
    </div>
  </section>
</template>
