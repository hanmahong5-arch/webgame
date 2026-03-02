<script setup lang="ts">
import { computed } from 'vue'
import { products, productIconPaths } from '../../data/products'
import ProductSubCard from './ProductSubCard.vue'
import AnimatedProductGraph from './AnimatedProductGraph.vue'

const infraProducts = computed(() => products.filter((p) => p.layer === 'infra'))
const appProducts = computed(() => products.filter((p) => p.layer === 'app'))
</script>

<template>
  <section id="products" aria-label="产品生态" class="py-fib-7 bg-cream-50 relative overflow-hidden">
    <div class="doodle-corner top-8 left-8" aria-hidden="true"></div>
    <div class="doodle-corner bottom-8 right-8 rotate-180" aria-hidden="true"></div>

    <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="text-center mb-fib-6 reveal-fade-up">
        <span class="inline-block px-4 py-2 border-sketchy-light text-ink-500 text-sm font-medium mb-fib-4">
          <span class="doodle-star mr-2" aria-hidden="true"></span>
          Product Ecosystem
        </span>
        <h2 class="text-phi-2xl sm:text-phi-3xl text-ink-900 mb-fib-4 font-semibold">
          探索 <span class="text-gradient-ochre underline-doodle">产品生态</span>
        </h2>
        <p class="text-phi-xl text-ink-500 max-w-2xl mx-auto">
          全栈自建，从 AI 网关到量化交易到企业邮件
        </p>
      </div>

      <!-- Main Card -->
      <div data-testid="product-main-card" class="card-sketchy p-8 lg:p-12 mb-10 reveal-fade-up">
        <div class="flex flex-col lg:flex-row items-center gap-8">
          <div class="flex-1 text-center lg:text-left">
            <h3 class="text-phi-2xl text-ink-900 mb-fib-3 font-semibold">
              一个团队，全栈自建
            </h3>
            <p class="text-phi-lg text-ink-500 mb-fib-4 max-w-2xl">
              从统一 AI 网关到量化交易平台，从企业邮件到桌面客户端，每一行代码都出自同一支团队，确保一致的品质与体验。
            </p>
            <div class="flex flex-wrap justify-center lg:justify-start gap-fib-3">
              <span v-for="product in products" :key="product.id" class="inline-flex items-center gap-2 px-3 py-1 border-sketchy-light text-sm text-ink-700">
                <span class="w-3 h-3 rounded-full" :style="{ backgroundColor: product.bgColor }" aria-hidden="true"></span>
                {{ product.name }}
              </span>
            </div>
          </div>

          <div class="w-full lg:w-2/5 flex justify-center">
            <AnimatedProductGraph :products="products" />
          </div>
        </div>
      </div>

      <!-- Infra Layer -->
      <div class="mb-10 reveal-fade-up">
        <h3 class="text-phi-xl text-ink-900 mb-fib-4 font-semibold">AI 基础设施层</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 reveal-stagger">
          <ProductSubCard
            v-for="product in infraProducts"
            :key="product.id"
            :product="product"
          />
        </div>
      </div>

      <!-- Divider -->
      <div class="flex items-center gap-4 mb-8 reveal-fade-up">
        <div class="flex-1 h-px bg-ink-100"></div>
        <p class="text-sm text-ink-400 whitespace-nowrap px-2">基于 Lurus 基础设施构建的产品</p>
        <div class="flex-1 h-px bg-ink-100"></div>
      </div>

      <!-- App Products -->
      <div class="reveal-fade-up">
        <h3 class="text-phi-xl text-ink-900 mb-fib-4 font-semibold">应用产品</h3>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <a
            v-for="product in appProducts"
            :key="product.id"
            :href="product.url"
            :target="product.url.startsWith('http') ? '_blank' : undefined"
            :rel="product.url.startsWith('http') ? 'noopener noreferrer' : undefined"
            class="group card-sketchy p-5 flex items-start gap-4 hover:shadow-paper-hover transition-all"
            data-testid="app-product-card"
          >
            <div
              class="w-10 h-10 rounded-lg flex-shrink-0 flex items-center justify-center border-sketchy"
              :style="{ backgroundColor: product.bgColor }"
            >
              <svg class="w-5 h-5 text-cream-50" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="productIconPaths[product.icon] || productIconPaths.api" />
              </svg>
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 mb-1">
                <h4 class="text-ink-900 font-semibold group-hover:text-gradient-ochre transition-colors">{{ product.name }}</h4>
                <span class="text-xs text-ink-400 border-sketchy-light px-2 py-0.5">{{ product.tagline }}</span>
              </div>
              <p class="text-sm text-ink-500 line-clamp-2">{{ product.description }}</p>
            </div>
            <svg class="w-4 h-4 text-ink-300 group-hover:text-ochre group-hover:translate-x-1 transition-all flex-shrink-0 mt-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </a>
        </div>
      </div>
    </div>
  </section>
</template>
