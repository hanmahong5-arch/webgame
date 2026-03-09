<script setup lang="ts">
import { useAuth } from '../../composables/useAuth'
import { useTracking } from '../../composables/useTracking'

const { login } = useAuth()
const { track } = useTracking()

const paths = [
  {
    audience: '个人用户',
    action: '下载 ACEST Desktop',
    description: '开始 AI 桌面体验',
    href: '/download',
    external: false,
    iconPath: 'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z',
    color: '#5C7A8B',
  },
  {
    audience: '开发者',
    action: '注册 API Key',
    description: '3 分钟接入 50+ 模型',
    href: 'https://api.lurus.cn',
    external: true,
    iconPath: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
    color: '#6B8BA4',
  },
  {
    audience: '企业/平台',
    action: '联系我们',
    description: '获取定制方案',
    href: 'mailto:support@lurus.cn',
    external: true,
    iconPath: 'M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
    color: '#8B6B7D',
  },
]
</script>

<template>
  <section class="py-fib-7 bg-cream-100" aria-label="Getting Started">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="text-center mb-fib-5 reveal-fade-up">
        <h2 class="text-phi-2xl sm:text-phi-3xl text-ink-900 mb-fib-3 font-semibold">选择你的起点</h2>
        <p class="text-phi-lg text-ink-500">无论你是探索者、创业者还是构建者，都有适合你的方案</p>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-3 gap-fib-4 mb-fib-5 reveal-fade-up">
        <a
          v-for="path in paths"
          :key="path.audience"
          :href="path.href"
          :target="path.external ? '_blank' : undefined"
          :rel="path.external ? 'noopener noreferrer' : undefined"
          class="group border-sketchy bg-cream-50 p-fib-5 text-center hover:shadow-paper-hover transition-all"
          @click="track('cta_click', { label: `start_${path.audience}` })"
        >
          <div
            class="w-12 h-12 rounded-lg flex items-center justify-center border-2 border-ink-200 mx-auto mb-fib-3 group-hover:border-ink-300 transition-colors"
            :style="{ backgroundColor: path.color + '20' }"
          >
            <svg
              class="w-6 h-6"
              :style="{ color: path.color }"
              fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="path.iconPath" />
            </svg>
          </div>
          <p class="text-xs text-ink-300 mb-1">{{ path.audience }}</p>
          <p class="text-ink-900 font-bold mb-1">{{ path.action }}</p>
          <p class="text-xs text-ink-400">{{ path.description }}</p>
        </a>
      </div>

      <!-- Register CTA -->
      <div class="text-center reveal-fade-up">
        <button
          class="btn-hand btn-hand-primary inline-flex items-center justify-center gap-2 text-lg px-10 py-4"
          @click="track('cta_click', { label: 'final_register' }); login({ prompt: 'create' })"
        >
          免费注册
        </button>
        <div class="mt-fib-3 flex flex-wrap items-center justify-center gap-fib-4 text-ink-400 text-sm">
          <span class="flex items-center gap-1.5">
            <svg class="w-4 h-4 text-product-gushen" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
            数据安全加密
          </span>
          <span class="flex items-center gap-1.5">
            <svg class="w-4 h-4 text-product-gushen" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>
            无需信用卡
          </span>
          <span class="flex items-center gap-1.5">
            <svg class="w-4 h-4 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
            即时开通
          </span>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
