<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { pageSidebarConfigs } from '../../../data/pageSidebarConfig'
import { usePageToc } from '../../../composables/usePageToc'
import { useSidebar } from '../../../composables/useSidebar'
import SidebarToc from './SidebarToc.vue'
import SidebarProductList from './SidebarProductList.vue'
import SidebarLinkList from './SidebarLinkList.vue'
import SidebarCta from './SidebarCta.vue'

const route = useRoute()
const { isCollapsed, isMobileOpen, closeMobile } = useSidebar()

const config = computed(() => {
  const name = route.name as string
  return pageSidebarConfigs[name] ?? null
})

const anchors = computed(() =>
  config.value?.toc.items.map(i => i.anchor) ?? [],
)

const { activeAnchor } = usePageToc(anchors)
</script>

<template>
  <!-- Mobile overlay backdrop -->
  <Transition
    enter-active-class="transition-opacity duration-200 ease-out"
    enter-from-class="opacity-0"
    enter-to-class="opacity-100"
    leave-active-class="transition-opacity duration-200 ease-in"
    leave-from-class="opacity-100"
    leave-to-class="opacity-0"
  >
    <div
      v-if="isMobileOpen"
      class="fixed inset-0 z-30 bg-black/40 md:hidden"
      aria-hidden="true"
      @click="closeMobile"
    />
  </Transition>

  <aside
    v-if="config"
    class="page-sidebar"
    :class="{
      'page-sidebar--collapsed': isCollapsed,
      'page-sidebar--mobile-open': isMobileOpen,
    }"
    aria-label="Page navigation"
  >
    <nav class="page-sidebar-nav">
      <!-- TOC -->
      <SidebarToc
        :label="config.toc.label"
        :items="config.toc.items"
        :active-anchor="activeAnchor"
        :collapsed="isCollapsed"
      />

      <!-- Divider -->
      <hr v-if="config.products || config.links" class="sidebar-divider" />

      <!-- Products -->
      <SidebarProductList
        v-if="config.products"
        :label="config.products.label"
        :items="config.products.items"
        :collapsed="isCollapsed"
        :initial-collapsed="config.products.collapsed"
      />

      <!-- Links -->
      <SidebarLinkList
        v-if="config.links"
        :label="config.links.label"
        :items="config.links.items"
        :collapsed="isCollapsed"
      />

      <!-- CTA -->
      <template v-if="config.cta?.length">
        <hr class="sidebar-divider" />
        <SidebarCta :items="config.cta" :collapsed="isCollapsed" />
      </template>
    </nav>
  </aside>
</template>

<style scoped>
@reference "../../../styles/main.css";

.page-sidebar {
  grid-area: sidebar;
  width: 224px;
  background-color: var(--color-surface-raised);
  border-right: 1px solid var(--color-surface-border);
  overflow-y: auto;
  overflow-x: hidden;
  transition: width 0.2s ease;
}

.page-sidebar--collapsed {
  width: 60px;
}

/* Mobile: off-canvas drawer */
@media (max-width: 767px) {
  .page-sidebar {
    position: fixed;
    top: 64px;
    left: 0;
    bottom: 0;
    z-index: 35;
    width: 260px;
    transform: translateX(-100%);
    transition: transform 0.2s ease;
  }

  .page-sidebar--mobile-open {
    transform: translateX(0);
  }
}

.page-sidebar-nav {
  padding: 12px 4px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.sidebar-divider {
  border: none;
  border-top: 1px solid var(--color-surface-border);
  margin: 0 8px;
}
</style>
