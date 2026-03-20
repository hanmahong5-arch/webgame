<script setup lang="ts">
import { ref, defineAsyncComponent } from 'vue'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useTracking } from '../composables/useTracking'
import { useAuth } from '../composables/useAuth'
import PricingPreview from '../components/Pricing/PricingPreview.vue'
import { getProductsForAudience } from '../data/products'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
const { track } = useTracking()
const { login } = useAuth()

const products = getProductsForAudience('explorer')

// Lazy-loaded diagram components keyed by product ID
const diagramComponents: Record<string, ReturnType<typeof defineAsyncComponent>> = {
  creator: defineAsyncComponent(() => import('../components/Illustrations/CreatorDiagram.vue')),
  lucrum:  defineAsyncComponent(() => import('../components/Illustrations/LucrumChartDiagram.vue')),
  switch:  defineAsyncComponent(() => import('../components/Illustrations/SwitchDiagram.vue')),
  memx:    defineAsyncComponent(() => import('../components/Illustrations/MemxGraphDiagram.vue')),
}
</script>

<template>
  <div ref="pageRef">
    <!-- Hero -->
    <section id="hero" class="relative overflow-hidden section-dark py-24">
      <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <span
          class="inline-block text-xs font-semibold uppercase tracking-wider px-3 py-1 rounded-full mb-6"
          style="background-color: #5C7A8B20; color: #5C7A8B;"
        >
          探索者
        </span>
        <h1 class="text-phi-2xl md:text-phi-3xl lg:text-[58px] text-[var(--color-text-primary)] mb-6 leading-tight font-bold reveal-fade-up">
          用 AI 武装你的
          <span class="text-gradient-gold">每一天</span>
        </h1>
        <p class="text-phi-lg text-[var(--color-text-secondary)] max-w-2xl mx-auto leading-relaxed mb-10 reveal-fade-up">
          视频内容创作、量化交易、工具管理、持久记忆 — 个人效率的无限延伸
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center reveal-fade-up">
          <router-link to="/download" class="btn-primary text-center">
            下载开始
          </router-link>
          <button @click="login({ prompt: 'create' })" class="btn-outline text-center">
            免费注册
          </button>
        </div>
      </div>
    </section>

    <!-- Products -->
    <section class="py-24 section-dark-raised" aria-label="产品列表">
      <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <div
          v-for="(product, index) in products"
          :id="product.id"
          :key="product.id"
          class="mb-24 last:mb-0 reveal-fade-up"
        >
          <div
            class="grid grid-cols-1 md:grid-cols-2 gap-8 items-center"
            :class="index % 2 === 1 ? 'md:[direction:rtl] md:[&>*]:[direction:ltr]' : ''"
          >
            <!-- Text side -->
            <div>
              <div class="flex items-center gap-3 mb-4">
                <div
                  class="w-10 h-10 rounded-lg flex items-center justify-center border border-[var(--color-surface-border)] shrink-0"
                  :style="{ backgroundColor: product.color + '20' }"
                >
                  <svg
                    class="w-5 h-5"
                    :style="{ color: product.color }"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                    aria-hidden="true"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="product.iconPath" />
                  </svg>
                </div>
                <div>
                  <h2 class="text-xl font-bold text-[var(--color-text-primary)]">{{ product.name }}</h2>
                  <p class="text-sm text-[var(--color-text-muted)]">{{ product.tagline }}</p>
                </div>
              </div>
              <p class="text-[var(--color-text-secondary)] leading-relaxed mb-6">{{ product.description }}</p>
              <ul class="space-y-2 mb-6">
                <li
                  v-for="feature in product.features"
                  :key="feature"
                  class="flex items-center gap-2 text-sm text-[var(--color-text-secondary)]"
                >
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
                class="btn-primary inline-block"
                @click="track('cta_click', { label: `explorer_${product.id}` })"
              >
                {{ product.cta.text }}
              </a>
              <router-link
                v-else
                :to="product.cta.href"
                class="btn-primary inline-block"
                @click="track('cta_click', { label: `explorer_${product.id}` })"
              >
                {{ product.cta.text }}
              </router-link>
            </div>

            <!-- Visual side -->
            <div class="diagram-wrapper" :style="{ '--product-color': product.color }">
              <!-- SVG diagram component when available -->
              <template v-if="diagramComponents[product.id]">
                <Suspense>
                  <component :is="diagramComponents[product.id]" />
                  <template #fallback>
                    <div class="diagram-loading" aria-hidden="true">
                      <div class="diagram-loading-icon" :style="{ backgroundColor: product.color + '15' }">
                        <svg class="w-8 h-8" :style="{ color: product.color }" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="product.iconPath" />
                        </svg>
                      </div>
                    </div>
                  </template>
                </Suspense>
              </template>

              <!-- Fallback: code block when showcase.fallbackCode exists -->
              <template v-else-if="product.showcase?.fallbackCode">
                <pre
                  class="diagram-code"
                  :aria-label="product.showcase.fallbackAriaLabel ?? `${product.name} 示例`"
                ><code>{{ product.showcase.fallbackCode }}</code></pre>
              </template>

              <!-- Minimal icon placeholder as last resort -->
              <template v-else>
                <div class="diagram-icon-placeholder">
                  <div
                    class="diagram-icon-box"
                    :style="{ backgroundColor: product.color + '15' }"
                  >
                    <svg class="w-8 h-8" :style="{ color: product.color }" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="product.iconPath" />
                    </svg>
                  </div>
                  <p class="diagram-icon-label">{{ product.name }}</p>
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Pricing Preview -->
    <div id="pricing-preview">
      <PricingPreview />
    </div>

    <!-- Bundle CTA -->
    <section id="bundle" class="py-24 section-dark" aria-label="个人套餐">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
        <h2 class="text-phi-2xl text-[var(--color-text-primary)] mb-4 font-semibold">个人智能套餐</h2>
        <p class="text-[var(--color-text-secondary)] max-w-2xl mx-auto mb-10 leading-relaxed">
          Creator + MemX + Switch + API 个人配额 — 一个订阅，完整的 AI 桌面体验。
          Creator 制作内容，MemX 持久记忆，Switch 管理工具，API 驱动一切。
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <router-link to="/pricing" class="btn-primary text-center">查看定价</router-link>
          <button @click="login({ prompt: 'create' })" class="btn-outline text-center">免费开始</button>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";

/* Diagram container — cream-tinted panel with subtle product-color glow */
.diagram-wrapper {
  position: relative;
  background-color: var(--color-surface-overlay);
  border: 1.5px solid var(--color-surface-border);
  border-radius: 16px;
  min-height: 220px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  padding: 24px;
}

/* Soft radial glow in the top-right corner tinted by product color */
.diagram-wrapper::before {
  content: '';
  position: absolute;
  top: -48px;
  right: -48px;
  width: 160px;
  height: 160px;
  border-radius: 50%;
  background: radial-gradient(circle, var(--product-color, #C67B5C), transparent 70%);
  opacity: 0.10;
  pointer-events: none;
}

/* SVG diagrams fill the container */
.diagram-wrapper :deep(svg) {
  width: 100%;
  height: 100%;
  max-height: 240px;
  display: block;
}

/* Loading skeleton while async component resolves */
.diagram-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  min-height: 160px;
}

.diagram-loading-icon {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  border: 2px solid var(--color-surface-border);
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Code fallback block */
.diagram-code {
  width: 100%;
  font-size: 0.75rem;
  font-family: ui-monospace, monospace;
  color: var(--color-text-muted);
  background: transparent;
  white-space: pre-wrap;
  word-break: break-all;
  line-height: 1.65;
  margin: 0;
  padding: 0;
}

/* Icon-only fallback */
.diagram-icon-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.diagram-icon-box {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  border: 2px solid var(--color-surface-border);
  display: flex;
  align-items: center;
  justify-content: center;
}

.diagram-icon-label {
  font-size: 0.85rem;
  color: var(--color-text-muted);
}
</style>
