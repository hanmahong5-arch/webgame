<script setup lang="ts">
import type { SidebarCtaItem } from '../../../types/sidebar'
import { useAuth } from '../../../composables/useAuth'

defineProps<{
  items: SidebarCtaItem[]
  collapsed: boolean
}>()

const { login } = useAuth()

function handleClick(item: SidebarCtaItem) {
  if (item.action === 'login') {
    login({ prompt: 'create' })
  }
}
</script>

<template>
  <div v-if="!collapsed" class="sidebar-cta">
    <template v-for="item in items" :key="item.label">
      <!-- Action button (login) -->
      <button
        v-if="item.action"
        class="cta-btn"
        :class="item.variant === 'primary' ? 'btn-primary btn-primary--sm' : 'btn-outline btn-outline--sm'"
        @click="handleClick(item)"
      >
        {{ item.label }}
      </button>
      <!-- External link -->
      <a
        v-else-if="item.external"
        :href="item.href"
        target="_blank"
        rel="noopener noreferrer"
        class="cta-btn"
        :class="item.variant === 'primary' ? 'btn-primary btn-primary--sm' : 'btn-outline btn-outline--sm'"
      >
        {{ item.label }}
      </a>
      <!-- Internal link -->
      <router-link
        v-else
        :to="item.href"
        class="cta-btn"
        :class="item.variant === 'primary' ? 'btn-primary btn-primary--sm' : 'btn-outline btn-outline--sm'"
      >
        {{ item.label }}
      </router-link>
    </template>
  </div>
</template>

<style scoped>
@reference "../../../styles/main.css";

.sidebar-cta {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 0 8px;
}

.cta-btn {
  width: 100%;
  text-align: center;
  font-size: 0.78rem;
}
</style>
