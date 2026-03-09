<script setup lang="ts">
import { ref, computed } from 'vue'
import { portalCategories, type PortalLink } from '../../data/portalLinks'
import { useTracking } from '../../composables/useTracking'
import { useChatFeature } from '../../composables/useChatFeature'
import { DRAG_MIME } from '../../utils/portalDrag'
import CTABar from '../CTAs/CTABar.vue'
import PortalChatPreview from './PortalChatPreview.vue'

const PREVIEW_LINK_COUNT = 4
const TOTAL_LINK_COUNT = 56

const { track } = useTracking()
const { isChatEnabled } = useChatFeature()
const isExpanded = ref(false)

const toggleExpand = () => {
  isExpanded.value = !isExpanded.value
}

/**
 * Return the links to display for a given category.
 * In collapsed mode, show only the first PREVIEW_LINK_COUNT links.
 */
const getDisplayedLinks = (links: typeof portalCategories[number]['links']) => {
  if (isExpanded.value) {
    return links
  }
  return links.slice(0, PREVIEW_LINK_COUNT)
}

const toggleLabel = computed(() =>
  isExpanded.value ? '收起链接' : `探索全部 ${TOTAL_LINK_COUNT} 个链接`
)

const trackPortalClick = (linkName: string, category: string) => {
  track('portal_link_click', { link_name: linkName, link_category: category })
}

const draggingLink = ref(false)

const handleDragStart = (e: DragEvent, link: PortalLink, categoryName: string) => {
  e.dataTransfer?.setData(DRAG_MIME, JSON.stringify({
    name: link.name,
    url: link.url,
    desc: link.desc || '',
    category: categoryName,
  }))
  e.dataTransfer!.effectAllowed = 'copy'
  draggingLink.value = true
}

const handleDragEnd = () => {
  draggingLink.value = false
}
</script>

<template>
  <section id="portal" aria-label="资源中心" class="py-fib-7 bg-cream-100 relative overflow-hidden">
    <!-- Background texture -->
    <div class="absolute inset-0 opacity-[0.02]" aria-hidden="true" style="background-image: linear-gradient(#A89B8B 1px, transparent 1px), linear-gradient(90deg, #A89B8B 1px, transparent 1px); background-size: 34px 34px;"></div>

    <!-- Corner decorations -->
    <div class="doodle-corner absolute top-8 left-8 opacity-40" aria-hidden="true"></div>
    <div class="doodle-corner absolute top-8 right-8 -scale-x-100 opacity-40" aria-hidden="true"></div>
    <div class="doodle-corner absolute bottom-8 left-8 -scale-y-100 opacity-40" aria-hidden="true"></div>
    <div class="doodle-corner absolute bottom-8 right-8 scale-[-1] opacity-40" aria-hidden="true"></div>

    <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Section Header -->
      <div class="text-center mb-fib-6 reveal-fade-up">
        <h2 class="text-phi-2xl sm:text-phi-3xl text-ink-900 mb-fib-3 font-semibold">
          资源中心
        </h2>
        <p class="text-phi-xl text-ink-500 max-w-2xl mx-auto">
          为使用 Lurus 的开发者精选的专业资源库
        </p>
      </div>

      <!-- Portal Content -->
      <div
        data-testid="portal-content-layout"
        class="portal-content-layout"
        :class="{ 'has-chat': isChatEnabled }"
      >
        <!-- Left: Portal Categories (60% on desktop when Chat enabled) -->
        <div class="portal-links-area">
          <!-- Portal Categories Grid -->
          <!-- Desktop: 3 cols x 2 rows | Tablet: 2 cols x 3 rows | Mobile: 1 col x 6 rows -->
          <div
            data-testid="portal-grid"
            class="grid gap-6 lg:gap-8 reveal-stagger grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
          >
            <div
              v-for="category in portalCategories"
              :key="category.id"
              data-testid="portal-category-card"
              class="portal-category-card"
              :style="{ '--category-color': category.color }"
            >
              <!-- Category Header -->
              <div class="flex items-center gap-3 mb-5">
                <div
                  data-testid="category-color-dot"
                  class="w-4 h-4 rounded-full flex-shrink-0"
                  :style="{ backgroundColor: category.color }"
                ></div>
                <h3 class="text-xl text-ink-900 font-semibold">{{ category.name }}</h3>
                <span class="text-sm text-ink-300">{{ category.nameEn }}</span>
              </div>

              <!-- Links Grid -->
              <div class="flex flex-wrap gap-3">
                <a
                  v-for="link in getDisplayedLinks(category.links)"
                  :key="link.name"
                  :href="link.url"
                  target="_blank"
                  rel="noopener noreferrer"
                  draggable="true"
                  class="portal-link-btn group"
                  :class="[category.colorClass, { 'is-dragging': draggingLink }]"
                  :title="link.desc"
                  @click="trackPortalClick(link.name, category.id)"
                  @dragstart="handleDragStart($event, link, category.name)"
                  @dragend="handleDragEnd"
                >
                  <span>{{ link.name }}</span>
                  <svg class="w-3 h-3 ml-1 opacity-0 group-hover:opacity-100 transition-opacity" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                  </svg>
                </a>
              </div>
            </div>
          </div>

          <!-- Expand/Collapse Toggle -->
          <div class="text-center mt-fib-5">
            <button
              data-testid="portal-expand-toggle"
              class="btn-hand inline-flex items-center gap-2 text-ink-700 hover:text-ink-900"
              @click="toggleExpand"
            >
              <span>{{ toggleLabel }}</span>
              <svg
                class="w-4 h-4 transition-transform"
                :class="{ 'rotate-180': isExpanded }"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
          </div>
        </div>

        <!-- Right: Chat Preview (40% on desktop, hidden on mobile unless expanded) -->
        <div v-if="isChatEnabled" class="portal-chat-area">
          <PortalChatPreview />
        </div>
      </div>
    </div>

    <!-- CTA Bar at bottom of Portal section -->
    <CTABar
      message="需要 API 访问？"
      :primary-cta="{
        text: '获取 API Key',
        href: 'https://api.lurus.cn',
        ariaLabel: '跳转到 API Key 注册页面'
      }"
    />
  </section>
</template>

<style scoped>
@reference "../../styles/main.css";

.portal-category-card {
  background-color: var(--color-cream-50);
  border: 2px solid var(--color-ink-100);
  border-left: 4px solid var(--category-color);
  border-radius: 4px 15px 8px 12px / 12px 8px 15px 4px;
  padding: 28px;
  transition: all 0.3s ease;
}

.portal-category-card:hover {
  box-shadow: 4px 4px 0 var(--color-ink-100);
  transform: translate(-2px, -2px);
}

/* Grid layout: 60/40 split when chat is enabled */
.portal-content-layout.has-chat {
  display: grid;
  grid-template-columns: 1fr;
  gap: 34px;
}

@media (min-width: 1024px) {
  .portal-content-layout.has-chat {
    grid-template-columns: 3fr 2fr;
  }
}

.portal-chat-area {
  display: none;
}

@media (min-width: 1024px) {
  .portal-chat-area {
    display: block;
    position: sticky;
    top: 100px;
    align-self: start;
  }
}

/* Dragging feedback: reduce opacity on all links while one is being dragged */
.portal-link-btn.is-dragging {
  opacity: 0.6;
  cursor: grabbing;
}

.portal-link-btn[draggable="true"] {
  cursor: grab;
}
</style>
