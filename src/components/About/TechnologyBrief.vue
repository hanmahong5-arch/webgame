<script setup lang="ts">
import { TECHNOLOGY_HIGHLIGHTS } from '../../data/about'
</script>

<template>
  <section id="technology" class="py-24 section-dark-raised">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="text-center mb-10 reveal-fade-up">
        <h2 class="text-phi-2xl font-bold text-[var(--color-text-primary)] mb-4">技术实力</h2>
        <p class="text-phi-lg text-[var(--color-text-secondary)] max-w-2xl mx-auto">
          我们用扎实的工程能力，为每一次 AI 调用保驾护航
        </p>
      </div>
      <div class="grid md:grid-cols-3 gap-4 reveal-fade-up">
        <div
          v-for="item in TECHNOLOGY_HIGHLIGHTS"
          :key="item.title"
          class="card-dark p-8 transition-all"
        >
          <div class="w-12 h-12 rounded-lg bg-[var(--color-surface-overlay)] flex items-center justify-center mb-4">
            <svg class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="item.icon" />
            </svg>
          </div>
          <h3 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-4">{{ item.title }}</h3>
          <p class="text-[var(--color-text-secondary)] text-sm leading-relaxed">{{ item.desc }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
