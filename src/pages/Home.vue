<script setup lang="ts">
import { ref } from 'vue'
import HeroSection from '../components/Hero/HeroSection.vue'
import CodeShowcase from '../components/TechDemo/CodeShowcase.vue'
import PortalLinks from '../components/Portal/PortalLinks.vue'
import ProductShowcase from '../components/Products/ProductShowcase.vue'
import StatsDisplay from '../components/Products/StatsDisplay.vue'
import PlatformCapabilities from '../components/Features/PlatformCapabilities.vue'
import { useScrollReveal } from '../composables/useScrollReveal'
import { useTracking } from '../composables/useTracking'
import { useAuth } from '../composables/useAuth'
import { trustBadges, trustBadgeIconPaths } from '../data/stats'
import GettingStartedSection from '../components/GettingStarted/GettingStartedSection.vue'
import FinalCTA from '../components/CTAs/FinalCTA.vue'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)

const { track } = useTracking()
const { login } = useAuth()
const trackCta = (label: string) => {
  track('cta_click', { label })
}

</script>

<template>
  <div ref="pageRef">
    <!-- S1: Hero Section — Lurus 是做什么的？ -->
    <HeroSection>
      <template #right>
        <CodeShowcase
          code="curl https://api.lurus.cn/v1/models"
          language="bash"
          ariaLabel="API 调用示例"
        />
      </template>
    </HeroSection>

    <!-- S2: Stats — 真的可靠吗？ -->
    <StatsDisplay />

    <!-- S3: Platform Capabilities — 这个 API 能做什么？ -->
    <PlatformCapabilities />

    <!-- S4: Use Cases — 我能用它做什么？ -->
    <section class="py-fib-6 bg-cream-50">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-fib-5 reveal-fade-up">
          <h2 class="text-phi-2xl sm:text-phi-3xl text-ink-900 mb-fib-3 font-semibold">覆盖多元场景</h2>
          <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto">一个接口，连接学术、金融、医疗、法律、软件工程等行业场景</p>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-fib-4">
          <div class="border-sketchy bg-cream-100 p-fib-4 text-center reveal-fade-up">
            <div class="text-3xl mb-2">📚</div>
            <h3 class="font-hand font-bold text-ink-900 text-lg">学术研究</h3>
            <p class="text-ink-400 text-sm mt-1">论文综述 · 数据分析</p>
          </div>
          <div class="border-sketchy bg-cream-100 p-fib-4 text-center reveal-fade-up">
            <div class="text-3xl mb-2">💹</div>
            <h3 class="font-hand font-bold text-ink-900 text-lg">金融分析</h3>
            <p class="text-ink-400 text-sm mt-1">市场研究 · 量化策略</p>
          </div>
          <div class="border-sketchy bg-cream-100 p-fib-4 text-center reveal-fade-up">
            <div class="text-3xl mb-2">🏥</div>
            <h3 class="font-hand font-bold text-ink-900 text-lg">医疗健康</h3>
            <p class="text-ink-400 text-sm mt-1">文献检索 · 临床辅助</p>
          </div>
          <div class="border-sketchy bg-cream-100 p-fib-4 text-center reveal-fade-up">
            <div class="text-3xl mb-2">⚖️</div>
            <h3 class="font-hand font-bold text-ink-900 text-lg">法律服务</h3>
            <p class="text-ink-400 text-sm mt-1">法规检索 · 合同审查</p>
          </div>
        </div>
        <div class="text-center mt-fib-4">
          <router-link to="/solutions" class="text-ochre hover:underline font-medium text-sm">
            查看全部解决方案 →
          </router-link>
        </div>
      </div>
    </section>

    <!-- S5: Products — 都有哪些产品？ -->
    <ProductShowcase />

    <!-- S6: Getting Started — 怎么开始？ -->
    <GettingStartedSection />

    <!-- S7: Portal Links — 有哪些配套资源？ -->
    <PortalLinks />

    <!-- S8: CTA Section — 立即注册 -->
    <section class="py-fib-7 bg-cream-100 relative overflow-hidden">
      <!-- Decorative pattern -->
      <div class="absolute inset-0 opacity-[0.02]" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>

      <!-- Corner decorations -->
      <div class="absolute top-12 left-12 doodle-corner opacity-40"></div>
      <div class="absolute top-12 right-12 doodle-corner -scale-x-100 opacity-40"></div>
      <div class="absolute bottom-12 left-12 doodle-corner -scale-y-100 opacity-40"></div>
      <div class="absolute bottom-12 right-12 doodle-corner scale-[-1] opacity-40"></div>

      <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
        <h2 class="text-phi-2xl sm:text-phi-3xl text-ink-900 mb-fib-4 font-semibold">
          准备好开始了吗？
        </h2>
        <p class="text-phi-xl text-ink-500 mb-fib-6 max-w-2xl mx-auto">
          立即注册，免费体验 Lurus 提供的全套 AI 基础设施服务
        </p>
        <div class="flex flex-col sm:flex-row gap-fib-4 justify-center">
          <button
            class="btn-hand btn-hand-primary inline-flex items-center justify-center gap-2 text-lg px-10 py-5"
            @click="trackCta('register'); login({ prompt: 'create' })"
          >
            <span>免费注册</span>
            <svg class="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
            </svg>
          </button>
          <a
            href="https://docs.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-hand inline-flex items-center justify-center gap-2 text-lg px-10 py-5"
            @click="trackCta('explore')"
          >
            <span>探索更多</span>
          </a>
        </div>

        <!-- Trust Badges -->
        <div class="mt-fib-6 flex flex-wrap items-center justify-center gap-fib-5 text-ink-500 text-sm">
          <div
            v-for="badge in trustBadges"
            :key="badge.label"
            class="flex items-center gap-2 px-4 py-2 border-sketchy-light bg-cream-50"
          >
            <svg :class="['w-5 h-5', badge.iconColor]" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="trustBadgeIconPaths[badge.icon]" />
            </svg>
            <span>{{ badge.label }}</span>
          </div>
        </div>
      </div>
    </section>

    <!-- S9: Final CTA — 品牌确认 -->
    <FinalCTA />
  </div>
</template>

<style scoped>
@reference "../styles/main.css";
</style>
