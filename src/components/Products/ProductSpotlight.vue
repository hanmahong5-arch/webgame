<script setup lang="ts">
import { ref } from 'vue'

interface SpotlightProduct {
  id: string
  tabLabel: string
  audience: string
  name: string
  tagline: string
  description: string
  features: string[]
  primaryCta: { text: string; href: string; external?: boolean }
  secondaryCta: { text: string; href: string; external?: boolean }
  color: string
  codeExample?: string
}

const spotlights: SpotlightProduct[] = [
  {
    id: 'acest',
    tabLabel: 'ACEST Desktop',
    audience: '探索者旗舰',
    name: 'ACEST Desktop',
    tagline: '在任何应用中按下快捷键，AI 立刻理解你正在做的事',
    description: '桌面全局 AI 上下文引擎 — 不需要切换窗口，不需要复制粘贴，AI 自动感知你的工作上下文。',
    features: [
      '全局上下文感知 — 不需要复制粘贴',
      '55+ 内置技能 — 翻译、总结、代码审查',
      '本地优先 — 你的数据从不离开你的电脑',
      '多模型支持 — Claude / GPT / Gemini 自由切换',
    ],
    primaryCta: { text: '下载', href: '/download' },
    secondaryCta: { text: '了解更多', href: '/for-explorers' },
    color: '#5C7A8B',
  },
  {
    id: 'api',
    tabLabel: 'Lurus API',
    audience: '创业者旗舰',
    name: 'Lurus API',
    tagline: '3 行代码，接入 50+ AI 模型',
    description: 'OpenAI 兼容的企业级 LLM 统一网关 — 零迁移成本，智能路由，99.9% 可用性。',
    features: [
      'OpenAI 兼容 — 一行代码迁移',
      '智能路由 — 自动故障转移与负载均衡',
      '多租户隔离 — 独立配额、密钥、用量统计',
      '实时监控 — 可视化调用链追踪',
    ],
    primaryCta: { text: '注册试用', href: 'https://api.lurus.cn', external: true },
    secondaryCta: { text: 'API 文档', href: 'https://docs.lurus.cn', external: true },
    color: '#6B8BA4',
    codeExample: `curl https://api.lurus.cn/v1/chat/completions \\
  -H "Authorization: Bearer $LURUS_API_KEY" \\
  -H "Content-Type: application/json" \\
  -d '{"model":"deepseek-chat",
       "messages":[{"role":"user","content":"Hello"}]}'`,
  },
  {
    id: 'identity',
    tabLabel: 'Lurus Identity',
    audience: '构建者旗舰',
    name: 'Lurus Identity',
    tagline: '不再重复造轮子 — 认证、计费、订阅，开箱即用',
    description: '统一身份与商业化平台 — OIDC 认证、订阅管理、钱包系统，3 天集成而不是 3 个月。',
    features: [
      'OIDC + gRPC — 行业标准协议',
      '订阅 + 钱包 — 完整的商业化组件',
      '多产品统一 — 一个账户体系，所有产品',
      '审计日志 — 全链路操作追踪',
    ],
    primaryCta: { text: '查看文档', href: 'https://docs.lurus.cn', external: true },
    secondaryCta: { text: '联系我们', href: '/about' },
    color: '#8B6B7D',
  },
]

const activeTab = ref(0)
</script>

<template>
  <section class="py-fib-7 bg-cream-100" aria-label="Featured Products">
    <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Section header -->
      <div class="text-center mb-fib-5 reveal-fade-up">
        <h2 class="text-phi-2xl sm:text-phi-3xl text-ink-900 mb-fib-3 font-semibold">旗舰产品</h2>
        <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto">每个受众群体的核心解决方案</p>
      </div>

      <!-- Tab buttons -->
      <div class="flex justify-center mb-fib-5 reveal-fade-up">
        <div class="inline-flex border-sketchy bg-cream-50 p-1 gap-1">
          <button
            v-for="(product, index) in spotlights"
            :key="product.id"
            class="px-5 py-2.5 text-sm font-medium rounded transition-all duration-200"
            :class="activeTab === index
              ? 'bg-cream-200 text-ink-900 shadow-sm'
              : 'text-ink-500 hover:text-ink-700'"
            @click="activeTab = index"
          >
            {{ product.tabLabel }}
          </button>
        </div>
      </div>

      <!-- Spotlight content -->
      <div class="reveal-fade-up">
        <TransitionGroup
          enter-active-class="transition-all duration-300 ease-out"
          enter-from-class="opacity-0 translate-y-4"
          enter-to-class="opacity-100 translate-y-0"
          leave-active-class="transition-all duration-200 ease-in absolute"
          leave-from-class="opacity-100"
          leave-to-class="opacity-0"
        >
          <div
            v-for="(product, index) in spotlights"
            :key="product.id"
            v-show="activeTab === index"
            class="spotlight-panel"
          >
            <div class="grid grid-cols-1 md:grid-cols-2 gap-fib-5 items-center">
              <!-- Left: Text content -->
              <div>
                <span
                  class="inline-block text-xs font-semibold uppercase tracking-wider px-3 py-1 rounded-full mb-fib-3"
                  :style="{ backgroundColor: product.color + '20', color: product.color }"
                >
                  {{ product.audience }}
                </span>
                <h3 class="text-phi-xl sm:text-phi-2xl text-ink-900 font-bold mb-fib-3">
                  {{ product.tagline }}
                </h3>
                <p class="text-ink-500 mb-fib-4 leading-relaxed">{{ product.description }}</p>
                <ul class="space-y-fib-3 mb-fib-5">
                  <li
                    v-for="feature in product.features"
                    :key="feature"
                    class="flex items-start gap-2"
                  >
                    <svg class="w-5 h-5 mt-0.5 text-ochre shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    <span class="text-sm text-ink-700">{{ feature }}</span>
                  </li>
                </ul>
                <div class="flex flex-col sm:flex-row gap-fib-3">
                  <a
                    v-if="product.primaryCta.external"
                    :href="product.primaryCta.href"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="btn-hand btn-hand-primary text-center"
                  >
                    {{ product.primaryCta.text }}
                  </a>
                  <router-link
                    v-else
                    :to="product.primaryCta.href"
                    class="btn-hand btn-hand-primary text-center"
                  >
                    {{ product.primaryCta.text }}
                  </router-link>
                  <a
                    v-if="product.secondaryCta.external"
                    :href="product.secondaryCta.href"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="btn-hand text-center"
                  >
                    {{ product.secondaryCta.text }}
                  </a>
                  <router-link
                    v-else
                    :to="product.secondaryCta.href"
                    class="btn-hand text-center"
                  >
                    {{ product.secondaryCta.text }}
                  </router-link>
                </div>
              </div>

              <!-- Right: Visual area -->
              <div class="border-sketchy bg-cream-50 p-fib-5 min-h-[280px] flex items-center justify-center">
                <!-- Code example for API -->
                <pre
                  v-if="product.codeExample"
                  class="text-xs text-ink-700 font-mono leading-relaxed overflow-x-auto w-full"
                ><code>{{ product.codeExample }}</code></pre>
                <!-- Feature list visual for non-code products -->
                <div v-else class="w-full space-y-fib-3">
                  <div
                    v-for="(feature, fi) in product.features"
                    :key="fi"
                    class="flex items-center gap-3 p-3 rounded-lg bg-cream-100 border border-ink-100"
                  >
                    <div
                      class="w-8 h-8 rounded-lg flex items-center justify-center shrink-0 text-sm font-bold text-cream-50"
                      :style="{ backgroundColor: product.color }"
                    >
                      {{ fi + 1 }}
                    </div>
                    <span class="text-sm text-ink-700">{{ feature.split(' — ')[0] }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </TransitionGroup>
      </div>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

.spotlight-panel {
  position: relative;
}
</style>
