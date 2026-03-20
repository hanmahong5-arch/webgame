<script setup lang="ts">
import { VALUES } from '../../data/about'
</script>

<template>
  <section id="values" class="py-24 section-dark">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      <h2 class="text-phi-2xl font-bold text-[var(--color-text-primary)] mb-10 text-center reveal-fade-up">
        核心价值
      </h2>
      <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div
          v-for="v in VALUES"
          :key="v.title"
          class="card-dark p-8 reveal-fade-up"
        >
          <div class="w-12 h-12 rounded-lg bg-[var(--color-surface-overlay)] flex items-center justify-center mb-4">
            <svg class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="v.icon" />
            </svg>
          </div>
          <h3 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-4">{{ v.title }}</h3>
          <p class="text-[var(--color-text-secondary)] text-phi-base leading-relaxed">{{ v.desc }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
