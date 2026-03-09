<script setup lang="ts">

const pillars = [
  {
    id: 'access',
    title: '统一接入',
    product: 'Lurus API',
    description: '所有 AI 模型，一个端点搞定',
    detail: '不管是 Claude、GPT、Gemini 还是 DeepSeek — 一个 API Key，统一调用格式，零迁移成本。',
    iconPath: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
    color: '#6B8BA4',
  },
  {
    id: 'manage',
    title: '统一管理',
    product: 'Lurus Switch',
    description: '所有 AI 工具，一个面板管理',
    detail: 'Claude Code、Codex CLI、Gemini CLI、Cursor — 配置、密钥、代理、MCP 预设，一站式管理。',
    iconPath: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
    color: '#C67B5C',
  },
  {
    id: 'memory',
    title: '统一记忆',
    product: 'MemX',
    description: '所有 AI 会话，一份记忆贯通',
    detail: '跨工具、跨会话的持久记忆 — AI 永远记住你的偏好、项目上下文和工作习惯。',
    iconPath: 'M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4',
    color: '#8B7A5C',
  },
]

const toolLogos = [
  'Claude Code', 'Codex CLI', 'Gemini CLI', 'Cursor', 'Windsurf', 'Cline',
]
</script>

<template>
  <section class="py-fib-7 bg-cream-50 relative overflow-hidden" aria-label="AI Tools Ecosystem">
    <!-- Background pattern -->
    <div class="absolute inset-0 opacity-[0.02]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>

    <div class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Section header -->
      <div class="text-center mb-fib-5 reveal-fade-up">
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
      <div class="grid grid-cols-1 md:grid-cols-3 gap-fib-4 reveal-fade-up">
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
