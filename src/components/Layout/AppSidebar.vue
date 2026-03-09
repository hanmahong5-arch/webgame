<script setup lang="ts">
import SidebarSection from './SidebarSection.vue'
import { sidebarSections } from '../../data/sidebarItems'
import { useSidebar } from '../../composables/useSidebar'

const { isCollapsed, isMobileOpen, closeMobile } = useSidebar()
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
      class="fixed inset-0 z-30 bg-ink-900/40 md:hidden"
      aria-hidden="true"
      @click="closeMobile"
    />
  </Transition>

  <!-- Sidebar -->
  <aside
    class="app-sidebar"
    :class="{
      'app-sidebar--collapsed': isCollapsed,
      'app-sidebar--mobile-open': isMobileOpen,
    }"
    aria-label="Business navigation"
  >
    <nav class="app-sidebar-nav">
      <SidebarSection
        v-for="section in sidebarSections"
        :key="section.key"
        :section="section"
        :collapsed="isCollapsed"
      />
    </nav>
  </aside>
</template>

<style scoped>
@reference "../../styles/main.css";

.app-sidebar {
  grid-area: sidebar;
  width: 224px;
  background-color: var(--color-cream-50);
  border-right: 1px solid var(--color-ink-100);
  overflow-y: auto;
  overflow-x: hidden;
  transition: width 0.2s ease;
}

.app-sidebar--collapsed {
  width: 60px;
}

/* Mobile: off-canvas drawer */
@media (max-width: 767px) {
  .app-sidebar {
    position: fixed;
    top: 44px;
    left: 0;
    bottom: 0;
    z-index: 35;
    width: 260px;
    transform: translateX(-100%);
    transition: transform 0.2s ease;
  }

  .app-sidebar--mobile-open {
    transform: translateX(0);
  }
}

.app-sidebar-nav {
  padding: 8px 0;
}
</style>
