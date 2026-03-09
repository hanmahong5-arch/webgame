<script setup lang="ts">
</script>

<template>
  <section class="py-fib-6 bg-cream-100 relative overflow-hidden">
    <div class="absolute top-8 left-8 doodle-corner opacity-40" aria-hidden="true"></div>
    <div class="absolute bottom-8 right-8 doodle-corner rotate-180 opacity-40" aria-hidden="true"></div>
    <div class="relative max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
      <h2 class="text-phi-2xl font-hand font-bold text-ink-900 mb-fib-3">企业套餐？联系我们</h2>
      <p class="text-ink-500 mb-fib-4 max-w-xl mx-auto">
        需要大额配额、专属模型部署、定制 SLA 或私有化部署方案？我们的商务团队随时为您服务。
      </p>
      <a
        href="mailto:enterprise@lurus.cn"
        class="btn-hand btn-hand-primary inline-flex items-center gap-2"
      >
        <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
        </svg>
        enterprise@lurus.cn
      </a>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
