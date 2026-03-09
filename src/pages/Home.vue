<script setup lang="ts">
import { ref } from 'vue'
import ValuePropositionHero from '../components/Hero/ValuePropositionHero.vue'
import MediaShowcase from '../components/Products/MediaShowcase.vue'
import AIToolsNarrative from '../components/Features/AIToolsNarrative.vue'
import PortalLinks from '../components/Portal/PortalLinks.vue'
import PricingPreview from '../components/Pricing/PricingPreview.vue'
import StatsDisplay from '../components/Products/StatsDisplay.vue'
import AudienceStartGuide from '../components/GettingStarted/AudienceStartGuide.vue'
import FinalCTA from '../components/CTAs/FinalCTA.vue'
import SectionDivider from '../components/Layout/SectionDivider.vue'
import { useScrollReveal } from '../composables/useScrollReveal'

const pageRef = ref<HTMLElement | null>(null)
useScrollReveal(pageRef)
</script>

<template>
  <div ref="pageRef">
    <!-- S1: Value Proposition Hero -->
    <ValuePropositionHero />

    <SectionDivider />

    <!-- S2: Media Showcase — Product demos with GIF/video placeholders -->
    <MediaShowcase />

    <SectionDivider />

    <!-- S3: AI Tools Narrative — Pain-point driven, de-jargoned -->
    <AIToolsNarrative />

    <SectionDivider />

    <!-- S4: Portal Links + AI Chat Preview -->
    <PortalLinks />

    <SectionDivider />

    <!-- S5: Stats — Social proof -->
    <StatsDisplay />

    <SectionDivider />

    <!-- S6: Pricing Preview — Simplified -->
    <PricingPreview />

    <SectionDivider />

    <!-- S7: Getting Started — Audience-routed -->
    <AudienceStartGuide />

    <!-- S8: Final CTA — Brand confirmation -->
    <FinalCTA />
  </div>
</template>

<style scoped>
@reference "../styles/main.css";
</style>
