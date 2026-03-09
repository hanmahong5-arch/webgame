<script setup lang="ts">
import { useAuth } from '../../composables/useAuth'
import { useTracking } from '../../composables/useTracking'

const { login } = useAuth()
const { track } = useTracking()

const painPoints = [
  {
    question: '每天在 5 个 AI 工具之间切来切去？',
    answer: '一个面板统一管理',
    color: '#C67B5C',
    icon: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
  },
  {
    question: '跟 AI 聊完就忘，下次又要从头来？',
    answer: '让 AI 记住你',
    color: '#8B7A5C',
    icon: 'M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4',
  },
  {
    question: '每个 AI 都要单独充值、单独管理？',
    answer: '一个账户接入 50+ 模型',
    color: '#6B8BA4',
    icon: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
  },
]
</script>

<template>
  <section class="py-fib-8 bg-cream-100 relative overflow-hidden" aria-label="Hero">
    <!-- Background texture -->
    <div class="absolute inset-0 opacity-[0.02]" aria-hidden="true" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>

    <!-- Corner decorations -->
    <div class="absolute top-12 left-12 doodle-corner opacity-40" aria-hidden="true"></div>
    <div class="absolute bottom-12 right-12 doodle-corner rotate-180 opacity-40" aria-hidden="true"></div>

    <!-- Floating dots -->
    <div class="absolute top-1/4 right-1/6 w-2 h-2 rounded-full bg-ochre/20 animate-float" aria-hidden="true"></div>
    <div class="absolute bottom-1/3 left-1/5 w-3 h-3 rounded-full bg-ink-300/15 animate-float" style="animation-delay: 2s;" aria-hidden="true"></div>

    <div class="relative max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Title -->
      <div class="text-center mb-fib-6 reveal-fade-up">
        <h1 class="text-phi-2xl sm:text-phi-3xl font-hand font-bold text-ink-900 mb-fib-3">
          你遇到过这些问题吗？
        </h1>
        <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto">
          我们也遇到过。所以我们做了 Lurus。
        </p>
      </div>

      <!-- Pain point cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-fib-4 mb-fib-6 reveal-fade-up">
        <div
          v-for="pain in painPoints"
          :key="pain.question"
          class="border-sketchy bg-cream-50 p-fib-5 hover:shadow-paper-hover transition-all"
        >
          <div
            class="w-10 h-10 rounded-lg flex items-center justify-center border-2 border-ink-200 mb-fib-4"
            :style="{ backgroundColor: pain.color + '20' }"
          >
            <svg
              class="w-5 h-5"
              :style="{ color: pain.color }"
              fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="pain.icon" />
            </svg>
          </div>
          <p class="text-ink-700 font-medium mb-fib-3 leading-relaxed">{{ pain.question }}</p>
          <p class="text-sm font-hand font-bold" :style="{ color: pain.color }">
            → {{ pain.answer }}
          </p>
        </div>
      </div>

      <!-- CTA buttons -->
      <div class="flex flex-wrap items-center justify-center gap-fib-3 reveal-fade-up">
        <button
          class="btn-hand btn-hand-primary inline-flex items-center justify-center gap-2 text-lg px-8 py-3"
          @click="track('cta_click', { label: 'hero_register' }); login({ prompt: 'create' })"
        >
          免费开始
        </button>
        <a
          href="https://docs.lurus.cn"
          target="_blank"
          rel="noopener noreferrer"
          class="btn-hand inline-flex items-center justify-center gap-2 text-lg px-8 py-3"
          @click="track('cta_click', { label: 'hero_docs' })"
        >
          查看文档
        </a>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
