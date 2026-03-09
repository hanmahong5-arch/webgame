<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { navIconPaths } from '../../data/navItems'
import type { SidebarNavItem } from '../../data/sidebarItems'

const props = defineProps<{
  item: SidebarNavItem
  collapsed?: boolean
}>()

const route = useRoute()

const isActive = computed(() => {
  if (props.item.external) return false
  // Match exact path or path with hash
  const itemPath = props.item.path.split('#')[0]
  return route.path === itemPath
})

const iconPath = computed(() => navIconPaths[props.item.icon] || '')
</script>

<template>
  <a
    v-if="item.external"
    :href="item.path"
    target="_blank"
    rel="noopener noreferrer"
    class="sidebar-item group"
    :class="{ 'sidebar-item--collapsed': collapsed }"
    :title="collapsed ? item.name : undefined"
  >
    <svg
      v-if="iconPath"
      class="sidebar-item-icon"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      aria-hidden="true"
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="iconPath" />
    </svg>
    <span v-if="!collapsed" class="sidebar-item-label">
      {{ item.name }}
    </span>
    <!-- External link indicator -->
    <svg
      v-if="!collapsed"
      class="w-3 h-3 ml-auto opacity-0 group-hover:opacity-40 transition-opacity shrink-0"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      aria-hidden="true"
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
    </svg>
    <!-- Badge -->
    <span
      v-if="item.badge && !collapsed"
      class="ml-auto text-[10px] px-1.5 py-0.5 rounded bg-ochre/15 text-ochre font-medium"
    >
      {{ item.badge }}
    </span>
  </a>

  <router-link
    v-else
    :to="item.path"
    class="sidebar-item group"
    :class="{
      'sidebar-item--collapsed': collapsed,
      'sidebar-item--active': isActive,
    }"
    :title="collapsed ? item.name : undefined"
  >
    <svg
      v-if="iconPath"
      class="sidebar-item-icon"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      aria-hidden="true"
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="iconPath" />
    </svg>
    <span v-if="!collapsed" class="sidebar-item-label">
      {{ item.name }}
    </span>
    <span
      v-if="item.badge && !collapsed"
      class="ml-auto text-[10px] px-1.5 py-0.5 rounded bg-ochre/15 text-ochre font-medium"
    >
      {{ item.badge }}
    </span>
  </router-link>
</template>

<style scoped>
@reference "../../styles/main.css";

.sidebar-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 7px 12px;
  border-radius: 6px;
  color: var(--color-ink-500);
  font-size: 13px;
  line-height: 1.4;
  transition: all 0.15s ease;
  text-decoration: none;
  min-height: 34px;
}

.sidebar-item:hover {
  color: var(--color-ink-900);
  background-color: var(--color-cream-200);
}

.sidebar-item--active {
  color: var(--color-ink-900);
  background-color: var(--color-cream-200);
  font-weight: 500;
}

.sidebar-item--active .sidebar-item-icon {
  color: var(--color-ochre);
}

.sidebar-item--collapsed {
  justify-content: center;
  padding: 8px;
}

.sidebar-item-icon {
  width: 18px;
  height: 18px;
  shrink: 0;
  flex-shrink: 0;
}

.sidebar-item-label {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
