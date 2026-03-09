<script setup lang="ts">
import { ABOUT_STATS } from '../../data/about'
</script>

<template>
  <section class="py-fib-7 bg-cream-100">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-fib-4 reveal-stagger">
        <div
          v-for="stat in ABOUT_STATS"
          :key="stat.label"
          class="text-center px-fib-4 py-fib-5 border-sketchy bg-cream-50 hover:shadow-paper-hover transition-all"
        >
          <div class="text-phi-2xl font-hand font-bold text-ochre mb-fib-2">
            {{ stat.value }}
          </div>
          <div class="text-ink-500 text-sm">{{ stat.label }}</div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
