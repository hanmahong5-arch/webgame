<script setup lang="ts">
import { ref, defineAsyncComponent } from 'vue'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useTracking } from '../composables/useTracking'
import { getProductsForAudience } from '../data/products'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
const { track } = useTracking()

const products = getProductsForAudience('builder')

// Lazy-loaded diagram components keyed by product ID
const diagramComponents: Record<string, ReturnType<typeof defineAsyncComponent>> = {
  kova: defineAsyncComponent(() => import('../components/Illustrations/KovaDiagram.vue')),
  lumen: defineAsyncComponent(() => import('../components/Illustrations/LumenDiagram.vue')),
  memx: defineAsyncComponent(() => import('../components/Illustrations/MemxGraphDiagram.vue')),
  api: defineAsyncComponent(() => import('../components/Illustrations/ApiFlowDiagram.vue')),
}

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
              <!-- Diagram component (lazy-loaded) -->
              <component
                :is="diagramComponents[product.id]"
                v-if="diagramComponents[product.id]"
                class="builder-diagram"
                :aria-label="`${product.name} diagram`"
              />

              <!-- Fallback: code block when no diagram but fallbackCode exists -->
              <div
                v-else-if="product.showcase?.fallbackCode"
                class="builder-code-block"
                role="region"
                :aria-label="product.showcase.fallbackAriaLabel ?? `${product.name} code example`"
              >
                <div class="builder-code-bar" aria-hidden="true">
                  <span class="builder-code-dot" style="background:#FF5F57"></span>
                  <span class="builder-code-dot" style="background:#FEBC2E"></span>
                  <span class="builder-code-dot" style="background:#28C840"></span>
                  <span class="builder-code-lang">{{ product.showcase.fallbackLanguage ?? 'code' }}</span>
                </div>
                <pre class="builder-code-pre"><code>{{ product.showcase.fallbackCode }}</code></pre>
              </div>

              <!-- Fallback: icon placeholder when neither diagram nor code is available -->
              <div v-else class="builder-visual-inner">
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

/* Diagram fills the visual container */
.builder-diagram {
  width: 100%;
  height: 100%;
  min-height: 200px;
  padding: 16px;
  box-sizing: border-box;
}

/* Code block */
.builder-code-block {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.builder-code-bar {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 14px 8px;
  border-bottom: 1px solid var(--color-surface-border);
}

.builder-code-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
  flex-shrink: 0;
}

.builder-code-lang {
  margin-left: auto;
  font-size: 0.7rem;
  font-family: ui-monospace, monospace;
  color: var(--color-text-muted);
  text-transform: lowercase;
}

.builder-code-pre {
  margin: 0;
  padding: 16px;
  overflow-x: auto;
  font-size: 0.75rem;
  font-family: ui-monospace, monospace;
  line-height: 1.6;
  color: var(--color-text-secondary);
  white-space: pre;
  flex: 1;
}

.builder-code-pre code {
  font-family: inherit;
  background: none;
  padding: 0;
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
