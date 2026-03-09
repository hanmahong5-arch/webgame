<script setup lang="ts">
import { stats } from '../../data/stats'
</script>

<template>
  <section aria-label="平台统计数据" class="py-fib-7 bg-cream-50 relative overflow-hidden">
    <!-- Decorative elements -->
    <div class="absolute top-8 left-8 doodle-corner opacity-30" aria-hidden="true"></div>
    <div class="absolute bottom-8 right-8 doodle-corner rotate-180 opacity-30" aria-hidden="true"></div>

    <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 reveal-stagger">
        <div
          v-for="stat in stats"
          :key="stat.label"
          data-testid="stat-item"
          class="text-center px-6 py-8 border-sketchy bg-cream-100 hover:shadow-paper-hover transition-all"
        >
          <div
            data-testid="stat-value"
            :class="['text-phi-2xl mb-2 font-bold', stat.color]"
          >
            {{ stat.value }}
          </div>
          <div data-testid="stat-label" class="text-ink-500">
            {{ stat.label }}
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
