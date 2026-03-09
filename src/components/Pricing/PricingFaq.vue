<script setup lang="ts">
import FaqItem from './FaqItem.vue'
import type { FaqData } from '../../config/pricing'

defineProps<{
  faqs: FaqData[]
}>()
</script>

<template>
  <section class="py-fib-6 bg-cream-50">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
      <h2 class="text-phi-2xl font-hand font-bold text-ink-900 mb-fib-5 text-center">
        常见问题
      </h2>
      <div class="space-y-fib-3">
        <FaqItem
          v-for="faq in faqs"
          :key="faq.question"
          :question="faq.question"
          :answer="faq.answer"
        />
      </div>
    </div>
  </section>
</template>
