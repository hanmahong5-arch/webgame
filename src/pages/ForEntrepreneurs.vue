<script setup lang="ts">
import { ref } from 'vue'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useTracking } from '../composables/useTracking'
import { useAuth } from '../composables/useAuth'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
const { track } = useTracking()
const { login } = useAuth()

const products = [
  {
    id: 'api',
    name: 'Lurus API',
    tagline: 'LLM 统一网关',
    description: '一个端点接入 50+ AI 模型。OpenAI 兼容接口，零迁移成本。多租户隔离、用量配额、智能路由 — 企业级 AI 接入从第一天开始。',
    features: ['50+ AI 模型统一接入', 'OpenAI 兼容 — 零迁移', '多租户隔离与配额管理', '智能路由与自动故障转移', '99.9% 可用性 SLA'],
    cta: { text: '注册试用', href: 'https://api.lurus.cn', external: true },
    color: '#6B8BA4',
    iconPath: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
  },
  {
    id: 'mail',
    name: 'Lurus Mail',
    tagline: '企业邮件',
    description: '自建企业邮件系统，数据完全自主可控。多域名管理、SPF/DKIM/DMARC 全配置，中国网络环境送达率优化。',
    features: ['多域名统一管理', 'SPF/DKIM/DMARC 安全防护', '中国网络送达率优化', '日历 + 通讯录 (规划中)', '99% 投递成功率'],
    cta: { text: '了解更多', href: 'https://mail.lurus.cn', external: true },
    color: '#8B6B7D',
    iconPath: 'M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
  },
  {
    id: 'switch',
    name: 'Lurus Switch (团队版)',
    tagline: '团队 AI 工具管理',
    description: '统一管理团队的 AI CLI 工具配置。密钥集中管理、代理统一配置、MCP 预设分发 — 从 "每人自己配" 到 "一键同步"。',
    features: ['团队配置统一管理', '密钥集中分发', '代理与 MCP 预设', '使用量统计', '合规审计'],
    cta: { text: '下载 Switch', href: '/download' },
    color: '#C67B5C',
    iconPath: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
  },
  {
    id: 'gushen-pro',
    name: 'GuShen Pro',
    tagline: '机构量化服务',
    description: '面向金融机构的量化交易解决方案。专业级策略引擎、风控系统、合规报告 — 从研究到实盘的完整闭环。',
    features: ['专业级策略引擎', '风险控制系统', '合规报告生成', '多策略组合管理', '机构级数据安全'],
    cta: { text: '联系我们', href: 'mailto:support@lurus.cn', external: true },
    color: '#7D8B6A',
    iconPath: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z',
  },
]

const industries = [
  { name: '金融', desc: '量化策略 · 风险评估 · 市场分析', products: 'GuShen + API' },
  { name: '学术', desc: '文献综述 · 数据处理 · 论文写作', products: 'API + MemX' },
  { name: '医疗', desc: '文献检索 · 临床辅助 · 报告生成', products: 'API + Identity' },
  { name: '法律', desc: '法规检索 · 合同审查 · 案例分析', products: 'API + MemX' },
]
</script>

<template>
  <div ref="pageRef">
    <!-- Hero -->
    <section class="relative overflow-hidden bg-cream-50 pt-28 pb-fib-7">
      <div class="absolute inset-0 opacity-[0.03]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>
      <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <span class="inline-block text-xs font-semibold uppercase tracking-wider px-3 py-1 rounded-full mb-fib-4" style="background-color: #6B8BA420; color: #6B8BA4;">
          创业者
        </span>
        <h1 class="text-phi-2xl md:text-phi-3xl lg:text-[58px] text-ink-900 mb-fib-4 leading-tight font-bold reveal-fade-up">
          用 AI 加速你的
          <span class="text-gradient-ochre font-hand">业务增长</span>
        </h1>
        <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto leading-relaxed mb-fib-5 reveal-fade-up">
          LLM 网关、企业邮件、团队工具管理 — 从第一天开始拥有企业级 AI 基础设施
        </p>
        <div class="flex flex-col sm:flex-row gap-fib-3 justify-center reveal-fade-up">
          <a href="https://api.lurus.cn" target="_blank" rel="noopener noreferrer" class="btn-hand btn-hand-primary text-center">
            注册 API Key
          </a>
          <button @click="login({ prompt: 'create' })" class="btn-hand text-center">
            免费开始
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
                @click="track('cta_click', { label: `biz_${product.id}` })"
              >
                {{ product.cta.text }}
              </a>
              <router-link
                v-else
                :to="product.cta.href"
                class="btn-hand btn-hand-primary inline-block"
                @click="track('cta_click', { label: `biz_${product.id}` })"
              >
                {{ product.cta.text }}
              </router-link>
            </div>
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

    <!-- Industry Solutions -->
    <section class="py-fib-6 bg-cream-50">
      <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-fib-5 reveal-fade-up">
          <h2 class="text-phi-2xl text-ink-900 mb-fib-3 font-semibold">行业解决方案</h2>
          <p class="text-ink-500">每个行业都有专属的产品组合</p>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-fib-4 reveal-fade-up">
          <router-link
            v-for="industry in industries"
            :key="industry.name"
            to="/solutions"
            class="border-sketchy bg-cream-100 p-fib-4 text-center hover:shadow-paper-hover transition-all"
          >
            <h3 class="font-bold text-ink-900 mb-1">{{ industry.name }}</h3>
            <p class="text-xs text-ink-400 mb-2">{{ industry.desc }}</p>
            <p class="text-xs text-ochre font-medium">{{ industry.products }}</p>
          </router-link>
        </div>
      </div>
    </section>

    <!-- Bundle CTA -->
    <section class="py-fib-7 bg-cream-100">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
        <h2 class="text-phi-2xl text-ink-900 mb-fib-3 font-semibold">企业 AI 套餐</h2>
        <p class="text-ink-500 max-w-2xl mx-auto mb-fib-5 leading-relaxed">
          Lurus API + Mail + Switch (团队版) + Identity SSO — 企业级 AI 基础设施，开箱即用。
        </p>
        <div class="flex flex-col sm:flex-row gap-fib-3 justify-center">
          <router-link to="/pricing" class="btn-hand btn-hand-primary text-center">查看定价</router-link>
          <a href="mailto:support@lurus.cn" class="btn-hand text-center">联系销售</a>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";
</style>
