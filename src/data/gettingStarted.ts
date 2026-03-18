/**
 * Getting Started Data
 * Centralized quick-access entry points for the Getting Started section (S6)
 * ADR-006: Data centralization
 */

import type { GettingStartedItem } from '../types/gettingStarted'

export const gettingStartedItems: readonly GettingStartedItem[] = [
  {
    id: 'api-docs',
    label: 'API 文档',
    href: 'https://docs.lurus.cn',
    external: true,
    ariaLabel: '查看 API 文档（新标签页打开）',
    iconPath: 'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253',
    description: '完整的 API 参考与集成指南',
  },
  {
    id: 'download',
    label: '下载客户端',
    href: '/download',
    external: false,
    ariaLabel: '跳转到客户端下载页面',
    iconPath: 'M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
    description: 'Switch 桌面端 · ACEST · MemX',
  },
  {
    id: 'lucrum',
    label: 'Lucrum 量化',
    href: 'https://gushen.lurus.cn',
    external: true,
    ariaLabel: '访问 Lucrum 量化交易平台（新标签页打开）',
    iconPath: 'M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 013 19.875v-6.75zM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V8.625zM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 01-1.125-1.125V4.125z',
    description: '自然语言驱动的量化交易',
  },
] as const satisfies readonly GettingStartedItem[]
