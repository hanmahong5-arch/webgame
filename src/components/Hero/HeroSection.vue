<script setup lang="ts">
import { products } from '../../data/products'
import PrimaryButton from '../CTAs/PrimaryButton.vue'
import SecondaryButton from '../CTAs/SecondaryButton.vue'

const infraProducts = products.filter((p) => p.layer === 'infra').map((p) => ({
  name: p.name,
  color: p.bgColor,
}))

const appProducts = products.filter((p) => p.layer === 'app').map((p) => ({
  name: p.name,
  color: p.bgColor,
}))

const floatingDots = [
  { id: 1, left: '15%', top: '20%', delay: '0s', duration: '6s' },
  { id: 2, left: '72%', top: '35%', delay: '1.5s', duration: '5s' },
  { id: 3, left: '40%', top: '70%', delay: '3s', duration: '7s' },
  { id: 4, left: '85%', top: '55%', delay: '4s', duration: '5.5s' },
]
</script>

<template>
  <section aria-label="Hero" class="relative min-h-golden-vh overflow-hidden bg-cream-50">
    <!-- Paper texture background -->
    <div class="absolute inset-0 pointer-events-none">
      <!-- Subtle grid pattern like notebook paper -->
      <div class="absolute inset-0 opacity-[0.03]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>

      <!-- Corner doodles -->
      <div class="doodle-corner top-12 left-12"></div>
      <div class="doodle-corner top-12 right-12 -scale-x-100"></div>
      <div class="doodle-corner bottom-24 left-12 -scale-y-100"></div>
      <div class="doodle-corner bottom-24 right-12 scale-[-1]"></div>

      <!-- Floating decorative elements (static positions for render stability) -->
      <div
        v-for="dot in floatingDots"
        :key="dot.id"
        class="absolute w-3 h-3 rounded-full bg-ochre/20 animate-float"
        :style="{ left: dot.left, top: dot.top, animationDelay: dot.delay, animationDuration: dot.duration }"
      ></div>
    </div>

    <!-- Main content: Two-column grid -->
    <div class="relative z-10 max-w-[1200px] mx-auto px-4 sm:px-6 lg:px-8 py-fib-7 pt-24">
      <div class="hero-grid">
        <!-- Left column: Value proposition -->
        <div class="hero-left">
          <!-- Logo Badge -->
          <div class="inline-flex items-center gap-3 px-6 py-3 border-sketchy bg-cream-100 mb-fib-6 hover:shadow-paper-hover transition-all">
            <div class="w-10 h-10 rounded-lg bg-ochre flex items-center justify-center border-2 border-ink-300">
              <span class="text-cream-50 font-hand font-bold text-xl">L</span>
            </div>
            <span class="text-ink-700 font-medium">Lurus Technology</span>
            <span class="w-2 h-2 rounded-full bg-product-gushen animate-pulse"></span>
          </div>

          <!-- Main Headline -->
          <h1 class="text-phi-2xl md:text-phi-3xl lg:text-[68px] text-ink-900 mb-fib-4 leading-tight font-bold">
            <span class="block mb-2">统一接入全球 AI 模型</span>
            <span class="text-gradient-ochre font-hand">一个 API，所有模型</span>
          </h1>

          <!-- Subheadline -->
          <p class="text-phi-lg md:text-phi-xl text-ink-500 mb-fib-6 leading-relaxed max-w-xl">
            OpenAI 兼容接口，50+ 主流大模型一键调用。内置智能路由与负载均衡，
            让你专注于 <span class="text-ink-900 font-medium underline-doodle">产品开发</span>，
            而非 <span class="text-ink-900 font-medium underline-doodle">基础设施</span>
          </p>

          <!-- CTA Buttons -->
          <div class="flex flex-col sm:flex-row gap-fib-4 mb-fib-5">
            <PrimaryButton
              text="获取 API Key"
              href="https://api.lurus.cn"
              target="_blank"
              ariaLabel="跳转到 API Key 注册页面"
              trackLocation="hero"
            />
            <SecondaryButton
              text="查看文档"
              href="https://docs.lurus.cn"
              target="_blank"
              ariaLabel="跳转到文档站点"
            />
          </div>

          <!-- Product Tags: infra group + app group -->
          <div>
            <p class="text-xs text-ink-300 mb-1.5 uppercase tracking-wide">核心基础设施</p>
            <div class="flex flex-wrap gap-fib-3 mb-fib-4">
              <div
                v-for="product in infraProducts"
                :key="product.name"
                class="group px-5 py-2.5 border-sketchy bg-cream-100 hover:shadow-paper-hover transition-all cursor-pointer"
                style="border-color: #C9A227;"
              >
                <div class="flex items-center gap-2">
                  <div
                    class="w-3 h-3 rounded-full transition-all duration-300 group-hover:scale-125"
                    :style="{ backgroundColor: product.color }"
                  ></div>
                  <span class="text-sm font-medium text-ink-700 group-hover:text-ink-900 transition-colors">{{ product.name }}</span>
                </div>
              </div>
            </div>
            <p class="text-xs text-ink-300 mb-1.5 uppercase tracking-wide">应用产品</p>
            <div class="flex flex-wrap gap-fib-3">
              <div
                v-for="product in appProducts"
                :key="product.name"
                class="group px-4 py-2 border-sketchy-light bg-cream-100 hover:shadow-paper-hover transition-all cursor-pointer"
              >
                <div class="flex items-center gap-2">
                  <div
                    class="w-2.5 h-2.5 rounded-full transition-all duration-300 group-hover:scale-125"
                    :style="{ backgroundColor: product.color }"
                  ></div>
                  <span class="text-sm text-ink-500 group-hover:text-ink-900 transition-colors">{{ product.name }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Right column: Tech demo slot -->
        <div class="hero-right card-sketchy bg-cream-50">
          <slot name="right">
            <!-- Default fallback: empty state -->
          </slot>
        </div>
      </div>
    </div>

    <!-- Scroll Indicator -->
    <div class="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
      <svg class="w-6 h-6 text-ink-300" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
      </svg>
    </div>
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

.hero-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 34px;
  align-items: center;
}

/* Tablet: 55/45 split */
@media (min-width: 768px) {
  .hero-grid {
    grid-template-columns: 55fr 45fr;
    gap: 34px;
  }
}

/* Desktop: 60/40 split (3fr 2fr) */
@media (min-width: 1024px) {
  .hero-grid {
    grid-template-columns: 3fr 2fr;
    gap: 55px;
  }
}

.hero-left {
  text-align: left;
}

.hero-right {
  display: flex;
  align-items: center;
  justify-content: center;
  order: 1;
}

/* Tablet+: reset order for side-by-side layout */
@media (min-width: 768px) {
  .hero-right {
    order: 0;
  }
}
</style>
