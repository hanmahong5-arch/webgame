<script setup lang="ts">
import { onMounted } from 'vue'
import { topBarLinks } from '../../data/topBarItems'
import AccountBadge from '../Portal/AccountBadge.vue'
import { useAuth } from '../../composables/useAuth'
import { useSidebar } from '../../composables/useSidebar'

const { isLoggedIn, userInfo, checkSession, login, logout } = useAuth()
const { toggle } = useSidebar()

const emit = defineEmits<{
  (e: 'toggle-sidebar'): void
}>()

const displayName = (u: NonNullable<typeof userInfo.value>) =>
  u.name || u.preferred_username || u.email || 'User'
const displayInitial = (u: NonNullable<typeof userInfo.value>) =>
  (u.name || u.preferred_username || u.email || 'U').charAt(0).toUpperCase()

const handleToggle = () => {
  toggle()
  emit('toggle-sidebar')
}

onMounted(async () => {
  await checkSession()
})
</script>

<template>
  <header class="app-topbar" aria-label="Top navigation">
    <div class="app-topbar-inner">
      <!-- Left: hamburger (mobile) + Logo -->
      <div class="flex items-center gap-2">
        <!-- Mobile hamburger -->
        <button
          class="md:hidden flex items-center justify-center w-8 h-8 rounded text-ink-500 hover:text-ink-900 hover:bg-cream-200 transition-colors"
          aria-label="Toggle sidebar"
          @click="handleToggle"
        >
          <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>

        <!-- Logo -->
        <router-link to="/" class="flex items-center gap-2 group">
          <div class="w-7 h-7 rounded-md bg-ochre flex items-center justify-center border border-ink-300 group-hover:animate-wiggle transition-transform duration-300">
            <span class="text-cream-50 font-hand font-bold text-sm">L</span>
          </div>
          <span class="text-ink-900 font-hand font-bold text-lg tracking-tight">Lurus</span>
        </router-link>
      </div>

      <!-- Center: functional links (desktop) -->
      <nav class="hidden md:flex items-center gap-1">
        <template v-for="link in topBarLinks" :key="link.name">
          <a
            v-if="link.external"
            :href="link.path"
            target="_blank"
            rel="noopener noreferrer"
            class="topbar-link"
          >
            {{ link.name }}
          </a>
          <router-link
            v-else
            :to="link.path"
            class="topbar-link"
          >
            {{ link.name }}
          </router-link>
        </template>
      </nav>

      <!-- Right: auth actions -->
      <div class="flex items-center gap-2">
        <template v-if="isLoggedIn && userInfo">
          <AccountBadge />
          <div class="hidden sm:flex items-center gap-1.5 px-2 py-1 rounded bg-cream-200">
            <img
              v-if="userInfo.picture"
              :src="userInfo.picture"
              :alt="`${displayName(userInfo)} avatar`"
              class="w-6 h-6 rounded-full border border-ink-300"
            >
            <div
              v-else
              class="w-6 h-6 rounded-full bg-ochre flex items-center justify-center border border-ink-300"
            >
              <span class="text-cream-50 text-xs font-bold">{{ displayInitial(userInfo) }}</span>
            </div>
            <span class="text-ink-900 text-sm font-medium max-w-[100px] truncate">{{ displayName(userInfo) }}</span>
          </div>
          <button
            @click="logout()"
            class="topbar-link text-ink-400 hover:text-red-600"
          >
            退出
          </button>
        </template>
        <template v-else>
          <button @click="login()" class="topbar-link">
            登录
          </button>
          <button
            @click="login({ prompt: 'create' })"
            class="topbar-cta"
          >
            开始使用
          </button>
        </template>
      </div>
    </div>
  </header>
</template>

<style scoped>
@reference "../../styles/main.css";

.app-topbar {
  grid-area: topbar;
  height: 44px;
  background-color: var(--color-cream-50);
  border-bottom: 1px solid var(--color-ink-100);
  z-index: 20;
}

.app-topbar-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
  padding: 0 16px;
}

.topbar-link {
  padding: 4px 10px;
  font-size: 13px;
  color: var(--color-ink-500);
  border-radius: 4px;
  transition: all 0.15s ease;
  white-space: nowrap;
}

.topbar-link:hover {
  color: var(--color-ink-900);
  background-color: var(--color-cream-200);
}

.topbar-cta {
  padding: 4px 14px;
  font-size: 13px;
  font-weight: 600;
  background-color: var(--color-ochre);
  color: var(--color-cream-50);
  border-radius: 4px;
  transition: all 0.15s ease;
  white-space: nowrap;
}

.topbar-cta:hover {
  background-color: color-mix(in srgb, var(--color-ochre), #000 12%);
}
</style>
