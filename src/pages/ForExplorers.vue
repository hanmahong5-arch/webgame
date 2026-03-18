<script setup lang="ts">
import { ref } from 'vue'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useTracking } from '../composables/useTracking'
import { useAuth } from '../composables/useAuth'
import PricingPreview from '../components/Pricing/PricingPreview.vue'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
const { track } = useTracking()
const { login } = useAuth()

const products = [
  {
    id: 'creator',
    name: 'Lurus Creator',
    tagline: '桌面内容工厂',
    description: '输入视频链接，yt-dlp 自动下载，Whisper 高精度转录，LLM 优化文案，一键同步到微信视频号、抖音、YouTube — 全流程无需手动操作。',
    features: ['yt-dlp 视频抓取', 'Whisper 语音转录', 'LLM 文案优化', '多平台一键发布', '本地运行 · 零云依赖'],
    cta: { text: '下载 Creator', href: '/download' },
    color: '#C67B5C',
    iconPath: 'M15 10l4.553-2.069A1 1 0 0121 8.845v6.31a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z',
  },
  {
    id: 'lucrum',
    name: 'Lucrum',
    tagline: 'AI 量化交易',
    description: '用自然语言描述你的交易策略，AI 自动生成可执行的量化代码。30+ 金融指标，专业级回测引擎，从想法到策略只需一句话。',
    features: ['自然语言策略生成', '30+ 金融指标', '专业级回测引擎', '多策略同时验证', '11 个投资流派 AI 顾问'],
    cta: { text: '访问 Lucrum', href: 'https://gushen.lurus.cn', external: true },
    color: '#7D8B6A',
    iconPath: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z',
  },
  {
    id: 'switch',
    name: 'Lurus Switch',
    tagline: 'AI 工具管家',
    description: '一站式管理 Claude Code、Codex CLI、Gemini CLI 等 AI 工具 — 配置、密钥、代理、MCP 预设，一个面板全搞定。',
    features: ['5+ AI CLI 工具管理', '配置自动生成', 'MCP 预设库', '配置快照与差异对比', '计费仪表盘'],
    cta: { text: '下载 Switch', href: '/download' },
    color: '#C67B5C',
    iconPath: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
  },
  {
    id: 'memx',
    name: 'MemX',
    tagline: 'AI 记忆扩展',
    description: '让 AI 永远记住你 — 你的偏好、你的文档、你的工作上下文。跨会话、跨工具的持久记忆，语义检索即用即得。',
    features: ['跨会话持久记忆', '语义检索', '本地优先存储', '端到端加密', '一行命令安装 (pip)'],
    cta: { text: '安装 MemX', href: '/download#memx' },
    color: '#8B7A5C',
    iconPath: 'M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4',
  },
]
</script>

<template>
  <div ref="pageRef">
    <!-- Hero -->
    <section class="relative overflow-hidden bg-cream-50 py-fib-7">
      <div class="absolute inset-0 opacity-[0.03]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>
      <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <span class="inline-block text-xs font-semibold uppercase tracking-wider px-3 py-1 rounded-full mb-fib-4" style="background-color: #5C7A8B20; color: #5C7A8B;">
          探索者
        </span>
        <h1 class="text-phi-2xl md:text-phi-3xl lg:text-[58px] text-ink-900 mb-fib-4 leading-tight font-bold reveal-fade-up">
          用 AI 武装你的
          <span class="text-gradient-ochre font-hand">每一天</span>
        </h1>
        <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto leading-relaxed mb-fib-5 reveal-fade-up">
          视频内容创作、量化交易、工具管理、持久记忆 — 个人效率的无限延伸
        </p>
        <div class="flex flex-col sm:flex-row gap-fib-3 justify-center reveal-fade-up">
          <router-link to="/download" class="btn-hand btn-hand-primary text-center">
            下载开始
          </router-link>
          <button @click="login({ prompt: 'create' })" class="btn-hand text-center">
            免费注册
          </button>
        </div>
      </div>
    </section>

    <!-- Products -->
    <section class="py-fib-7 bg-cream-100">
      <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <div
          v-for="(product, index) in products"
          :key="product.id"
          class="mb-fib-7 last:mb-0 reveal-fade-up"
        >
          <div class="grid grid-cols-1 md:grid-cols-2 gap-fib-5 items-center" :class="index % 2 === 1 ? 'md:[direction:rtl] md:[&>*]:[direction:ltr]' : ''">
            <!-- Text -->
            <div>
              <div class="flex items-center gap-3 mb-fib-3">
                <div
                  class="w-10 h-10 rounded-lg flex items-center justify-center border-2 border-ink-200"
                  :style="{ backgroundColor: product.color + '20' }"
                >
                  <svg class="w-5 h-5" :style="{ color: product.color }" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="product.iconPath" />
                  </svg>
                </div>
                <div>
                  <h2 class="text-xl font-bold text-ink-900">{{ product.name }}</h2>
                  <p class="text-sm text-ink-400">{{ product.tagline }}</p>
                </div>
              </div>
              <p class="text-ink-500 leading-relaxed mb-fib-4">{{ product.description }}</p>
              <ul class="space-y-2 mb-fib-4">
                <li v-for="feature in product.features" :key="feature" class="flex items-center gap-2 text-sm text-ink-700">
                  <svg class="w-4 h-4 text-ochre shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  {{ feature }}
                </li>
              </ul>
              <a
                v-if="product.cta.external"
                :href="product.cta.href"
                target="_blank"
                rel="noopener noreferrer"
                class="btn-hand btn-hand-primary inline-block"
                @click="track('cta_click', { label: `explorer_${product.id}` })"
              >
                {{ product.cta.text }}
              </a>
              <router-link
                v-else
                :to="product.cta.href"
                class="btn-hand btn-hand-primary inline-block"
                @click="track('cta_click', { label: `explorer_${product.id}` })"
              >
                {{ product.cta.text }}
              </router-link>
            </div>

            <!-- Visual placeholder -->
            <div class="border-sketchy bg-cream-50 p-fib-5 min-h-[200px] flex items-center justify-center">
              <div class="text-center">
                <div
                  class="w-16 h-16 rounded-xl flex items-center justify-center mx-auto mb-fib-3 border-2 border-ink-200"
                  :style="{ backgroundColor: product.color + '15' }"
                >
                  <svg class="w-8 h-8" :style="{ color: product.color }" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="product.iconPath" />
                  </svg>
                </div>
                <p class="text-sm text-ink-300 font-hand">{{ product.name }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Pricing Preview -->
    <PricingPreview />

    <!-- Bundle CTA -->
    <section class="py-fib-7 bg-cream-50">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
        <h2 class="text-phi-2xl text-ink-900 mb-fib-3 font-semibold">个人智能套餐</h2>
        <p class="text-ink-500 max-w-2xl mx-auto mb-fib-5 leading-relaxed">
          Creator + MemX + Switch + API 个人配额 — 一个订阅，完整的 AI 桌面体验。
          Creator 制作内容，MemX 持久记忆，Switch 管理工具，API 驱动一切。
        </p>
        <div class="flex flex-col sm:flex-row gap-fib-3 justify-center">
          <router-link to="/pricing" class="btn-hand btn-hand-primary text-center">查看定价</router-link>
          <button @click="login({ prompt: 'create' })" class="btn-hand text-center">免费开始</button>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";
</style>
