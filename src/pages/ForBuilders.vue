<script setup lang="ts">
import { ref } from 'vue'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useTracking } from '../composables/useTracking'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
const { track } = useTracking()

const products = [
  {
    id: 'kova',
    name: 'Kova SDK',
    tagline: 'Rust Agent 持久化执行框架',
    description: '将 WAL 预写日志引入 Agent 执行引擎。崩溃重启后自动从断点恢复，Rust 零 GC 保障 μs 级确定性延迟。构建生产级、永不中断的 AI Agent。',
    features: [
      'WAL 持久化，掉电不丢状态',
      'Rust 零 GC，μs 级响应',
      'Agent Loop 断点自动恢复',
      'Plan → Execute → Review 循环',
      '编译时类型安全',
      'Async + 多线程调度',
    ],
    cta: { text: '查看文档', href: 'https://docs.lurus.cn', external: true },
    color: '#B08EFF',
    iconPath: 'M9 3H7a2 2 0 00-2 2v2M9 3h6M9 3v2m6-2h2a2 2 0 012 2v2m0 0V7m0 0h2M3 9v6m0 0v2a2 2 0 002 2h2m-4-4h2M21 9v6m0 0v2a2 2 0 01-2 2h-2m4-4h-2M9 21h6M9 21v-2m6 2v-2M9 19H7a2 2 0 01-2-2v-2m14 4h-2a2 2 0 01-2-2v-2',
  },
  {
    id: 'forge',
    name: 'Forge',
    tagline: 'AI 产品开发工作台',
    description: '对话即需求 — 用自然语言描述产品想法，AI PM Agent 自动生成结构化需求树。从模糊构想到可执行 Story，一场对话搞定。运行在 Kova 之上，Agent 任务永不丢失。',
    features: [
      '对话 → 需求树自动生成',
      'AI PM / Architect / Code Agent',
      '产品本体论（7 级知识图谱）',
      'Kova WAL 保障任务不丢失',
      '依赖守护者（自动升级分析）',
      '实时协作 (WebSocket)',
    ],
    cta: { text: '了解 Forge', href: 'https://docs.lurus.cn', external: true },
    color: '#FF6B35',
    iconPath: 'M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4',
  },
  {
    id: 'lumen',
    name: 'Lumen',
    tagline: 'Agent 执行可视化与调试 CLI',
    description: '让 Agent 执行过程透明可见。实时追踪调用链与每步耗时，支持断点注入和状态树检查 — 开发阶段必备，生产排查利器。',
    features: [
      '实时执行 flamechart',
      '断点注入与暂停',
      '状态树可视化',
      'CLI 日志导出',
      '与 Kova SDK 无缝集成',
      '零侵入式接入',
    ],
    cta: { text: '查看文档', href: 'https://docs.lurus.cn', external: true },
    color: '#FFE566',
    iconPath: 'M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4',
  },
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
    description: '为你的产品添加跨会话持久记忆。语义检索、本地优先、端到端加密 — 让你的 AI 应用拥有"记住用户"的能力，3 行代码接入。',
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
    description: '在你的品牌下提供 AI 模型访问服务。私有化部署、自定义定价、完全白标 — 你的客户看到的是你的品牌，你获得模型调用的全部收益。',
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
]

const architectureSteps = [
  { step: '1', title: 'Kova SDK', desc: 'Agent 持久执行引擎' },
  { step: '2', title: 'Forge', desc: '对话式产品开发工作台' },
  { step: '3', title: 'Lurus API', desc: '50+ AI 模型统一网关' },
  { step: '4', title: 'Identity', desc: '认证 + 订阅计费闭环' },
]
</script>

<template>
  <div ref="pageRef">
    <!-- Hero -->
    <section class="builder-hero section-dark" aria-label="For Builders">
      <div class="builder-hero-glow" aria-hidden="true"></div>
      <div class="relative max-w-4xl mx-auto px-6 sm:px-8 lg:px-12 py-28 sm:py-36 text-center">
        <span class="builder-eyebrow reveal-fade-up">构建者</span>
        <h1 class="builder-title reveal-fade-up">
          用 AI 构建你的<br>
          <span class="text-gradient-gold">平台基座</span>
        </h1>
        <p class="builder-subtitle reveal-fade-up">
          Kova · Forge · Lumen · API · Identity · MemX —— 从 Agent 引擎到产品工作台的完整开发者工具链
        </p>
        <div class="builder-cta-row reveal-fade-up">
          <a
            href="https://docs.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-primary px-8 py-3 text-base"
            @click="track('cta_click', { label: 'builder_hero_docs' })"
          >
            查看文档 →
          </a>
          <a
            href="mailto:support@lurus.cn"
            class="btn-outline px-8 py-3 text-base"
          >
            联系我们
          </a>
        </div>
      </div>
    </section>

    <!-- Integration Path -->
    <section class="section-dark-raised py-20" aria-label="集成路径">
      <div class="max-w-4xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-12 reveal-fade-up">
          <h2 class="builder-section-title">4 步构建完整 AI 平台</h2>
          <p class="builder-section-sub">渐进式集成，每一步都独立可用</p>
        </div>
        <div class="arch-steps reveal-fade-up">
          <div
            v-for="(item, index) in architectureSteps"
            :key="item.step"
            class="arch-step"
          >
            <div class="arch-step-num">{{ item.step }}</div>
            <h3 class="arch-step-title">{{ item.title }}</h3>
            <p class="arch-step-desc">{{ item.desc }}</p>
            <div v-if="index < architectureSteps.length - 1" class="arch-connector" aria-hidden="true">→</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Products -->
    <section class="section-dark py-24" aria-label="产品">
      <div class="max-w-5xl mx-auto px-6 sm:px-8 lg:px-12">
        <div
          v-for="(product, index) in products"
          :key="product.id"
          class="builder-product reveal-fade-up"
          :class="{ 'builder-product--last': index === products.length - 1 }"
        >
          <div class="builder-product-grid" :class="{ 'builder-product-grid--flip': index % 2 === 1 }">
            <!-- Text side -->
            <div>
              <div class="builder-product-header">
                <div class="builder-product-icon" :style="{ color: product.color }">
                  <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="product.iconPath" />
                  </svg>
                </div>
                <div>
                  <h2 class="builder-product-name">{{ product.name }}</h2>
                  <p class="builder-product-tagline">{{ product.tagline }}</p>
                </div>
              </div>
              <p class="builder-product-desc">{{ product.description }}</p>
              <ul class="builder-feature-list">
                <li v-for="feature in product.features" :key="feature">
                  <svg class="w-4 h-4 shrink-0" style="color:var(--color-ochre)" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
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
                class="btn-primary inline-block mt-8 px-6 py-2.5"
                @click="track('cta_click', { label: `builder_${product.id}` })"
              >{{ product.cta.text }} →</a>
              <router-link
                v-else
                :to="product.cta.href"
                class="btn-primary inline-block mt-8 px-6 py-2.5"
                @click="track('cta_click', { label: `builder_${product.id}` })"
              >{{ product.cta.text }} →</router-link>
            </div>
            <!-- Visual side -->
            <div class="builder-product-visual" :style="{ '--prod-color': product.color }">
              <div class="builder-visual-inner">
                <div class="builder-visual-icon" :style="{ color: product.color }">
                  <svg class="w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.2" :d="product.iconPath" />
                  </svg>
                </div>
                <p class="builder-visual-name">{{ product.name }}</p>
                <p class="builder-visual-tag">{{ product.tagline }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Platform Bundle CTA -->
    <section class="section-dark-raised py-24" aria-label="平台构建者套件">
      <div class="max-w-4xl mx-auto px-6 sm:px-8 lg:px-12 text-center reveal-fade-up">
        <h2 class="builder-section-title">开发者全套工具链</h2>
        <p class="builder-section-sub builder-section-sub--wide">
          Kova 执行 Agent，Forge 管理产品，Lumen 调试追踪，API 接入模型，Identity 认证计费，MemX 持久记忆 — 完整闭环。
        </p>
        <div class="builder-cta-row mt-10">
          <a
            href="https://docs.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-primary px-8 py-3 text-base"
          >查看技术文档 →</a>
          <a href="mailto:support@lurus.cn" class="btn-outline px-8 py-3 text-base">预约技术咨询</a>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";

/* Hero */
.builder-hero {
  position: relative;
  overflow: hidden;
}

.builder-hero-glow {
  position: absolute;
  top: 10%;
  left: 50%;
  transform: translateX(-50%);
  width: 600px;
  height: 350px;
  background: radial-gradient(ellipse, rgba(139,107,125,0.1) 0%, transparent 70%);
  pointer-events: none;
}

.builder-eyebrow {
  display: inline-block;
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  padding: 5px 14px;
  border-radius: 999px;
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  color: var(--color-text-secondary);
  margin-bottom: 24px;
}

.builder-title {
  font-size: clamp(2.5rem, 6vw, 4rem);
  font-weight: 800;
  color: var(--color-text-primary);
  line-height: 1.1;
  letter-spacing: -0.03em;
  margin-bottom: 20px;
}

.builder-subtitle {
  font-size: 1.15rem;
  color: var(--color-text-secondary);
  max-width: 520px;
  margin: 0 auto 36px;
  line-height: 1.65;
}

.builder-cta-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

/* Architecture steps */
.arch-steps {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 14px;
  position: relative;
}

@media (min-width: 640px) {
  .arch-steps { grid-template-columns: repeat(4, 1fr); }
}

.arch-step {
  position: relative;
  padding: 24px 18px;
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  border-radius: 14px;
  text-align: center;
}

.arch-step-num {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background-color: var(--color-ochre);
  color: #0D0B09;
  font-weight: 800;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 12px;
}

.arch-step-title {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 6px;
}

.arch-step-desc {
  font-size: 0.78rem;
  color: var(--color-text-muted);
  line-height: 1.5;
}

.arch-connector {
  display: none;
  position: absolute;
  right: -12px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-text-muted);
  font-size: 1rem;
  z-index: 1;
}

@media (min-width: 640px) {
  .arch-connector { display: block; }
}

/* Products */
.builder-section-title {
  font-size: clamp(1.75rem, 4vw, 2.5rem);
  font-weight: 800;
  color: var(--color-text-primary);
  letter-spacing: -0.03em;
  margin-bottom: 12px;
}

.builder-section-sub {
  font-size: 1rem;
  color: var(--color-text-secondary);
  max-width: 400px;
  margin: 0 auto;
  line-height: 1.65;
}

.builder-section-sub--wide {
  max-width: 580px;
  margin-top: 12px;
  margin-bottom: 0;
}

.builder-product {
  margin-bottom: 80px;
}

.builder-product--last {
  margin-bottom: 0;
}

.builder-product-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 56px;
  align-items: center;
}

@media (max-width: 767px) {
  .builder-product-grid {
    grid-template-columns: 1fr;
    gap: 32px;
  }
  .builder-product-grid--flip > *:first-child { order: 0; }
}

@media (min-width: 768px) {
  .builder-product-grid--flip > *:first-child { order: 2; }
  .builder-product-grid--flip > *:last-child  { order: 1; }
}

.builder-product-header {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 16px;
}

.builder-product-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background-color: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.08);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.builder-product-name {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--color-text-primary);
  line-height: 1.3;
}

.builder-product-tagline {
  font-size: 0.82rem;
  color: var(--color-text-muted);
  margin-top: 2px;
}

.builder-product-desc {
  font-size: 0.95rem;
  color: var(--color-text-secondary);
  line-height: 1.7;
  margin-bottom: 20px;
}

.builder-feature-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

@media (max-width: 480px) {
  .builder-feature-list { grid-template-columns: 1fr; }
}

.builder-feature-list li {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  color: var(--color-text-secondary);
}

.builder-product-visual {
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  border-radius: 16px;
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.builder-product-visual::before {
  content: '';
  position: absolute;
  top: -60px;
  right: -60px;
  width: 180px;
  height: 180px;
  border-radius: 50%;
  background: radial-gradient(circle, var(--prod-color, var(--color-ochre)), transparent 70%);
  opacity: 0.12;
  pointer-events: none;
}

.builder-visual-inner {
  text-align: center;
  padding: 32px;
}

.builder-visual-icon {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  background-color: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.07);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 12px;
}

.builder-visual-name {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text-secondary);
}

.builder-visual-tag {
  font-size: 0.78rem;
  color: var(--color-text-muted);
  margin-top: 4px;
}
</style>
