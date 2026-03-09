<script setup lang="ts">
import { ref } from 'vue'
import AudienceHero from '../components/Hero/AudienceHero.vue'
import EcosystemMap from '../components/Products/EcosystemMap.vue'
import ProductSpotlight from '../components/Products/ProductSpotlight.vue'
import AIToolsNarrative from '../components/Features/AIToolsNarrative.vue'
import PricingPreview from '../components/Pricing/PricingPreview.vue'
import StatsDisplay from '../components/Products/StatsDisplay.vue'
import AudienceStartGuide from '../components/GettingStarted/AudienceStartGuide.vue'
import FinalCTA from '../components/CTAs/FinalCTA.vue'
import { useScrollReveal } from '../composables/useScrollReveal'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
</script>

<template>
  <div ref="pageRef">
    <!-- S1: Hero — Vision + Audience routing (Cognition) -->
    <AudienceHero />

    <!-- S2: Ecosystem Map — Product relationships (Understanding) -->
    <EcosystemMap />

    <!-- S3: Flagship Products Spotlight — Deep dive with tabs (Resonance) -->
    <ProductSpotlight />

    <!-- S4: AI Tools Narrative — Market positioning (Resonance) -->
    <AIToolsNarrative />

    <!-- S5: Industry Solutions — Scenario-based (Understanding) -->
    <section class="py-fib-6 bg-cream-100">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-fib-5 reveal-fade-up">
          <h2 class="text-phi-2xl sm:text-phi-3xl text-ink-900 mb-fib-3 font-semibold">覆盖多元场景</h2>
          <p class="text-phi-lg text-ink-500 max-w-2xl mx-auto">一个生态，连接学术、金融、医疗、法律、工程等行业场景</p>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-fib-4 reveal-fade-up">
          <div class="border-sketchy bg-cream-50 p-fib-4 text-center hover:shadow-paper-hover transition-all">
            <div class="text-3xl mb-2">📚</div>
            <h3 class="font-hand font-bold text-ink-900 text-lg">学术研究</h3>
            <p class="text-ink-400 text-sm mt-1">论文综述 · 数据分析</p>
            <p class="text-xs text-ink-300 mt-2">API + MemX + ACEST</p>
          </div>
          <div class="border-sketchy bg-cream-50 p-fib-4 text-center hover:shadow-paper-hover transition-all">
            <div class="text-3xl mb-2">💹</div>
            <h3 class="font-hand font-bold text-ink-900 text-lg">金融分析</h3>
            <p class="text-ink-400 text-sm mt-1">量化策略 · 风险控制</p>
            <p class="text-xs text-ink-300 mt-2">GuShen + API + MemX</p>
          </div>
          <div class="border-sketchy bg-cream-50 p-fib-4 text-center hover:shadow-paper-hover transition-all">
            <div class="text-3xl mb-2">🏥</div>
            <h3 class="font-hand font-bold text-ink-900 text-lg">医疗健康</h3>
            <p class="text-ink-400 text-sm mt-1">文献检索 · 临床辅助</p>
            <p class="text-xs text-ink-300 mt-2">API + ACEST + Identity</p>
          </div>
          <div class="border-sketchy bg-cream-50 p-fib-4 text-center hover:shadow-paper-hover transition-all">
            <div class="text-3xl mb-2">⚖️</div>
            <h3 class="font-hand font-bold text-ink-900 text-lg">法律服务</h3>
            <p class="text-ink-400 text-sm mt-1">法规检索 · 合同审查</p>
            <p class="text-xs text-ink-300 mt-2">API + MemX + Mail</p>
          </div>
        </div>
        <div class="text-center mt-fib-4 reveal-fade-up">
          <router-link to="/solutions" class="text-ochre hover:underline font-medium text-sm">
            查看全部解决方案 →
          </router-link>
        </div>
      </div>
    </section>

    <!-- S6: Pricing Preview — Simplified (Trust) -->
    <PricingPreview />

    <!-- S7: Stats — Social proof (Trust) -->
    <StatsDisplay />

    <!-- S8: Getting Started — Audience-routed (Action) -->
    <AudienceStartGuide />

    <!-- S9: Final CTA — Brand confirmation -->
    <FinalCTA />
  </div>
</template>

<style scoped>
@reference "../styles/main.css";
</style>
