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
    id: 'switch',
    name: 'Lurus Switch (团队版)',
    tagline: '团队 AI 工具管理',
    description: '统一管理团队的 AI CLI 工具配置。密钥集中管理、代理统一配置、MCP 预设分发 — 从 "每人自己配" 到 "一键同步"。',
    features: ['团队配置统一管理', '密钥集中分发', '代理与 MCP 预设', '使用量统计', '合规审计'],
    cta: { text: '下载 Switch', href: '/download' },
    color: '#FF8C69',
    iconPath: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
  },
  {
    id: 'lucrum-pro',
    name: 'Lucrum Pro',
    tagline: '机构量化服务',
    description: '面向金融机构的量化交易解决方案。专业级策略引擎、风控系统、合规报告 — 从研究到实盘的完整闭环。',
    features: ['专业级策略引擎', '风险控制系统', '合规报告生成', '多策略组合管理', '机构级数据安全'],
    cta: { text: '联系我们', href: 'mailto:support@lurus.cn', external: true },
    color: '#7D8B6A',
    iconPath: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z',
  },
]

const industries = [
  { name: '金融', desc: '量化策略 · 风险评估 · 市场分析', products: 'Lucrum + API' },
  { name: '学术', desc: '文献综述 · 数据处理 · 论文写作', products: 'API + MemX' },
  { name: '医疗', desc: '文献检索 · 临床辅助 · 报告生成', products: 'API + Identity' },
  { name: '法律', desc: '法规检索 · 合同审查 · 案例分析', products: 'API + MemX' },
]
</script>

<template>
  <div ref="pageRef">
    <!-- Hero -->
    <section class="biz-hero section-dark" aria-label="For Entrepreneurs">
      <div class="biz-hero-glow" aria-hidden="true"></div>
      <div class="relative max-w-4xl mx-auto px-6 sm:px-8 lg:px-12 py-28 sm:py-36 text-center">
        <span class="biz-eyebrow reveal-fade-up">创业者</span>
        <h1 class="biz-title reveal-fade-up">
          用 AI 加速你的<br>
          <span class="text-gradient-gold">业务增长</span>
        </h1>
        <p class="biz-subtitle reveal-fade-up">
          LLM 网关、量化交易、团队工具管理 — 从第一天开始拥有企业级 AI 基础设施
        </p>
        <div class="biz-cta-row reveal-fade-up">
          <a
            href="https://api.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-primary px-8 py-3 text-base"
            @click="track('cta_click', { label: 'biz_hero_api' })"
          >
            注册 API Key →
          </a>
          <button
            class="btn-outline px-8 py-3 text-base"
            @click="track('cta_click', { label: 'biz_hero_register' }); login({ prompt: 'create' })"
          >
            免费开始
          </button>
        </div>
      </div>
    </section>

    <!-- Products -->
    <section class="section-dark-raised py-24" aria-label="产品">
      <div class="max-w-5xl mx-auto px-6 sm:px-8 lg:px-12">
        <div
          v-for="(product, index) in products"
          :key="product.id"
          class="biz-product reveal-fade-up"
          :class="{ 'biz-product--last': index === products.length - 1 }"
        >
          <div class="biz-product-grid" :class="{ 'biz-product-grid--flip': index % 2 === 1 }">
            <!-- Text side -->
            <div>
              <div class="biz-product-header">
                <div class="biz-product-icon" :style="{ '--prod-color': product.color }">
                  <svg class="w-5 h-5" :style="{ color: product.color }" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="product.iconPath" />
                  </svg>
                </div>
                <div>
                  <h2 class="biz-product-name">{{ product.name }}</h2>
                  <p class="biz-product-tagline">{{ product.tagline }}</p>
                </div>
              </div>
              <p class="biz-product-desc">{{ product.description }}</p>
              <ul class="biz-feature-list">
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
                @click="track('cta_click', { label: `biz_${product.id}` })"
              >{{ product.cta.text }} →</a>
              <router-link
                v-else
                :to="product.cta.href"
                class="btn-primary inline-block mt-8 px-6 py-2.5"
                @click="track('cta_click', { label: `biz_${product.id}` })"
              >{{ product.cta.text }} →</router-link>
            </div>
            <!-- Visual side -->
            <div class="biz-product-visual" :style="{ '--prod-color': product.color }">
              <div class="biz-product-visual-inner">
                <div class="biz-product-visual-icon">
                  <svg class="w-10 h-10" :style="{ color: product.color }" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.2" :d="product.iconPath" />
                  </svg>
                </div>
                <p class="biz-product-visual-name">{{ product.name }}</p>
                <p class="biz-product-visual-tag">{{ product.tagline }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Industry Solutions -->
    <section class="section-dark py-20" aria-label="行业解决方案">
      <div class="max-w-5xl mx-auto px-6 sm:px-8 lg:px-12">
        <div class="text-center mb-12 reveal-fade-up">
          <h2 class="biz-section-title">行业解决方案</h2>
          <p class="biz-section-sub">每个行业都有专属的产品组合</p>
        </div>
        <div class="biz-industry-grid reveal-fade-up">
          <router-link
            v-for="industry in industries"
            :key="industry.name"
            to="/solutions"
            class="biz-industry-card"
          >
            <h3 class="biz-industry-name">{{ industry.name }}</h3>
            <p class="biz-industry-desc">{{ industry.desc }}</p>
            <p class="biz-industry-products">{{ industry.products }}</p>
          </router-link>
        </div>
      </div>
    </section>

    <!-- Bundle CTA -->
    <section class="section-dark-raised py-24" aria-label="企业套餐">
      <div class="max-w-4xl mx-auto px-6 sm:px-8 lg:px-12 text-center reveal-fade-up">
        <h2 class="biz-section-title">企业 AI 套餐</h2>
        <p class="biz-section-sub biz-section-sub--wide">
          Lurus API + Switch (团队版) + Lucrum Pro + Identity SSO — 企业级 AI 基础设施，开箱即用。
        </p>
        <div class="biz-cta-row mt-10">
          <a href="mailto:support@lurus.cn" class="btn-primary px-8 py-3 text-base">联系销售</a>
          <a href="https://api.lurus.cn" target="_blank" rel="noopener noreferrer" class="btn-outline px-8 py-3 text-base">注册试用</a>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";

/* Hero */
.biz-hero {
  position: relative;
  overflow: hidden;
}

.biz-hero-glow {
  position: absolute;
  top: 10%;
  left: 50%;
  transform: translateX(-50%);
  width: 600px;
  height: 350px;
  background: radial-gradient(ellipse, rgba(212,168,39,0.09) 0%, transparent 70%);
  pointer-events: none;
}

.biz-eyebrow {
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

.biz-title {
  font-size: clamp(2.5rem, 6vw, 4rem);
  font-weight: 800;
  color: var(--color-text-primary);
  line-height: 1.1;
  letter-spacing: -0.03em;
  margin-bottom: 20px;
}

.biz-subtitle {
  font-size: 1.15rem;
  color: var(--color-text-secondary);
  max-width: 520px;
  margin: 0 auto 36px;
  line-height: 1.65;
}

.biz-cta-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

/* Products */
.biz-product {
  margin-bottom: 80px;
}

.biz-product--last {
  margin-bottom: 0;
}

.biz-product-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 56px;
  align-items: center;
}

@media (max-width: 767px) {
  .biz-product-grid {
    grid-template-columns: 1fr;
    gap: 32px;
  }
  .biz-product-grid--flip > *:first-child { order: 0; }
}

@media (min-width: 768px) {
  .biz-product-grid--flip > *:first-child { order: 2; }
  .biz-product-grid--flip > *:last-child  { order: 1; }
}

.biz-product-header {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 16px;
}

.biz-product-icon {
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

.biz-product-name {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--color-text-primary);
  line-height: 1.3;
}

.biz-product-tagline {
  font-size: 0.82rem;
  color: var(--color-text-muted);
  margin-top: 2px;
}

.biz-product-desc {
  font-size: 0.95rem;
  color: var(--color-text-secondary);
  line-height: 1.7;
  margin-bottom: 20px;
}

.biz-feature-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.biz-feature-list li {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 0.875rem;
  color: var(--color-text-secondary);
}

.biz-product-visual {
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  border-radius: 16px;
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  transition: border-color 0.2s;
}

.biz-product-visual::before {
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

.biz-product-visual-inner {
  text-align: center;
  padding: 32px;
}

.biz-product-visual-icon {
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

.biz-product-visual-name {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text-secondary);
}

.biz-product-visual-tag {
  font-size: 0.78rem;
  color: var(--color-text-muted);
  margin-top: 4px;
}

/* Industry grid */
.biz-section-title {
  font-size: clamp(1.75rem, 4vw, 2.5rem);
  font-weight: 800;
  color: var(--color-text-primary);
  letter-spacing: -0.03em;
  margin-bottom: 12px;
}

.biz-section-sub {
  font-size: 1rem;
  color: var(--color-text-secondary);
  max-width: 400px;
  margin: 0 auto;
  line-height: 1.65;
}

.biz-section-sub--wide {
  max-width: 560px;
  margin-top: 12px;
  margin-bottom: 0;
}

.biz-industry-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 14px;
}

@media (min-width: 640px) {
  .biz-industry-grid { grid-template-columns: repeat(4, 1fr); }
}

.biz-industry-card {
  display: block;
  padding: 20px 18px;
  background-color: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  border-radius: 12px;
  text-align: center;
  text-decoration: none;
  transition: border-color 0.2s, transform 0.2s;
}

.biz-industry-card:hover {
  border-color: rgba(212, 168, 39, 0.4);
  transform: translateY(-2px);
}

.biz-industry-name {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text-primary);
  margin-bottom: 6px;
}

.biz-industry-desc {
  font-size: 0.75rem;
  color: var(--color-text-muted);
  line-height: 1.5;
  margin-bottom: 8px;
}

.biz-industry-products {
  font-size: 0.72rem;
  font-weight: 600;
  color: var(--color-ochre);
}
</style>
