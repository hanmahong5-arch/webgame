<script setup lang="ts">
import EcosystemGraph from './EcosystemGraph.vue'

const advantages = [
  {
    title: '企业级可靠性',
    desc: '多节点冗余部署，自动故障转移，99.9% SLA 可用性保障',
    icon: 'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z',
  },
  {
    title: '统一接入',
    desc: '一个 API 接入 50+ AI 模型，统一格式，无缝切换',
    icon: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
  },
  {
    title: '全面可观测',
    desc: '实时监控、日志追踪、用量分析，运行状态一目了然',
    icon: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z',
  },
  {
    title: '安全优先',
    desc: '全链路 TLS 加密、API Key 管理、细粒度访问控制',
    icon: 'M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z',
  },
]
</script>

<template>
  <section id="advantages" class="py-20 section-dark-raised" data-testid="advantages-section">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      <h2 class="text-phi-2xl font-bold text-[var(--color-text-primary)] mb-10 text-center reveal-fade-up">
        我们的优势
      </h2>
      <div class="grid md:grid-cols-2 gap-6 mb-10">
        <div
          v-for="item in advantages"
          :key="item.title"
          class="card-dark p-8 hover-breathe reveal-fade-up"
        >
          <div class="w-12 h-12 rounded-lg bg-[var(--color-surface-overlay)] flex items-center justify-center mb-4">
            <svg class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="item.icon" />
            </svg>
          </div>
          <h3 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-4">{{ item.title }}</h3>
          <p class="text-[var(--color-text-secondary)] text-phi-base leading-relaxed">{{ item.desc }}</p>
        </div>
      </div>

      <!-- Ecosystem Graph -->
      <div class="reveal-fade-up">
        <h3 class="text-phi-lg font-bold text-[var(--color-text-primary)] mb-4 text-center">
          产品生态
        </h3>
        <EcosystemGraph />
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

.hover-breathe {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.hover-breathe:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
}
</style>
