<script setup lang="ts">
import type { SidebarTocItem } from '../../../types/sidebar'

defineProps<{
  label: string
  items: SidebarTocItem[]
  activeAnchor: string
  collapsed: boolean
}>()

function scrollTo(anchor: string) {
  const el = document.getElementById(anchor)
  if (el) {
    el.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }
}
</script>

<template>
  <div class="sidebar-toc">
    <p class="section-label" :class="{ 'sr-only': collapsed }">{{ label }}</p>
    <ul class="toc-list">
      <li v-for="item in items" :key="item.anchor">
        <button
          class="toc-item"
          :class="{
            'toc-item--active': activeAnchor === item.anchor,
            'toc-item--collapsed': collapsed,
          }"
          :title="collapsed ? item.label : undefined"
          @click="scrollTo(item.anchor)"
        >
          <span class="toc-dot" :class="{ 'toc-dot--active': activeAnchor === item.anchor }"></span>
          <span v-if="!collapsed" class="toc-label">{{ item.label }}</span>
        </button>
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

.toc-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.toc-item {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  padding: 5px 12px;
  border: none;
  background: none;
  cursor: pointer;
  text-align: left;
  color: var(--color-text-muted);
  font-size: 0.8rem;
  transition: color 0.15s ease, background-color 0.15s ease;
  border-radius: 4px;
}

.toc-item:hover {
  color: var(--color-text-secondary);
  background-color: var(--color-surface-overlay);
}

.toc-item--active {
  color: var(--color-ochre);
}

.toc-item--collapsed {
  justify-content: center;
  padding: 6px;
}

.toc-dot {
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background-color: var(--color-surface-border);
  flex-shrink: 0;
  transition: background-color 0.15s ease, transform 0.15s ease;
}

.toc-dot--active {
  background-color: var(--color-ochre);
  transform: scale(1.3);
}

.toc-label {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
