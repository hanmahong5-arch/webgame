<script setup lang="ts">
import { TECHNOLOGY_HIGHLIGHTS } from '../../data/about'
</script>

<template>
  <section class="py-fib-7 bg-cream-100">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="text-center mb-fib-5 reveal-fade-up">
        <h2 class="text-phi-2xl font-hand font-bold text-ink-900 mb-fib-3">技术实力</h2>
        <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto">
          我们用扎实的工程能力，为每一次 AI 调用保驾护航
        </p>
      </div>
      <div class="grid md:grid-cols-3 gap-fib-4 reveal-fade-up">
        <div
          v-for="item in TECHNOLOGY_HIGHLIGHTS"
          :key="item.title"
          class="border-sketchy bg-cream-50 p-fib-5 hover:shadow-paper-hover transition-all"
        >
          <div class="w-12 h-12 border-sketchy bg-cream-100 flex items-center justify-center mb-fib-4">
            <svg class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="item.icon" />
            </svg>
          </div>
          <h3 class="text-phi-lg font-hand font-bold text-ink-900 mb-fib-3">{{ item.title }}</h3>
          <p class="text-ink-500 text-sm leading-relaxed">{{ item.desc }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
