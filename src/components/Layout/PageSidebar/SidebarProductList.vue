<script setup lang="ts">
import type { SidebarProductItem } from '../../../types/sidebar'

defineProps<{
  label: string
  items: SidebarProductItem[]
  collapsed: boolean
  initialCollapsed?: boolean
}>()
</script>

<template>
  <div class="sidebar-products">
    <p class="section-label" :class="{ 'sr-only': collapsed }">{{ label }}</p>
    <ul class="product-list">
      <li v-for="item in items" :key="item.productId">
        <component
          :is="item.external ? 'a' : 'router-link'"
          :href="item.external ? item.href : undefined"
          :to="item.external ? undefined : item.href"
          :target="item.external ? '_blank' : undefined"
          :rel="item.external ? 'noopener noreferrer' : undefined"
          class="product-item"
          :class="{ 'product-item--collapsed': collapsed }"
          :title="collapsed ? item.label : undefined"
        >
          <span class="product-dot" :style="{ backgroundColor: item.color }"></span>
          <span v-if="!collapsed" class="product-label">{{ item.label }}</span>
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

.product-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.product-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 5px 12px;
  text-decoration: none;
  color: var(--color-text-secondary);
  font-size: 0.8rem;
  transition: color 0.15s ease, background-color 0.15s ease;
  border-radius: 4px;
}

.product-item:hover {
  color: var(--color-text-primary);
  background-color: var(--color-surface-overlay);
}

.product-item--collapsed {
  justify-content: center;
  padding: 6px;
}

.product-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  flex-shrink: 0;
}

.product-label {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
