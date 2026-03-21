/**
 * Downloadable Products Registry
 * Maps product display IDs to release API product_ids
 * and defines download-related metadata
 */

import type { Platform } from '../types/release'

export interface DownloadableProduct {
  /** Short ID matching products.ts */
  id: string
  /** API release product_id (e.g. 'lurus-switch') */
  releaseProductId: string
  name: string
  tagline: string
  description: string
  /** Icon key matching productIconPaths */
  icon: string
  /** Supported target platforms */
  platforms: Platform[]
  /** How users install this product */
  installMethod: 'binary' | 'pip' | 'cargo' | 'app-store'
  /** pip/cargo install command (if applicable) */
  installCommand?: string
  /** Whether releases are currently available */
  isReleased: boolean
  /** Brand color for the product card */
  color: string
  /** Link to source/docs */
  repoUrl?: string
  docsUrl?: string
}

export const downloadableProducts: DownloadableProduct[] = [
  {
    id: 'acest',
    releaseProductId: 'acest-desktop',
    name: 'ACEST Desktop',
    tagline: 'AI Desktop Assistant',
    description: '自适应上下文智能任务引擎 — 桌面 AI 助手，55+ 技能覆盖十大领域',
    icon: 'brain',
    platforms: ['windows'],
    installMethod: 'binary',
    isReleased: true,
    color: '#D4A827',
    docsUrl: 'https://docs.lurus.cn/acest/',
  },
  {
    id: 'switch',
    releaseProductId: 'lurus-switch',
    name: 'Lurus Switch',
    tagline: 'Local AI Gateway',
    description: '本地 AI 网关 — 充一次钱用所有工具，统一计费、智能路由、透明用量追踪，支持 Claude Code / Codex / Gemini CLI 等',
    icon: 'desktop',
    platforms: ['windows', 'darwin'],
    installMethod: 'binary',
    isReleased: true,
    color: '#FF8C69',
    repoUrl: 'https://github.com/hanmahong5-arch/lurus-switch',
    docsUrl: 'https://docs.lurus.cn/switch/',
  },
  {
    id: 'creator',
    releaseProductId: 'lurus-creator',
    name: 'Lurus Creator',
    tagline: 'Content Factory',
    description: '视频抓取 → Whisper 转录 → LLM 编辑 → 多平台一键发布',
    icon: 'video',
    platforms: ['windows', 'darwin'],
    installMethod: 'binary',
    isReleased: true,
    color: '#FFB86C',
    docsUrl: 'https://docs.lurus.cn/creator/',
  },
  {
    id: 'memx',
    releaseProductId: 'memx',
    name: 'MemX',
    tagline: 'AI Memory Engine',
    description: '零 LLM 成本的自适应 AI 记忆框架，让智能体学会记忆与遗忘',
    icon: 'database',
    platforms: ['windows', 'darwin', 'linux'],
    installMethod: 'pip',
    installCommand: 'pip install memx',
    isReleased: true,
    color: '#8B7A5C',
    repoUrl: 'https://github.com/UU114/memx',
    docsUrl: 'https://docs.lurus.cn/memx/',
  },
  {
    id: 'lumen',
    releaseProductId: 'lumen',
    name: 'Lumen',
    tagline: 'Agent Debugger CLI',
    description: 'Agent 开发者专用调试 CLI，实时可视化执行轨迹',
    icon: 'bug',
    platforms: ['windows', 'darwin', 'linux'],
    installMethod: 'cargo',
    installCommand: 'cargo install lumen-cli',
    isReleased: false,
    color: '#FFE566',
    docsUrl: 'https://docs.lurus.cn/lumen/',
  },
  {
    id: 'lutu',
    releaseProductId: 'lutu',
    name: 'Lutu',
    tagline: 'Mobile AI Client',
    description: 'Lurus 移动端，随时随地使用 AI 工具',
    icon: 'mobile',
    platforms: ['android', 'ios'],
    installMethod: 'app-store',
    isReleased: false,
    color: '#6B8BA4',
  },
]

/** Get downloadable product by short ID */
export function getDownloadableProduct(id: string): DownloadableProduct | undefined {
  return downloadableProducts.find(p => p.id === id)
}

/** Get downloadable product by release API product_id */
export function getProductByReleaseId(releaseProductId: string): DownloadableProduct | undefined {
  return downloadableProducts.find(p => p.releaseProductId === releaseProductId)
}

/** Products that are released and have binary downloads */
export const releasedBinaryProducts = downloadableProducts.filter(
  p => p.isReleased && p.installMethod === 'binary'
)

/** All products that can potentially have releases tracked */
export const allTrackableProducts = downloadableProducts.filter(
  p => p.installMethod === 'binary' || p.installMethod === 'pip' || p.installMethod === 'cargo'
)
