<script setup lang="ts">
import { ref } from 'vue'
import { useScrollReveal } from '../composables/useScrollReveal'
import AdvantagesSection from '../components/About/AdvantagesSection.vue'
import MissionVision from '../components/About/MissionVision.vue'
import CredibilityStats from '../components/About/CredibilityStats.vue'
import CoreValues from '../components/About/CoreValues.vue'
import TechnologyBrief from '../components/About/TechnologyBrief.vue'
import AnimatedTimeline from '../components/About/AnimatedTimeline.vue'
import CareersSection from '../components/About/CareersSection.vue'
import TeamSection from '../components/About/TeamSection.vue'
import { MILESTONES } from '../data/about'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
</script>

<template>
  <div ref="pageRef">
    <!-- Hero -->
    <section id="hero" class="py-24 section-dark-raised relative overflow-hidden">
      <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
        <h1 class="text-phi-3xl sm:text-phi-4xl font-bold text-[var(--color-text-primary)] mb-4">
          关于 Lurus
        </h1>
        <p class="text-phi-xl text-[var(--color-text-secondary)] max-w-2xl mx-auto">
          让每个人都能简单、稳定地使用 AI
        </p>
      </div>
    </section>

    <!-- Mission & Vision -->
    <MissionVision />

    <!-- Credibility Stats -->
    <CredibilityStats />

    <!-- Core Values -->
    <CoreValues />

    <!-- Advantages + Ecosystem Graph -->
    <AdvantagesSection />

    <!-- Timeline -->
    <AnimatedTimeline :milestones="MILESTONES" />

    <!-- Technology Brief -->
    <TechnologyBrief />

    <!-- Team -->
    <TeamSection />

    <!-- Careers -->
    <CareersSection />

    <!-- Contact -->
    <section id="contact" class="py-24 section-dark-raised">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center reveal-fade-up">
        <h2 class="text-phi-2xl font-bold text-[var(--color-text-primary)] mb-4">联系我们</h2>
        <p class="text-[var(--color-text-secondary)] mb-10">
          有任何问题或建议？我们很乐意听取你的反馈
        </p>
        <div class="flex flex-wrap justify-center gap-4">
          <a
            href="mailto:support@lurus.cn"
            class="btn-outline inline-flex items-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
            support@lurus.cn
          </a>
          <a
            href="https://docs.lurus.cn"
            target="_blank"
            rel="noopener noreferrer"
            class="btn-outline inline-flex items-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
            </svg>
            文档
          </a>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@reference "../styles/main.css";
</style>
