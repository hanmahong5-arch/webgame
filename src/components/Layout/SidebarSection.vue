<script setup lang="ts">
import { ref } from 'vue'
import SidebarItem from './SidebarItem.vue'
import type { SidebarSection } from '../../data/sidebarItems'

defineProps<{
  section: SidebarSection
  collapsed?: boolean
}>()

const isExpanded = ref(true)
</script>

<template>
  <div class="sidebar-section">
    <!-- Section header -->
    <button
      v-if="!collapsed"
      class="sidebar-section-header"
      @click="isExpanded = !isExpanded"
      :aria-expanded="isExpanded"
    >
      <span class="sidebar-section-label">{{ section.label }}</span>
      <svg
        class="w-3 h-3 text-text-secondary transition-transform duration-200"
        :class="{ 'rotate-180': !isExpanded }"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        aria-hidden="true"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>

    <!-- Collapsed mode: just a thin divider -->
    <div v-else class="mx-2 my-2 border-t border-surface-border" aria-hidden="true"></div>

    <!-- Section items -->
    <div v-if="!collapsed && isExpanded" class="sidebar-section-items">
      <SidebarItem
        v-for="item in section.items"
        :key="item.path + item.name"
        :item="item"
        :collapsed="false"
      />
    </div>

    <!-- Collapsed mode: show only icons -->
    <div v-if="collapsed" class="sidebar-section-items">
      <SidebarItem
        v-for="item in section.items"
        :key="item.path + item.name"
        :item="item"
        :collapsed="true"
      />
    </div>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.sidebar-section {
  margin-bottom: 4px;
}

.sidebar-section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding: 6px 12px;
  cursor: pointer;
  background: none;
  border: none;
}

.sidebar-section-header:hover .sidebar-section-label {
  color: var(--color-text-primary);
}

.sidebar-section-label {
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-secondary);
  transition: color 0.15s ease;
}

.sidebar-section-items {
  display: flex;
  flex-direction: column;
  gap: 1px;
  padding: 0 6px;
}
</style>
