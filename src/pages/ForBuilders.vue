<script setup lang="ts">
import { ref } from 'vue'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useTracking } from '../composables/useTracking'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
const { track } = useTracking()

const products = [
  {
    id: 'identity',
    name: 'Lurus Identity',
    tagline: '身份认证 + 订阅计费平台',
    description: '不再重复造认证和计费系统。OIDC 标准认证、订阅管理、钱包系统、角色权限 — 3 天集成而不是 3 个月。适用于任何需要用户体系的 SaaS 产品。',
    features: [
      'OIDC + gRPC 双协议支持',
      '订阅管理 + 钱包系统',
      '多支付网关 (Stripe / WeChat / Alipay)',
      '角色权限 + 权限缓存',
      '审计日志 + 邮件通知',
      '服务间 API (Bearer Key)',
    ],
    cta: { text: '查看文档', href: 'https://docs.lurus.cn', external: true },
    color: '#8B6B7D',
    iconPath: 'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z',
  },
  {
    id: 'memx-sdk',
    name: 'MemX SDK',
    tagline: 'AI 记忆基础设施',
    description: '为你的产品添加跨会话持久记忆。语义检索、本地优先、端到端加密 — 让你的 AI 应用拥有"记住用户"的能力。',
    features: [
      '跨会话持久化存储',
      '语义向量检索',
      '本地优先 + 端到端加密',
      'Python SDK (pip install)',
      'REST API 接口',
      '无限记忆容量',
    ],
    cta: { text: '安装 SDK', href: '/download#memx' },
    color: '#8B7A5C',
    iconPath: 'M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4',
  },
  {
    id: 'api-oem',
    name: 'Lurus API (OEM)',
    tagline: '白标 LLM 网关',
    description: '在你的品牌下提供 AI 模型访问服务。私有化部署、自定义定价、完全白标 — 你的客户看到的是你的品牌。',
    features: [
      '完全白标 — 你的品牌',
      '自定义定价与配额',
      '私有化部署选项',
      '多租户管理后台',
      '50+ 模型即时可用',
      '请求日志与分析',
    ],
    cta: { text: '联系我们', href: 'mailto:support@lurus.cn', external: true },
    color: '#6B8BA4',
    iconPath: 'M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
  },
  {
    id: 'notification',
    name: 'Lurus Notification',
    tagline: '多渠道通知中枢',
    description: 'NATS 事件驱动的通知引擎。站内信、邮件、移动推送 — 一次集成，多渠道触达。模板系统支持变量替换和多语言。',
    features: [
      'NATS JetStream 事件驱动',
      '站内信 (WebSocket 实时)',
      '邮件通知 (Stalwart SMTP)',
      '移动推送 (FCM, 规划中)',
      '模板管理 + 变量替换',
      '发送记录与审计',
    ],
    cta: { text: '联系我们', href: 'mailto:support@lurus.cn', external: true },
    color: '#A89B8B',
    iconPath: 'M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9',
  },
]

const architectureSteps = [
  { step: '1', title: '集成 Identity', desc: 'OIDC 认证 + 订阅计费，3 天上线' },
  { step: '2', title: '接入 API', desc: '50+ AI 模型能力，一个端点' },
  { step: '3', title: '添加 MemX', desc: '持久记忆层，用户体验升级' },
  { step: '4', title: '启用 Notify', desc: '多渠道触达，用户运营闭环' },
]
</script>

<template>
  <div ref="pageRef">
    <!-- Hero -->
    <section class="relative overflow-hidden bg-cream-50 py-fib-7">
      <div class="absolute inset-0 opacity-[0.03]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>
      <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <span class="inline-block text-xs font-semibold uppercase tracking-wider px-3 py-1 rounded-full mb-fib-4" style="background-color: #8B6B7D20; color: #8B6B7D;">
          构建者
        </span>
        <h1 class="text-phi-2xl md:text-phi-3xl lg:text-[58px] text-ink-900 mb-fib-4 leading-tight font-bold reveal-fade-up">
          用 AI 构建你的
          <span class="text-gradient-ochre font-hand">平台基座</span>
        </h1>
        <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto leading-relaxed mb-fib-5 reveal-fade-up">
          身份认证、AI 记忆、模型网关、通知中枢 — 为你的产品注入完整的 AI 基础设施
        </p>
        <div class="flex flex-col sm:flex-row gap-fib-3 justify-center reveal-fade-up">
          <a href="https://docs.lurus.cn" target="_blank" rel="noopener noreferrer" class="btn-hand btn-hand-primary text-center">
            查看文档
          </a>
          <a href="mailto:support@lurus.cn" class="btn-hand text-center">
            联系我们
          </a>
        </div>
      </div>
    </section>

    <!-- Integration path -->
    <section class="py-fib-6 bg-cream-100">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-fib-5 reveal-fade-up">
          <h2 class="text-phi-2xl text-ink-900 mb-fib-3 font-semibold">4 步构建完整 AI 平台</h2>
          <p class="text-ink-500">渐进式集成，每一步都独立可用</p>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-fib-3 reveal-fade-up">
          <div
            v-for="item in architectureSteps"
            :key="item.step"
            class="border-sketchy bg-cream-50 p-fib-4 text-center"
          >
            <div class="w-8 h-8 rounded-full bg-ochre flex items-center justify-center mx-auto mb-fib-3 text-cream-50 font-bold text-sm">
              {{ item.step }}
            </div>
            <h3 class="font-bold text-ink-900 text-sm mb-1">{{ item.title }}</h3>
            <p class="text-xs text-ink-400">{{ item.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Products -->
    <section class="py-fib-7 bg-cream-50">
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
              <ul class="grid grid-cols-1 sm:grid-cols-2 gap-2 mb-fib-4">
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
                @click="track('cta_click', { label: `builder_${product.id}` })"
              >
                {{ product.cta.text }}
              </a>
              <router-link
                v-else
                :to="product.cta.href"
                class="btn-hand btn-hand-primary inline-block"
                @click="track('cta_click', { label: `builder_${product.id}` })"
              >
                {{ product.cta.text }}
              </router-link>
            </div>
            <div class="border-sketchy bg-cream-100 p-fib-5 min-h-[200px] flex items-center justify-center">
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

    <!-- Platform Bundle CTA -->
    <section class="py-fib-7 bg-cream-100">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
        <h2 class="text-phi-2xl text-ink-900 mb-fib-3 font-semibold">平台构建者套件</h2>
        <p class="text-ink-500 max-w-2xl mx-auto mb-fib-5 leading-relaxed">
          Identity + MemX SDK + API OEM + Notification — 完整的 AI 平台基座。
          Identity 提供认证计费，API 提供模型能力，MemX 提供记忆，Notification 提供触达。
        </p>
        <div class="flex flex-col sm:flex-row gap-fib-3 justify-center">
          <a href="https://docs.lurus.cn" target="_blank" rel="noopener noreferrer" class="btn-hand btn-hand-primary text-center">查看技术文档</a>
          <a href="mailto:support@lurus.cn" class="btn-hand text-center">预约技术咨询</a>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";
</style>
