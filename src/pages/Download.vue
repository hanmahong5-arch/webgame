<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useReleases } from '../composables/useReleases'
import { downloadableProducts } from '../data/downloadableProducts'
import PlatformIcon from '../components/Download/PlatformIcon.vue'
import { productIconPaths } from '../data/products'
import type { LatestReleaseResponse } from '../types/release'

const {
  fetchLatestRelease,
  findRecommendedArtifact,
  formatFileSize,
  getPlatformName,
  downloadArtifact,
} = useReleases()

// Static fallbacks (always available even if API is down)
interface StaticFallback {
  url: string
  size: string
  version: string
  sha256: string
}

const staticFallbacks = new Map<string, StaticFallback>([
  ['acest-desktop', {
    url: '/releases/acest-desktop/v0.2.0/ACEST-Desktop_0.2.0_x64-setup.exe',
    size: '37.4 MB',
    version: '0.2.0',
    sha256: '1e8bdb46fb45fde5b7e9c4b51a8beab31376afe369d214adea4dbcaf25544d26',
  }],
  ['lurus-switch', {
    url: '/releases/lurus-switch/v0.1.0/lurus-switch_0.1.0_windows_x64.exe',
    size: '12 MB',
    version: '0.1.0',
    sha256: '9442a44d9e61e1d0fa0083dcc17728d820144244f0e1035620a0add7969b1e16',
  }],
  ['lurus-creator', {
    url: '/releases/lurus-creator/v0.3.0/lurus-creator_0.3.0_windows_x64.exe',
    size: '21 MB',
    version: '0.3.0',
    sha256: '69745bb5d6ff6b2a9c914e71a98ab83758308bbcc2cb4304a61730c518f2f3b8',
  }],
])

function downloadByProduct(releaseProductId: string) {
  // Prefer API data
  const apiRelease = latestReleases.value.get(releaseProductId)
  if (apiRelease) {
    const recommended = findRecommendedArtifact(apiRelease.release.artifacts)
    if (recommended) {
      downloadArtifact(apiRelease.release.id, recommended.id)
      return
    }
  }
  // Fall back to static URL
  const fallback = staticFallbacks.get(releaseProductId)
  if (fallback) {
    window.location.href = fallback.url
  }
}

// Dynamic release data from API
const latestReleases = ref<Map<string, LatestReleaseResponse>>(new Map())
const loadingProducts = ref(true)

// AbortController for cancelling all in-flight fetches on unmount
let fetchController: AbortController | null = null

onMounted(async () => {
  loadingProducts.value = true
  fetchController = new AbortController()
  const signal = fetchController.signal

  // Fetch latest release for each product in parallel (pass abort signal)
  const promises = downloadableProducts
    .filter(p => p.isReleased || p.installMethod === 'binary')
    .map(async (product) => {
      const result = await fetchLatestRelease(product.releaseProductId, undefined, signal)
      if (result) {
        latestReleases.value.set(product.releaseProductId, result)
      }
    })
  await Promise.allSettled(promises)
  if (!signal.aborted) {
    loadingProducts.value = false
  }
})

// Helper: get version/size/sha256 for a product (API first, then static fallback)
function getProductVersion(releaseProductId: string): string {
  const apiRelease = latestReleases.value.get(releaseProductId)
  if (apiRelease) return apiRelease.release.version
  return staticFallbacks.get(releaseProductId)?.version ?? '—'
}

function getProductFileSize(releaseProductId: string): string {
  const apiRelease = latestReleases.value.get(releaseProductId)
  if (apiRelease) {
    const recommended = findRecommendedArtifact(apiRelease.release.artifacts)
    if (recommended) return formatFileSize(recommended.file_size)
  }
  return staticFallbacks.get(releaseProductId)?.size ?? '—'
}

function getProductSha256(releaseProductId: string): string {
  const apiRelease = latestReleases.value.get(releaseProductId)
  if (apiRelease) {
    const recommended = findRecommendedArtifact(apiRelease.release.artifacts)
    if (recommended) return recommended.checksum_sha256
  }
  return staticFallbacks.get(releaseProductId)?.sha256 ?? ''
}

// ACEST hero section computed
const acestVersion = computed(() => getProductVersion('acest-desktop'))
const acestFileSize = computed(() => getProductFileSize('acest-desktop'))
const acestSha256 = computed(() => getProductSha256('acest-desktop'))

// Build the all-releases list combining API data + static fallbacks
const allReleaseItems = computed(() => {
  return downloadableProducts.map(product => {
    const apiData = latestReleases.value.get(product.releaseProductId)
    const release = apiData?.release
    const recommended = release ? findRecommendedArtifact(release.artifacts) : null
    const fallback = staticFallbacks.get(product.releaseProductId)

    const hasDownload = !!(release && recommended) || !!fallback
    const version = release
      ? `v${release.version}`
      : fallback ? `v${fallback.version}` : '—'
    const size = recommended
      ? formatFileSize(recommended.file_size)
      : fallback ? fallback.size : '—'

    return {
      product: product.name,
      productId: product.id,
      releaseProductId: product.releaseProductId,
      version,
      platform: product.platforms.map(p => getPlatformName(p)).join(' / '),
      status: (hasDownload ? 'available' : product.isReleased ? 'available' : 'coming-soon') as 'available' | 'coming-soon',
      size,
      installMethod: product.installMethod,
      installCommand: product.installCommand,
      release,
      recommended,
      fallbackUrl: fallback?.url,
      icon: product.icon,
      color: product.color,
      downloadCount: release
        ? release.artifacts.reduce((sum, a) => sum + a.download_count, 0)
        : 0,
    }
  })
})

function handleItemDownload(item: typeof allReleaseItems.value[0]) {
  downloadByProduct(item.releaseProductId)
}

// Feature cards data
const features = [
  {
    title: 'Self-Learning',
    subtitle: '越用越聪明',
    description: 'ACE framework learns from every conversation. Insights are extracted, scored, and stored — the assistant improves over time.',
    icon: 'brain',
  },
  {
    title: 'Context-Efficient',
    subtitle: '极致上下文效率',
    description: 'Five-layer context model with JIT skill mounting. Only 4-8 tools active at any time, system context under 6k tokens.',
    icon: 'layers',
  },
  {
    title: '55+ Skills',
    subtitle: '覆盖十大领域',
    description: 'Office, Academic, Analysis, Research, Management, Knowledge, Batch, Creative, Developer, Content — loaded on demand.',
    icon: 'grid',
  },
  {
    title: 'Office Native',
    subtitle: '原生文档处理',
    description: 'Read and write Excel, Word, PDF, PowerPoint. Formulas, charts, tables, styles — full office document support.',
    icon: 'file',
  },
  {
    title: 'Graceful Fallback',
    subtitle: '从不失败',
    description: 'When no skill matches, falls back to atomic tools — shell, file I/O, web search. Never fails simply because a scenario is unforeseen.',
    icon: 'shield',
  },
  {
    title: 'MCP Ecosystem',
    subtitle: '可扩展工具生态',
    description: 'Integrates with Playwright, Tavily, email, calendar, and more. Extend capabilities through the MCP protocol.',
    icon: 'plug',
  },
]

// Skill domains data
const skillDomains = [
  { name: 'Office', count: 7, color: 'bg-blue-100 text-blue-700 border-blue-200' },
  { name: 'Academic', count: 6, color: 'bg-purple-100 text-purple-700 border-purple-200' },
  { name: 'Analysis', count: 6, color: 'bg-green-100 text-green-700 border-green-200' },
  { name: 'Research', count: 1, color: 'bg-amber-100 text-amber-700 border-amber-200' },
  { name: 'Manager', count: 8, color: 'bg-red-100 text-red-700 border-red-200' },
  { name: 'Knowledge', count: 4, color: 'bg-teal-100 text-teal-700 border-teal-200' },
  { name: 'Batch', count: 5, color: 'bg-orange-100 text-orange-700 border-orange-200' },
  { name: 'Creative', count: 5, color: 'bg-pink-100 text-pink-700 border-pink-200' },
  { name: 'Developer', count: 5, color: 'bg-indigo-100 text-indigo-700 border-indigo-200' },
  { name: 'Content', count: 5, color: 'bg-cyan-100 text-cyan-700 border-cyan-200' },
]

// MemX pip install copy state
const memxCopied = ref(false)
let copyResetTimer: ReturnType<typeof setTimeout> | null = null
function copyPipInstall() {
  navigator.clipboard.writeText('pip install memx').then(() => {
    memxCopied.value = true
    if (copyResetTimer) clearTimeout(copyResetTimer)
    copyResetTimer = setTimeout(() => { memxCopied.value = false }, 2000)
  })
}

// Cancel all in-flight fetches and timers on unmount (rapid navigation away)
onUnmounted(() => {
  fetchController?.abort()
  fetchController = null
  if (copyResetTimer) {
    clearTimeout(copyResetTimer)
    copyResetTimer = null
  }
})
</script>

<template>
  <div>
    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- HERO: ACEST Desktop -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <section id="hero" class="relative py-20 sm:py-28 section-dark-raised overflow-hidden">
      <div class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          <!-- Left: Text + CTA -->
          <div>
            <!-- Badge -->
            <div class="inline-flex items-center gap-2 px-3 py-1.5 mb-6 border-2 border-ochre/30 bg-ochre/5 text-ochre text-sm font-medium" style="border-radius: 9999px">
              <span class="w-2 h-2 rounded-full bg-ochre animate-pulse"></span>
              v{{ acestVersion }} — Windows
            </div>

            <!-- Headline -->
            <h1 class="text-4xl sm:text-5xl lg:text-6xl font-bold text-[var(--color-text-primary)] mb-4 leading-tight">
              ACEST Desktop
            </h1>
            <p class="text-xl sm:text-2xl text-[var(--color-text-secondary)] mb-2 font-medium">
              Adaptive Context Engine for Smart Tasks
            </p>
            <p class="text-lg text-[var(--color-text-muted)] mb-8">
              自适应上下文智能任务引擎 — 一个懂你的 AI 桌面助手
            </p>

            <!-- CTA Buttons -->
            <div class="flex flex-col sm:flex-row gap-4 mb-8">
              <button
                @click="downloadByProduct('acest-desktop')"
                class="btn-primary inline-flex items-center justify-center gap-3 text-lg px-8 py-4 group"
              >
                <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                </svg>
                <span>Download for Windows</span>
                <span class="text-sm opacity-70">({{ acestFileSize }})</span>
              </button>
              <a
                href="#all-releases"
                class="btn-outline inline-flex items-center justify-center gap-2 text-lg px-8 py-4"
              >
                All Releases
              </a>
              <a
                href="#memx"
                class="btn-outline inline-flex items-center justify-center gap-2 text-base px-5 py-4 text-ochre border-ochre/40"
              >
                MemX ↓
              </a>
            </div>

            <!-- Trust signals -->
            <div class="flex flex-wrap items-center gap-4 text-sm text-[var(--color-text-muted)]">
              <div class="flex items-center gap-1.5">
                <svg class="w-4 h-4 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
                <span>SHA256 verified</span>
              </div>
              <span class="text-[var(--color-surface-border)]">|</span>
              <div class="flex items-center gap-1.5">
                <svg class="w-4 h-4 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
                <span>Rust + Tauri 2.0</span>
              </div>
              <span class="text-[var(--color-surface-border)]">|</span>
              <div class="flex items-center gap-1.5">
                <svg class="w-4 h-4 text-[var(--color-text-muted)]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z" />
                </svg>
                <span>macOS coming soon</span>
              </div>
            </div>
          </div>

          <!-- Right: Architecture Visualization -->
          <div class="hidden lg:block">
            <div class="card-dark p-6">
              <p class="text-xs text-[var(--color-text-muted)] uppercase tracking-wider mb-4 font-medium">Five-Layer Context Model</p>
              <div class="space-y-2 font-mono text-sm">
                <div class="p-3 bg-ochre/10 border-2 border-ochre/30 text-[var(--color-text-secondary)] rounded-xl">
                  <span class="text-ochre font-bold">L0</span> Kernel
                  <span class="float-right text-[var(--color-text-muted)] text-xs">&lt;800 tok</span>
                </div>
                <div class="p-3 bg-blue-900/20 border border-blue-700/40 text-blue-300 rounded-xl">
                  <span class="text-blue-400 font-bold">L1</span> Registry
                  <span class="float-right text-[var(--color-text-muted)] text-xs">&lt;1500 tok</span>
                </div>
                <div class="p-3 bg-green-900/20 border border-green-700/40 text-green-300 rounded-xl">
                  <span class="text-green-400 font-bold">L2</span> Router
                  <span class="float-right text-[var(--color-text-muted)] text-xs">dynamic</span>
                </div>
                <div class="p-3 bg-purple-900/20 border border-purple-700/40 text-purple-300 rounded-xl">
                  <span class="text-purple-400 font-bold">L3</span> Active Skills
                  <span class="float-right text-[var(--color-text-muted)] text-xs">&le;3 slots</span>
                </div>
                <div class="p-3 bg-pink-900/20 border border-pink-700/40 text-pink-300 rounded-xl">
                  <span class="text-pink-400 font-bold">L4</span> Tool Interface
                  <span class="float-right text-[var(--color-text-muted)] text-xs">dynamic</span>
                </div>
              </div>
              <p class="mt-4 text-xs text-[var(--color-text-muted)] text-center">
                Total system context &lt; 6k tokens — 60% less than traditional assistants
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- FEATURES GRID -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <section id="acest" class="py-20 section-dark">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-14">
          <h2 class="text-3xl sm:text-4xl font-bold text-[var(--color-text-primary)] mb-4">
            Why ACEST
          </h2>
          <p class="text-lg text-[var(--color-text-secondary)] max-w-2xl mx-auto">
            Built with Rust for performance, designed for intelligence
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div
            v-for="feature in features"
            :key="feature.title"
            class="card-dark p-6 hover:border-ochre/40 transition-colors group"
          >
            <!-- Icon -->
            <div class="w-12 h-12 rounded-lg bg-ochre/10 flex items-center justify-center mb-4 group-hover:bg-ochre/20 transition-colors">
              <!-- Brain -->
              <svg v-if="feature.icon === 'brain'" class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
              </svg>
              <!-- Layers -->
              <svg v-else-if="feature.icon === 'layers'" class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
              </svg>
              <!-- Grid -->
              <svg v-else-if="feature.icon === 'grid'" class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
              </svg>
              <!-- File -->
              <svg v-else-if="feature.icon === 'file'" class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <!-- Shield -->
              <svg v-else-if="feature.icon === 'shield'" class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
              <!-- Plug -->
              <svg v-else-if="feature.icon === 'plug'" class="w-6 h-6 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
              </svg>
            </div>

            <h3 class="text-lg font-bold text-[var(--color-text-primary)] mb-1">{{ feature.title }}</h3>
            <p class="text-sm text-ochre mb-2">{{ feature.subtitle }}</p>
            <p class="text-sm text-[var(--color-text-secondary)] leading-relaxed">{{ feature.description }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- SKILL DOMAINS -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <section class="py-20 section-dark-raised">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-14">
          <h2 class="text-3xl sm:text-4xl font-bold text-[var(--color-text-primary)] mb-4">
            55+ Built-in Skills
          </h2>
          <p class="text-lg text-[var(--color-text-secondary)] max-w-2xl mx-auto">
            Ten domains, loaded on demand — only what you need, when you need it
          </p>
        </div>

        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
          <div
            v-for="domain in skillDomains"
            :key="domain.name"
            :class="[
              'p-4 border rounded-lg text-center transition-transform hover:scale-105',
              domain.color,
            ]"
          >
            <p class="text-2xl font-bold">{{ domain.count }}</p>
            <p class="text-sm font-medium mt-1">{{ domain.name }}</p>
          </div>
        </div>

        <!-- ACE Learning Pipeline -->
        <div class="mt-14 card-dark p-8">
          <h3 class="text-lg font-bold text-[var(--color-text-primary)] mb-6 text-center">ACE Learning Pipeline</h3>
          <div class="flex flex-col sm:flex-row items-center justify-center gap-2 sm:gap-0 text-sm font-mono text-[var(--color-text-secondary)]">
            <div class="px-4 py-2 bg-ochre/10 border border-ochre/30 rounded whitespace-nowrap">
              Conversation
            </div>
            <svg class="w-6 h-6 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            <svg class="w-6 h-6 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            <div class="px-4 py-2 bg-blue-900/20 border border-blue-700/40 text-blue-300 rounded whitespace-nowrap">
              Reflector
            </div>
            <svg class="w-6 h-6 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            <svg class="w-6 h-6 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            <div class="px-4 py-2 bg-green-900/20 border border-green-700/40 text-green-300 rounded whitespace-nowrap">
              Curator
            </div>
            <svg class="w-6 h-6 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            <svg class="w-6 h-6 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            <div class="px-4 py-2 bg-purple-900/20 border border-purple-700/40 text-purple-300 rounded whitespace-nowrap">
              Storage
            </div>
            <svg class="w-6 h-6 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            <svg class="w-6 h-6 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
            <div class="px-4 py-2 bg-pink-900/20 border border-pink-700/40 text-pink-300 rounded whitespace-nowrap">
              Retrieval
            </div>
          </div>
          <p class="text-center text-sm text-[var(--color-text-muted)] mt-4">
            Every conversation makes the assistant smarter — hybrid retrieval (keyword 60% + semantic 40%) with time decay
          </p>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- SECONDARY DOWNLOAD CTA -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <section class="py-16 section-dark">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 class="text-3xl font-bold text-[var(--color-text-primary)] mb-4">
          Ready to Get Started?
        </h2>
        <p class="text-lg text-[var(--color-text-secondary)] mb-8 max-w-xl mx-auto">
          Download ACEST Desktop and experience the future of AI-assisted work
        </p>

        <div class="inline-flex flex-col sm:flex-row gap-4 items-center">
          <button
            @click="downloadByProduct('acest-desktop')"
            class="btn-primary inline-flex items-center justify-center gap-3 text-lg px-10 py-5 group"
          >
            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
            <span>Download for Windows</span>
          </button>

          <div class="flex items-center gap-3 text-sm text-[var(--color-text-muted)]">
            <svg class="w-5 h-5 text-[var(--color-text-muted)]" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
            </svg>
            <span>macOS version coming soon</span>
          </div>
        </div>

        <!-- SHA256 -->
        <div class="mt-8 inline-block">
          <details class="text-left">
            <summary class="text-sm text-[var(--color-text-muted)] cursor-pointer hover:text-[var(--color-text-secondary)] transition-colors">
              SHA256 Checksum
            </summary>
            <code class="block mt-2 p-3 bg-[var(--color-surface-overlay)] border border-[var(--color-surface-border)] rounded text-xs font-mono text-[var(--color-text-secondary)] break-all max-w-lg">
              {{ acestSha256 }}
            </code>
          </details>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- SYSTEM REQUIREMENTS -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <section class="py-16 section-dark-raised">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-2xl font-bold text-[var(--color-text-primary)] mb-8 text-center">
          System Requirements
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Windows -->
          <div class="card-dark p-6">
            <div class="flex items-center gap-3 mb-4">
              <svg class="w-6 h-6 text-ochre" viewBox="0 0 24 24" fill="currentColor">
                <path d="M3 12V6.75l6-1.32v6.48L3 12zm17-9v8.75l-9.91.09V5.79L20 3zm0 18l-9.91-1.82V13l9.91.09V21zM3 13l6 .09v6.72l-6-1.06V13z"/>
              </svg>
              <h4 class="text-lg font-medium text-[var(--color-text-primary)]">Windows</h4>
              <span class="ml-auto px-2 py-0.5 text-xs font-medium rounded border text-green-400 bg-green-900/20 border-green-700/40">Available</span>
            </div>
            <ul class="text-[var(--color-text-secondary)] space-y-2 text-sm">
              <li>Windows 10 or later</li>
              <li>64-bit processor (x64)</li>
              <li>4 GB RAM minimum</li>
              <li>200 MB disk space</li>
              <li>Internet connection (for LLM API)</li>
            </ul>
          </div>
          <!-- macOS -->
          <div class="card-dark p-6 opacity-60">
            <div class="flex items-center gap-3 mb-4">
              <svg class="w-6 h-6 text-[var(--color-text-muted)]" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
              </svg>
              <h4 class="text-lg font-medium text-[var(--color-text-secondary)]">macOS</h4>
              <span class="ml-auto px-2 py-0.5 text-xs font-medium rounded border text-[var(--color-text-muted)] bg-[var(--color-surface-overlay)] border-[var(--color-surface-border)]">Coming Soon</span>
            </div>
            <ul class="text-[var(--color-text-muted)] space-y-2 text-sm">
              <li>macOS 12 Monterey or later</li>
              <li>Apple Silicon or Intel</li>
              <li>4 GB RAM minimum</li>
              <li>200 MB disk space</li>
              <li>Internet connection (for LLM API)</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- MEMX: Adaptive Context Engine for AI Memory           -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <section id="memx" class="relative py-20 sm:py-28 section-dark overflow-hidden">
      <div class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">

        <!-- ── HERO ── -->
        <div class="text-center mb-16">
          <div class="inline-flex items-center gap-2 px-3 py-1.5 mb-6 border-2 border-ochre/30 bg-ochre/5 text-ochre text-sm font-medium" style="border-radius: 9999px">
            <span class="w-2 h-2 rounded-full bg-green-500"></span>
            Python · ACE Engine · Open Source
          </div>

          <h2 class="text-5xl sm:text-6xl font-bold text-[var(--color-text-primary)] mb-3">MemX</h2>
          <p class="text-xl sm:text-2xl text-[var(--color-text-secondary)] mb-2 font-medium">Adaptive Context Engine for AI Memory</p>
          <p class="text-lg text-[var(--color-text-muted)] mb-10">
            零 LLM 成本的自适应 AI 记忆框架 — 让智能体真正学会记忆与遗忘
          </p>

          <!-- pip install + copy -->
          <div class="inline-flex items-center gap-0 mb-8 card-dark overflow-hidden">
            <code class="px-6 py-3 font-mono text-base text-[var(--color-text-secondary)] bg-[var(--color-surface-overlay)] select-all">pip install memx</code>
            <button
              @click="copyPipInstall"
              class="px-4 py-3 bg-ochre/10 border-l-2 border-ochre/20 hover:bg-ochre/20 transition-colors text-sm text-ochre font-medium whitespace-nowrap"
            >
              {{ memxCopied ? '✓ Copied' : 'Copy' }}
            </button>
          </div>

          <!-- CTA buttons -->
          <div class="flex flex-col sm:flex-row items-center justify-center gap-4 mb-8">
            <a
              href="https://github.com/UU114/memx"
              target="_blank"
              rel="noopener noreferrer"
              class="btn-primary inline-flex items-center gap-2 px-6 py-3"
            >
              <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C6.477 2 2 6.477 2 12c0 4.42 2.865 8.17 6.839 9.49.5.092.682-.217.682-.482 0-.237-.008-.866-.013-1.7-2.782.603-3.369-1.342-3.369-1.342-.454-1.155-1.11-1.463-1.11-1.463-.908-.62.069-.608.069-.608 1.003.07 1.531 1.03 1.531 1.03.892 1.529 2.341 1.087 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.11-4.555-4.943 0-1.091.39-1.984 1.029-2.683-.103-.253-.446-1.27.098-2.647 0 0 .84-.269 2.75 1.025A9.578 9.578 0 0112 6.836c.85.004 1.705.114 2.504.336 1.909-1.294 2.747-1.025 2.747-1.025.546 1.377.202 2.394.1 2.647.64.699 1.028 1.592 1.028 2.683 0 3.842-2.339 4.687-4.566 4.935.359.309.678.919.678 1.852 0 1.336-.012 2.415-.012 2.741 0 .267.18.579.688.481C19.138 20.167 22 16.418 22 12c0-5.523-4.477-10-10-10z"/>
              </svg>
              GitHub
            </a>
            <a
              href="https://docs.lurus.cn"
              target="_blank"
              rel="noopener noreferrer"
              class="btn-outline inline-flex items-center gap-2 px-6 py-3"
            >
              查看文档
            </a>
          </div>

          <!-- Trust signals -->
          <div class="flex flex-wrap items-center justify-center gap-4 text-sm text-[var(--color-text-muted)]">
            <span class="flex items-center gap-1.5">
              <span class="text-ochre">★</span> ACE 4-layer retrieval
            </span>
            <span class="text-[var(--color-surface-border)]">|</span>
            <span class="flex items-center gap-1.5">
              <span class="text-green-500">●</span> Zero LLM cost
            </span>
            <span class="text-[var(--color-surface-border)]">|</span>
            <span class="flex items-center gap-1.5">
              <span class="text-blue-400">⇌</span> mem0 drop-in compatible
            </span>
          </div>
        </div>

        <!-- ── FEATURE 4-GRID ── -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-16">
          <div class="card-dark p-5 hover:border-ochre/40 transition-colors">
            <div class="w-10 h-10 rounded-lg bg-green-900/20 border border-green-700/40 flex items-center justify-center mb-3">
              <svg class="w-5 h-5 text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
            </div>
            <h3 class="text-base font-bold text-[var(--color-text-primary)] mb-1">零 LLM 成本</h3>
            <p class="text-xs text-ochre mb-2">规则引擎替代 LLM 调用</p>
            <p class="text-xs text-[var(--color-text-muted)] leading-relaxed">ACE 规则引擎提取知识，余弦相似度去重，无需每次调用 LLM，节省 2-5k tokens/次。</p>
          </div>
          <div class="card-dark p-5 hover:border-ochre/40 transition-colors">
            <div class="w-10 h-10 rounded-lg bg-purple-900/20 border border-purple-700/40 flex items-center justify-center mb-3">
              <svg class="w-5 h-5 text-purple-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h3 class="text-base font-bold text-[var(--color-text-primary)] mb-1">智能遗忘</h3>
            <p class="text-xs text-ochre mb-2">指数衰减 + 召回增强</p>
            <p class="text-xs text-[var(--color-text-muted)] leading-relaxed">半衰期 30 天自动衰减，召回 ≥15 次永久保留，防止知识无限膨胀。</p>
          </div>
          <div class="card-dark p-5 hover:border-ochre/40 transition-colors">
            <div class="w-10 h-10 rounded-lg bg-blue-900/20 border border-blue-700/40 flex items-center justify-center mb-3">
              <svg class="w-5 h-5 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
            </div>
            <h3 class="text-base font-bold text-[var(--color-text-primary)] mb-1">隐私优先</h3>
            <p class="text-xs text-ochre mb-2">处理前自动清理 PII</p>
            <p class="text-xs text-[var(--color-text-muted)] leading-relaxed">内置 12 种正则模式 + 自定义规则，自动识别并清理 API Key、手机号、邮箱等敏感信息。</p>
          </div>
          <div class="card-dark p-5 hover:border-ochre/40 transition-colors">
            <div class="w-10 h-10 rounded-lg bg-ochre/10 border-2 border-ochre/30 flex items-center justify-center mb-3">
              <svg class="w-5 h-5 text-ochre" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
            <h3 class="text-base font-bold text-[var(--color-text-primary)] mb-1">混合检索</h3>
            <p class="text-xs text-ochre mb-2">精确 + 模糊 + 元数据 + 向量</p>
            <p class="text-xs text-[var(--color-text-muted)] leading-relaxed">4 层评分融合：keyword×0.6 + semantic×0.4，再乘以衰减权重与时近度提升。</p>
          </div>
        </div>

        <!-- ── ACE PIPELINE VISUALIZATION ── -->
        <div class="card-dark p-8 mb-10">
          <h3 class="text-lg font-bold text-[var(--color-text-primary)] mb-6 text-center">ACE Pipeline</h3>

          <!-- Ingest -->
          <div class="mb-6">
            <p class="text-xs uppercase tracking-widest text-[var(--color-text-muted)] mb-3 font-medium text-center">Ingest — add()</p>
            <div class="flex flex-col sm:flex-row items-center justify-center gap-2 sm:gap-0 text-xs font-mono text-[var(--color-text-secondary)]">
              <div class="px-3 py-2 bg-ochre/10 border border-ochre/30 rounded whitespace-nowrap text-ochre font-bold">add()</div>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <div class="px-3 py-2 bg-blue-900/20 border border-blue-700/40 text-blue-300 rounded whitespace-nowrap">Privacy Sanitizer</div>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <div class="px-3 py-2 bg-green-900/20 border border-green-700/40 text-green-300 rounded whitespace-nowrap">Reflector</div>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <div class="px-3 py-2 bg-purple-900/20 border border-purple-700/40 text-purple-300 rounded whitespace-nowrap">Curator</div>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <div class="px-3 py-2 bg-amber-900/20 border border-amber-700/40 text-amber-300 rounded whitespace-nowrap">mem0 Backend</div>
            </div>
          </div>

          <!-- Retrieve -->
          <div>
            <p class="text-xs uppercase tracking-widest text-[var(--color-text-muted)] mb-3 font-medium text-center">Retrieve — search()</p>
            <div class="flex flex-col sm:flex-row items-center justify-center gap-2 sm:gap-0 text-xs font-mono text-[var(--color-text-secondary)]">
              <div class="px-3 py-2 bg-ochre/10 border border-ochre/30 rounded whitespace-nowrap text-ochre font-bold">search()</div>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <div class="px-3 py-2 bg-blue-900/20 border border-blue-700/40 text-blue-300 rounded whitespace-nowrap">4-layer scoring</div>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <div class="px-3 py-2 bg-purple-900/20 border border-purple-700/40 text-purple-300 rounded whitespace-nowrap">decay weight</div>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] hidden sm:block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <svg class="w-5 h-5 text-[var(--color-text-muted)] sm:hidden flex-shrink-0 rotate-90" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
              <div class="px-3 py-2 bg-green-900/20 border border-green-700/40 text-green-300 rounded whitespace-nowrap">result</div>
            </div>
            <p class="text-center text-xs text-[var(--color-text-muted)] mt-3 font-mono">
              score = (keyword×0.6 + semantic×0.4) × decay_weight × recency_boost
            </p>
          </div>
        </div>

        <!-- ── COMPARISON TABLE ── -->
        <div class="mb-10">
          <h3 class="text-xl font-bold text-[var(--color-text-primary)] mb-5 text-center">MemX vs mem0</h3>
          <div class="card-dark overflow-hidden">
            <table class="w-full text-sm">
              <thead>
                <tr class="bg-[var(--color-surface-overlay)]">
                  <th class="text-left p-4 font-semibold text-[var(--color-text-secondary)] w-1/3">能力</th>
                  <th class="text-center p-4 font-semibold text-[var(--color-text-muted)] w-1/3">mem0</th>
                  <th class="text-center p-4 font-semibold text-ochre w-1/3">MemX</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-[var(--color-surface-border)]">
                <tr class="hover:bg-white/5 transition-colors">
                  <td class="p-4 text-[var(--color-text-secondary)] font-medium">知识提取</td>
                  <td class="p-4 text-center text-[var(--color-text-muted)]">LLM 调用（2-5k tokens/次）</td>
                  <td class="p-4 text-center text-green-400 font-medium">规则引擎（零 LLM 开销）</td>
                </tr>
                <tr class="hover:bg-white/5 transition-colors">
                  <td class="p-4 text-[var(--color-text-secondary)] font-medium">去重策略</td>
                  <td class="p-4 text-center text-[var(--color-text-muted)]">LLM 逐条决策</td>
                  <td class="p-4 text-center text-green-400 font-medium">余弦相似度 ≥0.8 自动合并</td>
                </tr>
                <tr class="hover:bg-white/5 transition-colors">
                  <td class="p-4 text-[var(--color-text-secondary)] font-medium">遗忘机制</td>
                  <td class="p-4 text-center text-[var(--color-text-muted)]">无，永久存储</td>
                  <td class="p-4 text-center text-green-400 font-medium">指数衰减 + 召回增强</td>
                </tr>
                <tr class="hover:bg-white/5 transition-colors">
                  <td class="p-4 text-[var(--color-text-secondary)] font-medium">搜索方式</td>
                  <td class="p-4 text-center text-[var(--color-text-muted)]">仅向量搜索</td>
                  <td class="p-4 text-center text-green-400 font-medium">精确+模糊+元数据+向量 4 层</td>
                </tr>
                <tr class="hover:bg-white/5 transition-colors">
                  <td class="p-4 text-[var(--color-text-secondary)] font-medium">离线嵌入</td>
                  <td class="p-4 text-center text-[var(--color-text-muted)]">需外部 API</td>
                  <td class="p-4 text-center text-green-400 font-medium">ONNX Runtime 本地运行</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- ── CODE EXAMPLE ── -->
        <div class="card-dark p-6">
          <h3 class="text-base font-bold text-[var(--color-text-primary)] mb-4">Quick Start</h3>
          <pre class="font-mono text-sm text-[var(--color-text-secondary)] bg-[var(--color-surface-overlay)] rounded p-5 overflow-x-auto leading-relaxed"><code><span class="text-purple-400">from</span> memx <span class="text-purple-400">import</span> Memory

<span class="text-[var(--color-text-muted)]"># Drop-in compatible with mem0 API</span>
m = Memory(ace_enabled=<span class="text-blue-400">True</span>)

<span class="text-[var(--color-text-muted)]"># Store memory — auto privacy-sanitized &amp; deduplicated</span>
m.add(<span class="text-green-400">"prefer dark mode, use Python 3.12"</span>, user_id=<span class="text-green-400">"alice"</span>)

<span class="text-[var(--color-text-muted)]"># Hybrid 4-layer retrieval with decay scoring</span>
results = m.search(<span class="text-green-400">"UI preference"</span>, user_id=<span class="text-green-400">"alice"</span>)
<span class="text-[var(--color-text-muted)]"># score = (keyword×0.6 + semantic×0.4) × decay_weight × recency_boost</span></code></pre>
        </div>

      </div>
    </section>

    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- ALL RELEASES (API-driven) -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <section id="all-releases" class="py-16 section-dark">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between mb-8">
          <h2 class="text-2xl font-bold text-[var(--color-text-primary)]">
            All Products
          </h2>
          <router-link
            to="/releases"
            class="text-sm text-ochre hover:text-ochre/80 font-medium transition-colors inline-flex items-center gap-1"
          >
            Version History
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </router-link>
        </div>

        <!-- Loading skeleton -->
        <div v-if="loadingProducts" class="space-y-4">
          <div v-for="i in 4" :key="i" class="card-dark p-6 animate-pulse flex items-center gap-4">
            <div class="w-10 h-10 rounded-lg bg-[var(--color-surface-overlay)]"></div>
            <div class="flex-1">
              <div class="w-32 h-5 bg-[var(--color-surface-overlay)] rounded mb-2"></div>
              <div class="w-48 h-4 bg-[var(--color-surface-overlay)] rounded"></div>
            </div>
            <div class="w-24 h-10 bg-[var(--color-surface-overlay)] rounded"></div>
          </div>
        </div>

        <!-- Product list -->
        <div v-else class="space-y-4">
          <div
            v-for="item in allReleaseItems"
            :key="item.productId"
            class="card-dark p-6 flex flex-col sm:flex-row sm:items-center gap-4"
            :class="item.status === 'coming-soon' ? 'opacity-60' : ''"
          >
            <!-- Product icon -->
            <div
              class="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
              :style="{ backgroundColor: item.color + '15', border: '2px solid ' + item.color + '30' }"
            >
              <svg v-if="productIconPaths[item.icon]" class="w-5 h-5" :style="{ color: item.color }" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="productIconPaths[item.icon]" />
              </svg>
              <PlatformIcon v-else-if="item.icon === 'mobile'" platform="android" size="md" />
            </div>

            <!-- Product info -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-3 mb-1 flex-wrap">
                <h3 class="text-lg font-bold text-[var(--color-text-primary)]">{{ item.product }}</h3>
                <span
                  class="px-2 py-0.5 text-xs font-medium rounded border"
                  :class="item.status === 'available'
                    ? 'text-green-400 bg-green-900/20 border-green-700/40'
                    : 'text-[var(--color-text-muted)] bg-[var(--color-surface-overlay)] border-[var(--color-surface-border)]'"
                >
                  {{ item.status === 'available' ? item.version : 'Coming Soon' }}
                </span>
                <span v-if="item.release?.release_type === 'beta'" class="px-2 py-0.5 text-xs font-medium rounded border text-yellow-700 bg-yellow-50 border-yellow-300">
                  Beta
                </span>
              </div>
              <p class="text-sm text-[var(--color-text-muted)]">{{ item.platform }}</p>
              <div class="flex items-center gap-3 mt-1">
                <p v-if="item.size !== '—'" class="text-xs text-[var(--color-text-muted)]">{{ item.size }}</p>
                <span v-if="item.downloadCount > 0" class="text-xs text-[var(--color-text-muted)]">
                  {{ item.downloadCount.toLocaleString() }} downloads
                </span>
              </div>
            </div>

            <!-- Action button -->
            <div class="flex-shrink-0">
              <!-- Binary download (API or static fallback) -->
              <button
                v-if="((item.release && item.recommended) || item.fallbackUrl) && item.installMethod === 'binary'"
                @click="handleItemDownload(item)"
                class="btn-primary inline-flex items-center gap-2 text-sm px-5 py-2.5 whitespace-nowrap"
              >
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                </svg>
                Download
              </button>

              <!-- Install command (pip/cargo) -->
              <code
                v-else-if="item.installCommand"
                class="font-mono text-sm px-4 py-2.5 bg-[var(--color-surface-overlay)] border border-[var(--color-surface-border)] text-[var(--color-text-secondary)] whitespace-nowrap rounded-xl"
              >
                {{ item.installCommand }}
              </code>

              <!-- Coming soon -->
              <span
                v-else-if="item.status === 'coming-soon'"
                class="btn-outline inline-flex items-center gap-2 text-sm px-5 py-2.5 opacity-50 cursor-not-allowed whitespace-nowrap"
              >
                Coming Soon
              </span>

              <!-- Changelog link for released products -->
              <router-link
                v-if="item.release || item.fallbackUrl"
                :to="{ path: '/releases', query: { product: item.productId } }"
                class="block text-xs text-ochre hover:text-ochre/80 mt-2 text-right"
              >
                Changelog →
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
