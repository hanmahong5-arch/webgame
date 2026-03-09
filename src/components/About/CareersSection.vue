<script setup lang="ts">
</script>

<template>
  <section class="py-fib-7 bg-cream-50 relative overflow-hidden">
    <div class="absolute top-8 left-8 doodle-corner opacity-40" aria-hidden="true"></div>
    <div class="absolute bottom-8 right-8 doodle-corner rotate-180 opacity-40" aria-hidden="true"></div>

    <div class="relative max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
      <h2 class="text-phi-2xl font-hand font-bold text-ink-900 mb-fib-3">加入我们</h2>
      <p class="text-ink-500 mb-fib-4 max-w-xl mx-auto leading-relaxed">
        我们正在寻找对 AI 基础设施充满热情的工程师和产品设计师。
        如果你想和一群务实的人一起，做真正有价值的事，欢迎联系。
      </p>
      <a
        href="mailto:careers@lurus.cn"
        class="btn-hand btn-hand-primary inline-flex items-center gap-2"
      >
        <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
        </svg>
        careers@lurus.cn
      </a>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
