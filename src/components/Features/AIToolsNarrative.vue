<script setup lang="ts">

const pillars = [
  {
    id: 'access',
    title: '不再为每个 AI 单独注册和充值',
    product: 'Lurus API',
    description: '一个账户，接入所有模型',
    detail: '不管你想用哪个 AI — 只需一个账户、一个余额。不再在各种平台之间反复注册、充值、管理密钥。',
    iconPath: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
    color: '#6B8BA4',
  },
  {
    id: 'manage',
    title: '不再在 5 个 app 之间切来切去',
    product: 'Lurus Switch',
    description: '一个面板，管理所有工具',
    detail: '你的 AI 编程助手、聊天工具、翻译器 — 所有配置和账户，集中在一个地方管理。',
    iconPath: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
    color: '#C67B5C',
  },
  {
    id: 'memory',
    title: '不再重复跟 AI 解释你是谁',
    product: 'MemX',
    description: '跨工具记忆，AI 懂你',
    detail: '换个工具又要从头介绍自己？让 AI 记住你的偏好、习惯和项目背景，下次对话无缝衔接。',
    iconPath: 'M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4',
    color: '#8B7A5C',
  },
]

const toolLogos = [
  'Claude Code', 'Codex CLI', 'Gemini CLI', 'Cursor', 'Windsurf', 'Cline',
]
</script>

<template>
  <section class="py-fib-7 bg-cream-100 relative overflow-hidden" aria-label="AI Tools Ecosystem">
    <!-- Background pattern -->
    <div class="absolute inset-0 opacity-[0.02]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>

    <div class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Section header -->
      <div class="text-center mb-fib-6 reveal-fade-up">
        <h2 class="text-phi-2xl sm:text-phi-3xl text-ink-900 mb-fib-3 font-semibold">
          AI 工具爆发的时代，你需要一个控制中心
        </h2>
        <p class="text-phi-lg text-ink-500 max-w-3xl mx-auto leading-relaxed">
          Lurus 不替代它们 — 让它们更强大
        </p>
      </div>

      <!-- Tool logos ticker -->
      <div class="flex flex-wrap justify-center gap-fib-3 mb-fib-6 reveal-fade-up">
        <span
          v-for="tool in toolLogos"
          :key="tool"
          class="px-4 py-2 border-sketchy-light bg-cream-100 text-sm text-ink-500 font-mono"
        >
          {{ tool }}
        </span>
      </div>

      <!-- Three pillars -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-fib-5 reveal-fade-up">
        <div
          v-for="pillar in pillars"
          :key="pillar.id"
          class="border-sketchy bg-cream-100 p-fib-5 hover:shadow-paper-hover transition-all"
        >
          <!-- Icon + product name -->
          <div class="flex items-center gap-3 mb-fib-4">
            <div
              class="w-10 h-10 rounded-lg flex items-center justify-center border-2 border-ink-200"
              :style="{ backgroundColor: pillar.color + '20' }"
            >
              <svg
                class="w-5 h-5"
                :style="{ color: pillar.color }"
                fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="pillar.iconPath" />
              </svg>
            </div>
            <div>
              <p class="text-xs text-ink-300 uppercase tracking-wider">{{ pillar.product }}</p>
              <h3 class="text-lg font-bold text-ink-900 font-hand">{{ pillar.title }}</h3>
            </div>
          </div>

          <!-- Description -->
          <p class="text-ink-700 font-medium mb-fib-3">{{ pillar.description }}</p>
          <p class="text-sm text-ink-400 leading-relaxed">{{ pillar.detail }}</p>
        </div>
      </div>

      <!-- Bottom summary -->
      <div class="text-center mt-fib-6 reveal-fade-up">
        <p class="text-ink-500 max-w-2xl mx-auto leading-relaxed">
          无论你用哪个 AI 工具，Lurus 让你的体验更
          <span class="text-ink-900 font-medium underline-doodle">统一</span>、更
          <span class="text-ink-900 font-medium underline-doodle">持久</span>、更
          <span class="text-ink-900 font-medium underline-doodle">可控</span>。
        </p>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";
</style>
