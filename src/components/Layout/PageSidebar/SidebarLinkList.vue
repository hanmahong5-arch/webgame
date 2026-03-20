<script setup lang="ts">
import type { SidebarLinkItem } from '../../../types/sidebar'

defineProps<{
  label: string
  items: SidebarLinkItem[]
  collapsed: boolean
}>()
</script>

<template>
  <div class="sidebar-links">
    <p class="section-label" :class="{ 'sr-only': collapsed }">{{ label }}</p>
    <ul class="link-list">
      <li v-for="item in items" :key="item.href">
        <component
          :is="item.external ? 'a' : 'router-link'"
          :href="item.external ? item.href : undefined"
          :to="item.external ? undefined : item.href"
          :target="item.external ? '_blank' : undefined"
          :rel="item.external ? 'noopener noreferrer' : undefined"
          class="link-item"
          :class="{ 'link-item--collapsed': collapsed }"
          :title="collapsed ? item.label : undefined"
        >
          <span v-if="!collapsed" class="link-label">{{ item.label }}</span>
          <svg
            v-if="item.external && !collapsed"
            class="link-external-icon"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
          </svg>
          <!-- Collapsed: show a small link icon -->
          <svg
            v-if="collapsed"
            class="link-collapsed-icon"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101" />
          </svg>
        </component>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.section-label {
  font-size: 0.68rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--color-text-muted);
  padding: 0 12px;
  margin-bottom: 6px;
}

.link-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.link-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 5px 12px;
  text-decoration: none;
  color: var(--color-text-muted);
  font-size: 0.78rem;
  transition: color 0.15s ease, background-color 0.15s ease;
  border-radius: 4px;
}

.link-item:hover {
  color: var(--color-text-secondary);
  background-color: var(--color-surface-overlay);
}

.link-item--collapsed {
  justify-content: center;
  padding: 6px;
}

.link-external-icon {
  width: 12px;
  height: 12px;
  opacity: 0.4;
  flex-shrink: 0;
}

.link-collapsed-icon {
  width: 16px;
  height: 16px;
  opacity: 0.5;
}

.link-label {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
