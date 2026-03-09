<script setup lang="ts">
import { VALUES } from '../../data/about'
</script>

<template>
  <section class="py-fib-7 bg-cream-50">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      <h2 class="text-phi-2xl font-hand font-bold text-ink-900 mb-fib-5 text-center reveal-fade-up">
        核心价值
      </h2>
      <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-fib-4">
        <div
          v-for="v in VALUES"
          :key="v.title"
          class="border-sketchy bg-cream-100 p-fib-5 reveal-fade-up"
        >
          <div class="w-12 h-12 border-sketchy bg-cream-50 flex items-center justify-center mb-fib-3">
            <svg class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="v.icon" />
            </svg>
          </div>
          <h3 class="text-phi-lg font-hand font-bold text-ink-900 mb-fib-3">{{ v.title }}</h3>
          <p class="text-ink-500 text-phi-base leading-relaxed">{{ v.desc }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
