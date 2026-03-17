<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import TopBar from './TopBar.vue'
import AppSidebar from './AppSidebar.vue'
import Footer from './Footer.vue'
import { useSidebar } from '../../composables/useSidebar'

const route = useRoute()
const { isCollapsed } = useSidebar()

const hideSidebar = computed(() => route.meta.hideSidebar === true)
</script>

<template>
  <div
    class="app-shell"
    :class="{
      'app-shell--no-sidebar': hideSidebar,
      'app-shell--collapsed': !hideSidebar && isCollapsed,
    }"
  >
    <TopBar />
    <AppSidebar v-if="!hideSidebar" />
    <main id="main-content" class="app-main" tabindex="-1">
      <slot />
      <Footer />
    </main>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.app-shell {
  display: grid;
  grid-template-rows: 64px 1fr;
  grid-template-columns: 224px 1fr;
  grid-template-areas:
    "topbar  topbar"
    "sidebar main";
  min-height: 100vh;
}

.app-shell--collapsed {
  grid-template-columns: 60px 1fr;
}

.app-shell--no-sidebar {
  grid-template-columns: 1fr;
  grid-template-areas:
    "topbar"
    "main";
}

.app-main {
  grid-area: main;
  overflow-y: auto;
  overflow-x: hidden;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

/* Responsive */
@media (max-width: 1023px) and (min-width: 768px) {
  .app-shell {
    grid-template-columns: 60px 1fr;
  }
}

@media (max-width: 767px) {
  .app-shell {
    grid-template-columns: 1fr;
    grid-template-areas:
      "topbar"
      "main";
  }
}
</style>
