<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useReleases } from '../composables/useReleases'
import {
  downloadableProducts,
  getProductByReleaseId,
} from '../data/downloadableProducts'
import { productIconPaths } from '../data/products'
import type { ReleaseType, Release } from '../types/release'
import PlatformIcon from '../components/Download/PlatformIcon.vue'
import { Marked } from 'marked'

const route = useRoute()
const router = useRouter()
const {
  releases,
  total,
  currentPage,
  pageSize,
  isLoading,
  error,
  fetchReleases,
  findRecommendedArtifact,
  formatFileSize,
  getPlatformName,
  getArchName,
  downloadArtifact,
  getDownloadUrl,
} = useReleases()

const marked = new Marked({ async: false })

// Filter state
const selectedProduct = ref<string | null>(null)
const selectedType = ref<ReleaseType | null>(null)
const includePrerelease = ref(false)

// Expand state for changelog
const expandedReleases = ref<Set<number>>(new Set())

// Set initial filter from route param
onMounted(() => {
  const productParam = route.query.product as string | undefined
  if (productParam) {
    const match = downloadableProducts.find(
      p => p.id === productParam || p.releaseProductId === productParam
    )
    if (match) selectedProduct.value = match.releaseProductId
  }
  loadReleases()
})

// Reload when filters change
watch([selectedProduct, selectedType, includePrerelease], () => {
  loadReleases(1)
})

async function loadReleases(page = 1) {
  await fetchReleases({
    product_id: selectedProduct.value || undefined,
    release_type: selectedType.value || undefined,
    include_prerelease: includePrerelease.value || undefined,
    page,
    page_size: 10,
  })
}

function loadPage(page: number) {
  loadReleases(page)
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const totalPages = computed(() => Math.ceil(total.value / pageSize.value))

function toggleChangelog(releaseId: number) {
  if (expandedReleases.value.has(releaseId)) {
    expandedReleases.value.delete(releaseId)
  } else {
    expandedReleases.value.add(releaseId)
  }
}

function renderChangelog(md: string): string {
  if (!md) return ''
  return marked.parse(md) as string
}

function getProductDisplayName(productId: string): string {
  const product = getProductByReleaseId(productId)
  return product?.name || productId
}

function getProductIcon(productId: string): string | null {
  const product = getProductByReleaseId(productId)
  return product?.icon || null
}

function getProductColor(productId: string): string {
  const product = getProductByReleaseId(productId)
  return product?.color || '#D4A827'
}

function relativeDate(dateStr: string): string {
  const date = new Date(dateStr)
  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

  if (diffDays === 0) return '今天'
  if (diffDays === 1) return '昨天'
  if (diffDays < 7) return `${diffDays} 天前`
  if (diffDays < 30) return `${Math.floor(diffDays / 7)} 周前`
  if (diffDays < 365) return `${Math.floor(diffDays / 30)} 个月前`
  return `${Math.floor(diffDays / 365)} 年前`
}

function fullDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

// Group releases by month
const groupedReleases = computed(() => {
  const groups: { label: string; releases: Release[] }[] = []
  let currentLabel = ''

  for (const release of releases.value) {
    const date = new Date(release.published_at || release.created_at)
    const label = date.toLocaleDateString('zh-CN', { year: 'numeric', month: 'long' })
    if (label !== currentLabel) {
      currentLabel = label
      groups.push({ label, releases: [] })
    }
    groups[groups.length - 1].releases.push(release)
  }

  return groups
})

function selectProduct(releaseProductId: string | null) {
  selectedProduct.value = releaseProductId
  // Update URL query without navigation
  const query = { ...route.query }
  if (releaseProductId) {
    const product = getProductByReleaseId(releaseProductId)
    query.product = product?.id || releaseProductId
  } else {
    delete query.product
  }
  router.replace({ query })
}
</script>

<template>
  <div>
    <!-- Header -->
    <section class="py-16 sm:py-20 bg-cream-100">
      <div class="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h1 class="text-4xl sm:text-5xl font-bold text-ink-900 mb-4 font-hand">
          Release History
        </h1>
        <p class="text-lg text-ink-500 max-w-2xl mx-auto">
          Track updates across all Lurus products — changelogs, downloads, and version history
        </p>
      </div>
    </section>

    <!-- Filter Bar -->
    <section class="sticky top-16 z-30 bg-cream-50 border-b-2 border-ink-100">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center gap-3 py-3 overflow-x-auto">
          <!-- Product filter tabs -->
          <button
            @click="selectProduct(null)"
            class="px-4 py-2 text-sm font-medium whitespace-nowrap border-2 transition-all"
            :class="selectedProduct === null
              ? 'bg-ochre/10 text-ochre border-ochre/30'
              : 'bg-transparent text-ink-400 border-transparent hover:text-ink-600 hover:border-ink-200'"
            style="border-radius: 3px 10px 5px 12px / 12px 5px 10px 3px"
          >
            All
          </button>
          <button
            v-for="product in downloadableProducts"
            :key="product.id"
            @click="selectProduct(product.releaseProductId)"
            class="px-4 py-2 text-sm font-medium whitespace-nowrap border-2 transition-all inline-flex items-center gap-2"
            :class="selectedProduct === product.releaseProductId
              ? 'bg-ochre/10 text-ochre border-ochre/30'
              : 'bg-transparent text-ink-400 border-transparent hover:text-ink-600 hover:border-ink-200'"
            style="border-radius: 3px 10px 5px 12px / 12px 5px 10px 3px"
          >
            {{ product.name }}
          </button>

          <!-- Spacer -->
          <div class="flex-1"></div>

          <!-- Release type filter -->
          <select
            v-model="selectedType"
            class="px-3 py-2 text-sm border-2 border-ink-200 bg-cream-50 text-ink-600 focus:border-ochre/50 focus:outline-none"
            style="border-radius: 3px 10px 5px 12px / 12px 5px 10px 3px"
          >
            <option :value="null">All Types</option>
            <option value="stable">Stable</option>
            <option value="beta">Beta</option>
            <option value="alpha">Alpha</option>
          </select>

          <!-- Pre-release toggle -->
          <label class="hidden sm:inline-flex items-center gap-2 text-sm text-ink-400 cursor-pointer whitespace-nowrap">
            <input
              type="checkbox"
              v-model="includePrerelease"
              class="accent-ochre"
            >
            Pre-release
          </label>
        </div>
      </div>
    </section>

    <!-- Content -->
    <section class="py-12 bg-cream-50 min-h-[50vh]">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">

        <!-- Loading skeleton -->
        <div v-if="isLoading && releases.length === 0" class="space-y-6">
          <div v-for="i in 3" :key="i" class="card-sketchy p-6 animate-pulse">
            <div class="flex items-center gap-3 mb-4">
              <div class="w-20 h-5 bg-cream-200 rounded"></div>
              <div class="w-16 h-5 bg-cream-200 rounded"></div>
            </div>
            <div class="w-full h-4 bg-cream-200 rounded mb-2"></div>
            <div class="w-2/3 h-4 bg-cream-200 rounded"></div>
          </div>
        </div>

        <!-- Error state -->
        <div v-else-if="error && releases.length === 0" class="text-center py-16">
          <div class="card-sketchy inline-block p-8 max-w-md border-orange-300">
            <svg class="w-12 h-12 text-orange-400 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <p class="text-ink-700 font-medium mb-2">Unable to load releases</p>
            <p class="text-ink-400 text-sm mb-4">{{ error }}</p>
            <button
              @click="loadReleases()"
              class="btn-hand btn-hand-primary text-sm px-6 py-2"
            >
              Retry
            </button>
          </div>
        </div>

        <!-- Empty state -->
        <div v-else-if="!isLoading && releases.length === 0" class="text-center py-16">
          <div class="card-sketchy inline-block p-8 max-w-md">
            <svg class="w-12 h-12 text-ink-300 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
            </svg>
            <p class="text-ink-700 font-medium mb-2">No releases found</p>
            <p class="text-ink-400 text-sm">
              {{ selectedProduct ? 'This product has no releases yet. Check back later.' : 'No releases match your filters.' }}
            </p>
          </div>
        </div>

        <!-- Timeline -->
        <div v-else class="space-y-8">
          <div v-for="group in groupedReleases" :key="group.label">
            <!-- Month separator -->
            <div class="flex items-center gap-4 mb-4">
              <div class="h-px flex-1 bg-ink-100"></div>
              <span class="text-sm font-medium text-ink-300 whitespace-nowrap">{{ group.label }}</span>
              <div class="h-px flex-1 bg-ink-100"></div>
            </div>

            <!-- Release cards -->
            <div class="space-y-4">
              <div
                v-for="(release, index) in group.releases"
                :key="release.id"
                class="relative"
              >
                <!-- Timeline dot -->
                <div class="absolute -left-8 top-6 w-3 h-3 rounded-full border-2 border-cream-50 hidden lg:block"
                  :style="{ backgroundColor: getProductColor(release.product_id) }"
                ></div>

                <div class="card-sketchy overflow-hidden hover:border-ink-300 transition-colors">
                  <!-- Release header -->
                  <div class="p-5 sm:p-6">
                    <div class="flex items-start justify-between gap-4 flex-wrap">
                      <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2 flex-wrap mb-2">
                          <!-- Product badge -->
                          <span
                            class="inline-flex items-center gap-1.5 px-2.5 py-1 text-xs font-medium rounded border"
                            :style="{
                              borderColor: getProductColor(release.product_id) + '40',
                              backgroundColor: getProductColor(release.product_id) + '10',
                              color: getProductColor(release.product_id),
                            }"
                          >
                            <svg
                              v-if="getProductIcon(release.product_id) && productIconPaths[getProductIcon(release.product_id)!]"
                              class="w-3.5 h-3.5"
                              fill="none"
                              viewBox="0 0 24 24"
                              stroke="currentColor"
                            >
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="productIconPaths[getProductIcon(release.product_id)!]" />
                            </svg>
                            {{ getProductDisplayName(release.product_id) }}
                          </span>

                          <!-- Version -->
                          <span class="text-lg font-bold text-ink-900">v{{ release.version }}</span>

                          <!-- Release type badge -->
                          <span
                            class="px-2 py-0.5 text-xs font-medium rounded border"
                            :class="{
                              'text-green-700 bg-green-50 border-green-300': release.release_type === 'stable',
                              'text-yellow-700 bg-yellow-50 border-yellow-300': release.release_type === 'beta',
                              'text-orange-700 bg-orange-50 border-orange-300': release.release_type === 'alpha',
                            }"
                          >
                            {{ release.release_type === 'stable' ? 'Stable' : release.release_type === 'beta' ? 'Beta' : 'Alpha' }}
                          </span>

                          <!-- Latest badge -->
                          <span
                            v-if="index === 0 && group === groupedReleases[0]"
                            class="px-2 py-0.5 text-xs font-medium rounded border text-ochre bg-yellow-50 border-ochre/30"
                          >
                            Latest
                          </span>
                        </div>

                        <!-- Title + date -->
                        <h3 v-if="release.title" class="text-ink-700 font-medium mb-1">{{ release.title }}</h3>
                        <div class="flex items-center gap-3 text-sm text-ink-300">
                          <time :datetime="release.published_at || release.created_at" :title="fullDate(release.published_at || release.created_at)">
                            {{ relativeDate(release.published_at || release.created_at) }}
                          </time>
                          <span v-if="release.artifacts.length > 0">&middot;</span>
                          <span v-if="release.artifacts.length > 0">
                            {{ release.artifacts.reduce((sum, a) => sum + a.download_count, 0).toLocaleString() }} downloads
                          </span>
                        </div>
                      </div>

                      <!-- Quick download button -->
                      <div v-if="release.artifacts.length > 0" class="flex-shrink-0">
                        <button
                          v-if="findRecommendedArtifact(release.artifacts)"
                          @click="downloadArtifact(release.id, findRecommendedArtifact(release.artifacts)!.id)"
                          class="btn-hand btn-hand-primary text-sm px-4 py-2 inline-flex items-center gap-2"
                        >
                          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                          </svg>
                          {{ getPlatformName(findRecommendedArtifact(release.artifacts)!.platform) }}
                        </button>
                      </div>
                    </div>

                    <!-- Description -->
                    <p v-if="release.description" class="text-ink-500 text-sm mt-3">
                      {{ release.description }}
                    </p>

                    <!-- Artifacts (collapsed by default, show on expand) -->
                    <div v-if="release.artifacts.length > 1" class="mt-3 flex flex-wrap gap-2">
                      <a
                        v-for="artifact in release.artifacts"
                        :key="artifact.id"
                        :href="getDownloadUrl(release.id, artifact.id)"
                        class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs border-2 border-ink-100 hover:border-ink-300 text-ink-500 transition-colors"
                        style="border-radius: 3px 8px 4px 10px / 10px 4px 8px 3px"
                      >
                        <PlatformIcon :platform="artifact.platform" size="sm" />
                        {{ getPlatformName(artifact.platform) }} {{ getArchName(artifact.arch) }}
                        <span class="text-ink-300">({{ formatFileSize(artifact.file_size) }})</span>
                      </a>
                    </div>
                  </div>

                  <!-- Changelog toggle -->
                  <div v-if="release.changelog_md" class="border-t-2 border-ink-100">
                    <button
                      @click="toggleChangelog(release.id)"
                      class="w-full px-5 sm:px-6 py-3 flex items-center justify-between text-left hover:bg-cream-100/50 transition-colors"
                    >
                      <span class="text-sm text-ink-600 font-medium">Changelog</span>
                      <svg
                        :class="['w-4 h-4 text-ink-300 transition-transform', expandedReleases.has(release.id) ? 'rotate-180' : '']"
                        fill="none" viewBox="0 0 24 24" stroke="currentColor"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                      </svg>
                    </button>
                    <div
                      v-if="expandedReleases.has(release.id)"
                      class="px-5 sm:px-6 pb-5 sm:pb-6"
                    >
                      <div
                        class="changelog-content prose-sm text-ink-500"
                        v-html="renderChangelog(release.changelog_md)"
                      ></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="flex items-center justify-center gap-2 mt-12">
          <button
            :disabled="currentPage <= 1"
            @click="loadPage(currentPage - 1)"
            class="px-4 py-2 text-sm border-2 border-ink-200 text-ink-500 hover:border-ink-300 disabled:opacity-30 disabled:cursor-not-allowed"
            style="border-radius: 3px 10px 5px 12px / 12px 5px 10px 3px"
          >
            Previous
          </button>
          <span class="text-sm text-ink-400 px-3">
            {{ currentPage }} / {{ totalPages }}
          </span>
          <button
            :disabled="currentPage >= totalPages"
            @click="loadPage(currentPage + 1)"
            class="px-4 py-2 text-sm border-2 border-ink-200 text-ink-500 hover:border-ink-300 disabled:opacity-30 disabled:cursor-not-allowed"
            style="border-radius: 3px 10px 5px 12px / 12px 5px 10px 3px"
          >
            Next
          </button>
        </div>

      </div>
    </section>

    <!-- CTA: Back to downloads -->
    <section class="py-12 bg-cream-100">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <p class="text-ink-500 mb-4">Looking for the latest downloads?</p>
        <router-link to="/download" class="btn-hand btn-hand-primary inline-flex items-center gap-2 px-6 py-3">
          <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          Download Center
        </router-link>
      </div>
    </section>
  </div>
</template>

<style scoped>
/* Changelog rendered markdown styling */
.changelog-content :deep(h2) {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-ink-900, #1a1a1a);
  margin-top: 1rem;
  margin-bottom: 0.5rem;
}

.changelog-content :deep(h3) {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--color-ink-700, #4a4a4a);
  margin-top: 0.75rem;
  margin-bottom: 0.375rem;
}

.changelog-content :deep(ul) {
  list-style-type: disc;
  padding-left: 1.25rem;
  margin: 0.375rem 0;
}

.changelog-content :deep(li) {
  font-size: 0.875rem;
  line-height: 1.5;
  margin-bottom: 0.25rem;
}

.changelog-content :deep(code) {
  font-family: ui-monospace, SFMono-Regular, 'SF Mono', Menlo, monospace;
  font-size: 0.8125rem;
  padding: 0.125rem 0.375rem;
  border-radius: 3px;
  background-color: var(--color-cream-200, #e8e0d4);
}

.changelog-content :deep(p) {
  margin: 0.375rem 0;
  font-size: 0.875rem;
  line-height: 1.5;
}

.changelog-content :deep(a) {
  color: var(--color-ochre, #D4A827);
  text-decoration: underline;
}
</style>
