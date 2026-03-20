<script setup lang="ts">
/**
 * Account Badge Component
 *
 * Compact identity status badge shown in the navigation bar for logged-in users.
 * Displays VIP level color indicator, Lubell balance, and a top-up link.
 * Errors are silently ignored — this is a non-critical enhancement.
 */

import { computed } from 'vue'
import { useAccountOverview } from '../../composables/useAccountOverview'

const { overview } = useAccountOverview()

// VIP level → CSS color class
const VIP_COLORS: Record<number, string> = {
  0: '#9CA3AF', // Standard — gray
  1: '#C0C0C0', // Silver
  2: '#F59E0B', // Gold — Lubell amber
  3: '#A5B4FC', // Platinum — indigo
  4: '#67E8F9', // Diamond — cyan
}

const vipColor = computed(() => {
  if (!overview.value) return '#9CA3AF'
  return VIP_COLORS[overview.value.vip.level] ?? '#9CA3AF'
})

const balance = computed(() => overview.value?.wallet.balance ?? null)

const topupUrl = computed(() => {
  if (!overview.value) return 'https://identity.lurus.cn/wallet/topup'
  return `${overview.value.topup_url}?redirect=${encodeURIComponent(window.location.href)}&from=lurus-www`
})
</script>

<template>
  <div
    v-if="overview"
    class="flex items-center gap-2 px-2 py-1 rounded-lg bg-[var(--color-surface-raised)] border border-[var(--color-surface-border)]"
  >
    <!-- VIP color dot -->
    <span
      class="w-2 h-2 rounded-full shrink-0"
      :style="{ backgroundColor: vipColor }"
      :title="overview.vip.level_name"
    />

    <!-- Lubell balance -->
    <span class="text-sm font-mono tabular-nums text-[var(--color-text-primary)]">
      🦌 {{ balance?.toFixed(2) }} <span class="text-xs text-[var(--color-text-muted)]">LB</span>
    </span>

    <!-- Top-up link -->
    <a
      :href="topupUrl"
      target="_blank"
      rel="noopener noreferrer"
      class="text-xs text-ochre hover:text-ochre-600 transition-colors whitespace-nowrap"
    >
      充值
    </a>
  </div>
</template>
