<script setup lang="ts">
import { ABOUT_STATS } from '../../data/about'
</script>

<template>
  <section id="stats" class="py-24 section-dark-raised">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 reveal-stagger">
        <div
          v-for="stat in ABOUT_STATS"
          :key="stat.label"
          class="text-center px-6 py-8 card-dark"
        >
          <div class="text-phi-2xl font-bold text-ochre mb-2">
            {{ stat.value }}
          </div>
          <div class="text-[var(--color-text-secondary)] text-sm">{{ stat.label }}</div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
