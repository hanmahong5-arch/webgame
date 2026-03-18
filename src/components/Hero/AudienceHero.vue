<script setup lang="ts">
import { useAuth } from '../../composables/useAuth'
import { useTracking } from '../../composables/useTracking'

const { login } = useAuth()
const { track } = useTracking()

const audiences = [
  {
    id: 'explorers',
    title: '探索者',
    subtitle: '用 AI 武装你的桌面',
    description: '桌面 AI 助手、量化交易、工具管理 — 个人效率的无限延伸',
    color: '#5C7A8B',
    link: '/for-explorers',
    iconPath: 'M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z',
  },
  {
    id: 'entrepreneurs',
    title: '创业者',
    subtitle: '用 AI 加速你的业务',
    description: 'LLM 网关、企业邮件、团队管理 — 从第一天开始拥有 AI 基础设施',
    color: '#6B8BA4',
    link: '/for-entrepreneurs',
    iconPath: 'M13 10V3L4 14h7v7l9-11h-7z',
  },
  {
    id: 'builders',
    title: '构建者',
    subtitle: '用 AI 构建你的平台',
    description: '身份认证、记忆层、白标网关 — 为你的产品注入 AI 能力',
    color: '#8B6B7D',
    link: '/for-builders',
    iconPath: 'M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z',
  },
]

const floatingDots = [
  { id: 1, left: '12%', top: '18%', delay: '0s', duration: '6s' },
  { id: 2, left: '75%', top: '30%', delay: '1.5s', duration: '5s' },
  { id: 3, left: '35%', top: '75%', delay: '3s', duration: '7s' },
  { id: 4, left: '88%', top: '60%', delay: '4s', duration: '5.5s' },
]
</script>

<template>
  <section id="audience-hero" aria-label="Hero" class="relative min-h-golden-vh overflow-hidden bg-cream-50">
    <!-- Paper texture background -->
    <div class="absolute inset-0 pointer-events-none">
      <div class="absolute inset-0 opacity-[0.03]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>
      <div class="doodle-corner top-12 left-12"></div>
      <div class="doodle-corner top-12 right-12 -scale-x-100"></div>
      <div class="doodle-corner bottom-24 left-12 -scale-y-100"></div>
      <div class="doodle-corner bottom-24 right-12 scale-[-1]"></div>
      <div
        v-for="dot in floatingDots"
        :key="dot.id"
        class="absolute w-3 h-3 rounded-full bg-ochre/20 animate-float"
        :style="{ left: dot.left, top: dot.top, animationDelay: dot.delay, animationDuration: dot.duration }"
      ></div>
    </div>

    <!-- Main content -->
    <div class="relative z-10 max-w-[1200px] mx-auto px-4 sm:px-6 lg:px-8 py-fib-7 pt-28">
      <!-- Logo badge -->
      <div class="text-center mb-fib-5 reveal-fade-up">
        <div class="inline-flex items-center gap-3 px-6 py-3 border-sketchy bg-cream-100 mb-fib-5 hover:shadow-paper-hover transition-all">
          <div class="w-10 h-10 rounded-lg bg-ochre flex items-center justify-center border-2 border-ink-300">
            <span class="text-cream-50 font-hand font-bold text-xl">L</span>
          </div>
          <span class="text-ink-700 font-medium">Lurus Technology</span>
          <span class="w-2 h-2 rounded-full bg-product-lucrum animate-pulse"></span>
        </div>
      </div>

      <!-- Main headline -->
      <div class="text-center mb-fib-6 reveal-fade-up">
        <h1 class="text-phi-2xl md:text-phi-3xl lg:text-[68px] text-ink-900 mb-fib-4 leading-tight font-bold">
          <span class="block mb-2">AI 的力量</span>
          <span class="text-gradient-ochre font-hand">从你开始</span>
        </h1>
        <p class="text-phi-lg md:text-phi-xl text-ink-500 max-w-2xl mx-auto leading-relaxed">
          个人效率 · 企业智能 · 平台基座 — 为每一种可能提供基础设施
        </p>
      </div>

      <!-- CTA buttons -->
      <div class="flex flex-col sm:flex-row gap-fib-4 justify-center mb-fib-7 reveal-fade-up">
        <button
          class="btn-hand btn-hand-primary inline-flex items-center justify-center gap-2 text-lg px-10 py-4"
          @click="track('cta_click', { label: 'hero_register' }); login({ prompt: 'create' })"
        >
          免费开始
        </button>
        <a
          href="https://docs.lurus.cn"
          target="_blank"
          rel="noopener noreferrer"
          class="btn-hand inline-flex items-center justify-center gap-2 text-lg px-10 py-4"
          @click="track('cta_click', { label: 'hero_docs' })"
        >
          查看文档
        </a>
      </div>

      <!-- Three audience cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-fib-4 reveal-fade-up">
        <router-link
          v-for="audience in audiences"
          :key="audience.id"
          :to="audience.link"
          class="audience-card group border-sketchy bg-cream-100 p-fib-5 hover:shadow-paper-hover transition-all"
        >
          <div class="flex items-center gap-3 mb-fib-3">
            <div
              class="w-10 h-10 rounded-lg flex items-center justify-center border-2 border-ink-200 group-hover:border-ink-300 transition-colors"
              :style="{ backgroundColor: audience.color + '20' }"
            >
              <svg
                class="w-5 h-5"
                :style="{ color: audience.color }"
                fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="audience.iconPath" />
              </svg>
            </div>
            <div>
              <h2 class="text-lg font-bold text-ink-900 font-hand">{{ audience.title }}</h2>
              <p class="text-sm text-ink-500">{{ audience.subtitle }}</p>
            </div>
          </div>
          <p class="text-sm text-ink-400 leading-relaxed mb-fib-3">{{ audience.description }}</p>
          <span class="text-sm text-ochre font-medium group-hover:underline">
            了解更多 →
          </span>
        </router-link>
      </div>
    </div>

    <!-- Scroll Indicator -->
    <div class="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
      <svg class="w-6 h-6 text-ink-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
      </svg>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

.audience-card {
  cursor: pointer;
}
</style>
