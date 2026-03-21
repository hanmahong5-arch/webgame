/**
 * Stats Data
 * Centralized statistics for Home page display
 * These are static fallback values; useStats composable attempts live data
 */

import type { Stat, TrustBadge } from '../types/common'

export const stats = [
  { value: '99.9%', label: '服务可用性', color: 'text-ochre' },
  { value: '50+', label: '支持模型', color: 'text-product-api' },
  { value: '<100ms', label: '平均延迟', color: 'text-product-lucrum' },
  { value: '7', label: '产品无缝协作', color: 'text-product-switch' },
] satisfies Stat[]

export const trustBadges = [
  { icon: 'shield', label: '数据安全加密', iconColor: 'text-product-lucrum' },
  { icon: 'check', label: '无需信用卡', iconColor: 'text-product-lucrum' },
  { icon: 'bolt', label: '即时开通', iconColor: 'text-ochre' },
] satisfies TrustBadge[]

/**
 * SVG icon paths for trust badges
 */
export const trustBadgeIconPaths: Record<string, string> = {
  shield: 'M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z',
  check: 'M5 13l4 4L19 7',
  bolt: 'M13 10V3L4 14h7v7l9-11h-7z',
}
