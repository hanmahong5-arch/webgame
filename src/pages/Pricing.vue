<script setup lang="ts">
import { ref, computed } from 'vue'
import type { BillingCycle, AudienceTierCode, ProductPricing } from '../types/pricing'
import {
  AUDIENCE_TIERS,
  AUDIENCE_PRODUCTS,
  COMPARISON_FEATURES,
  PRICING_FAQ,
} from '../config/pricing'
import { useAccountOverview } from '../composables/useAccountOverview'
import { useAuth } from '../composables/useAuth'

const { overview } = useAccountOverview()
const { isLoggedIn, login } = useAuth()

const billingCycle = ref<BillingCycle>('monthly')
const selectedAudience = ref<AudienceTierCode>('personal')
const openFaqIndex = ref<number | null>(null)

const currentProducts = computed(() => AUDIENCE_PRODUCTS[selectedAudience.value])

function isCurrentPlan(product: ProductPricing): boolean {
  if (!overview.value?.subscription) return false
  return overview.value.subscription.plan_code === product.id
}

function handleCta(product: ProductPricing) {
  if (!isLoggedIn.value) {
    login({ returnUrl: '/pricing' })
    return
  }
  window.open('https://identity.lurus.cn/wallet/topup', '_blank', 'noopener,noreferrer')
}

function displayPrice(product: ProductPricing): string {
  const price = billingCycle.value === 'yearly' ? product.yearlyPrice : product.monthlyPrice
  if (price === null) return '联系我们'
  if (price === 0) return '免费'
  return `¥${price}`
}

function priceIsContact(product: ProductPricing): boolean {
  const price = billingCycle.value === 'yearly' ? product.yearlyPrice : product.monthlyPrice
  return price === null
}

function toggleFaq(index: number) {
  openFaqIndex.value = openFaqIndex.value === index ? null : index
}
</script>

<template>
  <div>
    <!-- S1: Hero + Billing Toggle -->
    <section id="pricing-hero" class="section-dark py-16 md:py-20 text-center relative overflow-hidden">
      <div
        class="absolute inset-0 opacity-[0.03]"
        aria-hidden="true"
        style="background-image: linear-gradient(var(--color-surface-border) 1px, transparent 1px), linear-gradient(90deg, var(--color-surface-border) 1px, transparent 1px); background-size: 40px 40px;"
      ></div>
      <div class="relative max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full border border-surface-border bg-surface-overlay text-xs text-text-muted mb-5">
          <span class="w-1.5 h-1.5 rounded-full bg-ochre inline-block"></span>
          透明定价，按需付费
        </div>
        <h1 class="text-4xl sm:text-5xl font-bold text-text-primary mb-4">
          <span class="text-gradient-gold">简单定价</span>
        </h1>
        <p class="text-text-secondary text-lg mb-10">选择适合你的方案，从免费开始，随时升级</p>

        <!-- Billing toggle -->
        <div class="inline-flex items-center gap-1 p-1 rounded-full bg-surface-overlay border border-surface-border">
          <button
            class="billing-tab"
            :class="{ 'billing-tab--active': billingCycle === 'monthly' }"
            @click="billingCycle = 'monthly'"
          >
            按月付费
          </button>
          <button
            class="billing-tab"
            :class="{ 'billing-tab--active': billingCycle === 'yearly' }"
            @click="billingCycle = 'yearly'"
          >
            按年付费
            <span class="ml-2 text-[10px] px-1.5 py-0.5 rounded-full bg-ochre/20 text-ochre font-semibold">省 20%</span>
          </button>
        </div>
      </div>
    </section>

    <!-- S2: Audience Selector -->
    <section id="audience-selector" class="section-dark-raised py-6 border-b border-surface-border sticky top-16 z-10">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-center gap-3 flex-wrap" role="tablist" aria-label="受众类型">
          <button
            v-for="tier in AUDIENCE_TIERS"
            :key="tier.code"
            role="tab"
            :aria-selected="selectedAudience === tier.code"
            :aria-label="`${tier.name} — ${tier.tagline}`"
            class="audience-tab"
            :class="{ 'audience-tab--active': selectedAudience === tier.code }"
            @click="selectedAudience = tier.code"
          >
            <span class="text-base">{{ tier.icon }}</span>
            <span>{{ tier.name }}</span>
            <span class="hidden sm:inline text-xs text-text-muted ml-1">· {{ tier.tagline }}</span>
          </button>
        </div>
      </div>
    </section>

    <!-- S3: Product Pricing Cards -->
    <section id="pricing-cards" class="section-dark py-16">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- Balance display for logged-in users -->
        <div v-if="overview" class="text-center text-sm text-text-muted mb-4">
          当前余额: <span class="font-mono tabular-nums">{{ (overview.wallet?.balance ?? 0).toFixed(2) }} LB</span>
        </div>
        <div class="pricing-grid">
          <div
            v-for="product in currentProducts"
            :key="product.id"
            class="pricing-card"
            :class="{
              'pricing-card--popular': product.popular,
              'pricing-card--soon': product.status === 'coming_soon',
              'pricing-card--current': isLoggedIn && isCurrentPlan(product),
            }"
          >
            <div v-if="product.popular" class="pricing-popular-badge">推荐</div>
            <div v-if="product.status === 'coming_soon'" class="pricing-soon-badge">即将推出</div>

            <h3 class="text-lg font-semibold text-text-primary mb-1">{{ product.name }}</h3>
            <p class="text-sm text-text-muted mb-6">{{ product.description }}</p>

            <!-- Price display -->
            <div class="mb-6">
              <template v-if="priceIsContact(product)">
                <span class="text-2xl font-bold text-text-primary">联系我们</span>
              </template>
              <template v-else-if="displayPrice(product) === '免费'">
                <span class="text-3xl font-bold text-text-primary">免费</span>
              </template>
              <template v-else>
                <span class="text-3xl font-bold text-text-primary">{{ displayPrice(product) }}</span>
                <span class="text-text-muted text-sm ml-1">/ {{ product.unit }}</span>
              </template>
              <div
                v-if="billingCycle === 'yearly' && product.yearlyPrice !== null && product.monthlyPrice !== null && product.monthlyPrice !== 0 && product.yearlyPrice !== product.monthlyPrice"
                class="text-xs text-text-muted mt-1"
              >
                原价 <span class="line-through">¥{{ product.monthlyPrice }}/月</span>
              </div>
            </div>

            <!-- Features -->
            <ul class="space-y-2.5 mb-8 flex-1">
              <li v-for="feature in product.features" :key="feature" class="flex items-start gap-2 text-sm text-text-secondary">
                <svg class="w-4 h-4 text-ochre shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                {{ feature }}
              </li>
            </ul>

            <!-- CTA button -->
            <template v-if="product.status === 'coming_soon'">
              <button disabled class="w-full py-2.5 px-4 rounded-lg border border-surface-border text-text-muted text-sm cursor-not-allowed">
                敬请期待
              </button>
            </template>
            <template v-else-if="priceIsContact(product)">
              <a
                href="mailto:enterprise@lurus.cn"
                class="block w-full py-2.5 px-4 rounded-lg border border-ochre text-ochre text-sm font-medium text-center hover:bg-ochre/10 transition-colors"
              >
                联系销售
              </a>
            </template>
            <template v-else-if="isLoggedIn && isCurrentPlan(product)">
              <button
                disabled
                class="w-full py-2.5 px-4 rounded-lg border border-ochre/50 bg-ochre/10 text-ochre text-sm font-medium cursor-default"
              >
                当前方案
              </button>
            </template>
            <template v-else-if="displayPrice(product) === '免费'">
              <button
                v-if="!isLoggedIn"
                class="w-full py-2.5 px-4 rounded-lg bg-surface-overlay border border-surface-border text-text-secondary text-sm font-medium hover:border-ochre/40 hover:text-text-primary transition-colors"
                @click="login({ returnUrl: '/pricing' })"
              >
                免费开始
              </button>
              <button
                v-else
                disabled
                class="w-full py-2.5 px-4 rounded-lg bg-surface-overlay border border-surface-border text-text-muted text-sm font-medium cursor-default"
              >
                已登录
              </button>
            </template>
            <template v-else>
              <button
                v-if="!isLoggedIn"
                :class="product.popular ? 'btn-primary' : 'btn-outline'"
                class="w-full text-center text-sm"
                @click="login({ returnUrl: '/pricing' })"
              >
                立即订阅
              </button>
              <button
                v-else
                :class="product.popular ? 'btn-primary' : 'btn-outline'"
                class="w-full text-center text-sm"
                @click="handleCta(product)"
              >
                立即订阅
              </button>
            </template>
          </div>
        </div>
      </div>
    </section>

    <!-- S4: Top-up CTA -->
    <section class="section-dark-raised py-12">
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <div class="topup-card">
          <div class="flex items-center justify-center w-10 h-10 rounded-full bg-ochre/15 mx-auto mb-4">
            <svg class="w-5 h-5 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
          </div>
          <h3 class="text-xl font-semibold text-text-primary mb-2">需要更多 Token？随时充值</h3>
          <p class="text-text-muted text-sm mb-6">套餐配额不够用？可以在控制台直接充值，按需补充额度，即充即用。</p>
          <a
            href="https://identity.lurus.cn/wallet/topup"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-primary inline-flex items-center gap-2"
          >
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            前往充值
          </a>
        </div>
      </div>
    </section>

    <!-- S5: Comparison Table -->
    <section id="comparison" class="section-dark py-16">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-2xl sm:text-3xl font-bold text-text-primary mb-10 text-center">功能对比</h2>
        <div class="comparison-table">
          <div class="comparison-header">
            <div class="comparison-feature-col">功能</div>
            <div class="comparison-tier-col">个人</div>
            <div class="comparison-tier-col">团队</div>
            <div class="comparison-tier-col">平台</div>
          </div>
          <div
            v-for="(feature, index) in COMPARISON_FEATURES"
            :key="feature.name"
            class="comparison-row"
            :class="{ 'comparison-row--alt': index % 2 === 1 }"
          >
            <div class="comparison-feature-col text-text-secondary">{{ feature.name }}</div>
            <div class="comparison-tier-col">
              <template v-if="feature.personal === true">
                <svg class="w-4 h-4 text-ochre inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
              </template>
              <span v-else-if="feature.personal === false" class="text-text-muted">—</span>
              <span v-else class="text-text-secondary text-sm">{{ feature.personal }}</span>
            </div>
            <div class="comparison-tier-col">
              <template v-if="feature.team === true">
                <svg class="w-4 h-4 text-ochre inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
              </template>
              <span v-else-if="feature.team === false" class="text-text-muted">—</span>
              <span v-else class="text-text-secondary text-sm">{{ feature.team }}</span>
            </div>
            <div class="comparison-tier-col">
              <template v-if="feature.platform === true">
                <svg class="w-4 h-4 text-ochre inline" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
              </template>
              <span v-else-if="feature.platform === false" class="text-text-muted">—</span>
              <span v-else class="text-text-secondary text-sm">{{ feature.platform }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- S6: Payment Methods -->
    <section class="section-dark-raised py-12 border-y border-surface-border">
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <p class="text-text-muted text-sm mb-6">支持多种支付方式</p>
        <div class="flex items-center justify-center gap-4 flex-wrap">
          <div v-for="method in ['支付宝', '微信支付', '银行卡', '对公转账', 'Stripe']" :key="method" class="payment-badge">
            {{ method }}
          </div>
        </div>
      </div>
    </section>

    <!-- S7: FAQ -->
    <section id="faq" class="section-dark py-16">
      <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-2xl sm:text-3xl font-bold text-text-primary mb-10 text-center">常见问题</h2>
        <div class="space-y-2">
          <div v-for="(faq, index) in PRICING_FAQ" :key="index" class="faq-item">
            <button
              class="faq-question"
              :aria-expanded="openFaqIndex === index"
              @click="toggleFaq(index)"
            >
              <span>{{ faq.question }}</span>
              <svg
                class="w-4 h-4 text-text-muted transition-transform duration-200 shrink-0"
                :class="{ 'rotate-180': openFaqIndex === index }"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            <div v-if="openFaqIndex === index" class="faq-answer">{{ faq.answer }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- S8: Enterprise CTA -->
    <section class="section-dark-raised py-20 border-t border-surface-border">
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full border border-ochre/30 bg-ochre/10 text-xs text-ochre mb-6">
          企业级方案
        </div>
        <h2 class="text-3xl sm:text-4xl font-bold text-text-primary mb-4">需要大规模方案？</h2>
        <p class="text-text-secondary mb-8">定制配额、专属部署、SLA 保障——我们的企业方案满足你的一切需求。</p>
        <div class="flex items-center justify-center gap-4 flex-wrap">
          <a href="mailto:enterprise@lurus.cn" class="btn-primary">联系企业销售</a>
          <a
            href="https://docs.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-outline"
          >查看文档</a>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";

/* Billing toggle */
.billing-tab {
  display: inline-flex;
  align-items: center;
  padding: 8px 20px;
  border-radius: 9999px;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-text-muted);
  background: none;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}
.billing-tab--active {
  background-color: var(--color-ochre);
  color: #0D0B09;
  font-weight: 600;
}

/* Audience tabs */
.audience-tab {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-text-secondary);
  background: none;
  border: 1px solid transparent;
  cursor: pointer;
  transition: all 0.2s ease;
}
.audience-tab:hover {
  color: var(--color-text-primary);
  border-color: var(--color-surface-border);
}
.audience-tab--active {
  color: var(--color-text-primary);
  border-color: rgba(212, 168, 39, 0.4);
  background-color: var(--color-surface-overlay);
}

/* Pricing grid */
.pricing-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 16px;
  align-items: start;
}

.pricing-card {
  position: relative;
  display: flex;
  flex-direction: column;
  padding: 24px;
  border-radius: 12px;
  background-color: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  transition: border-color 0.2s ease;
}
.pricing-card:hover {
  border-color: rgba(212, 168, 39, 0.3);
}
.pricing-card--popular {
  border-color: rgba(212, 168, 39, 0.5);
}
.pricing-card--soon {
  opacity: 0.7;
}
.pricing-card--current {
  border-color: rgba(212, 168, 39, 0.6);
  box-shadow: 0 0 0 1px rgba(212, 168, 39, 0.2);
}

.pricing-popular-badge {
  position: absolute;
  top: -12px;
  left: 50%;
  transform: translateX(-50%);
  padding: 3px 12px;
  border-radius: 9999px;
  background-color: var(--color-ochre);
  color: #0D0B09;
  font-size: 11px;
  font-weight: 700;
  white-space: nowrap;
}
.pricing-soon-badge {
  display: inline-flex;
  align-self: flex-start;
  margin-bottom: 8px;
  padding: 2px 8px;
  border-radius: 4px;
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  color: var(--color-text-muted);
  font-size: 11px;
  font-weight: 500;
}

/* Top-up card */
.topup-card {
  padding: 32px;
  border-radius: 12px;
  background-color: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
}

/* Comparison table */
.comparison-table {
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid var(--color-surface-border);
}
.comparison-header {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr;
  padding: 12px 16px;
  background-color: var(--color-surface-overlay);
  font-size: 13px;
  font-weight: 600;
  color: var(--color-text-primary);
}
.comparison-row {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr;
  padding: 12px 16px;
  background-color: var(--color-surface-raised);
  border-top: 1px solid var(--color-surface-border);
}
.comparison-row--alt {
  background-color: var(--color-surface-base);
}
.comparison-feature-col {
  font-size: 13px;
}
.comparison-tier-col {
  font-size: 13px;
  text-align: center;
}

@media (max-width: 640px) {
  .comparison-header,
  .comparison-row {
    grid-template-columns: 1.5fr 1fr 1fr 1fr;
    padding: 10px 10px;
    gap: 4px;
  }
  .comparison-feature-col,
  .comparison-tier-col {
    font-size: 12px;
  }
}

/* Payment methods */
.payment-badge {
  padding: 6px 16px;
  border-radius: 6px;
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  font-size: 13px;
  color: var(--color-text-secondary);
}

/* FAQ */
.faq-item {
  border-radius: 8px;
  background-color: var(--color-surface-raised);
  border: 1px solid var(--color-surface-border);
  overflow: hidden;
}
.faq-question {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding: 16px 20px;
  text-align: left;
  background: none;
  border: none;
  color: var(--color-text-primary);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  gap: 12px;
  transition: color 0.15s ease;
}
.faq-question:hover {
  color: var(--color-ochre);
}
.faq-answer {
  padding: 0 20px 16px;
  font-size: 13px;
  color: var(--color-text-secondary);
  line-height: 1.7;
  border-top: 1px solid var(--color-surface-border);
}
</style>
