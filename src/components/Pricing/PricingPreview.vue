<script setup lang="ts">
const tiers = [
  {
    name: '个人版',
    price: '¥0 起',
    desc: '免费体验核心功能',
    color: '#5C7A8B',
  },
  {
    name: '团队版',
    price: '¥59.9/月 起',
    desc: '团队协作与用量管理',
    color: '#6B8BA4',
    highlight: true,
  },
  {
    name: '平台版',
    price: '定制',
    desc: '私有化部署与 OEM 方案',
    color: '#8B6B7D',
  },
]
</script>

<template>
  <section class="section-dark py-20" aria-label="Pricing Preview">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="text-center mb-10 reveal-fade-up">
        <h2 class="text-phi-2xl sm:text-phi-3xl text-[var(--color-text-primary)] mb-5 font-semibold">透明定价，按需付费</h2>
        <p class="text-phi-lg text-[var(--color-text-secondary)]">从免费开始，随业务增长升级</p>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-3 gap-5 mb-10 reveal-fade-up">
        <div
          v-for="tier in tiers"
          :key="tier.name"
          class="border border-[var(--color-surface-border)] rounded-xl p-8 text-center transition-all hover:border-[var(--color-ochre)]"
          :class="tier.highlight ? 'bg-[var(--color-surface-raised)] border-[var(--color-ochre)]' : 'bg-[var(--color-surface-overlay)]'"
        >
          <p class="text-sm text-[var(--color-text-muted)] mb-2">{{ tier.name }}</p>
          <p class="text-phi-xl font-bold text-[var(--color-text-primary)] mb-2">{{ tier.price }}</p>
          <p class="text-xs text-[var(--color-text-muted)]">{{ tier.desc }}</p>
        </div>
      </div>

      <div class="text-center reveal-fade-up">
        <router-link to="/pricing" class="text-[var(--color-ochre)] hover:underline font-medium text-sm">
          查看完整定价方案 →
        </router-link>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
