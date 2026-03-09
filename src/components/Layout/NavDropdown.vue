<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import type { NavItem, NavFooterLink } from '../../types/navigation'
import { navIconPaths } from '../../data/navItems'

defineProps<{
  label: string
  items: NavItem[]
  active?: boolean
  footerLink?: NavFooterLink
  solutionTags?: string[]
}>()

const isOpen = ref(false)
const dropdownRef = ref<HTMLElement | null>(null)
const buttonRef = ref<HTMLButtonElement | null>(null)
let hoverTimeout: ReturnType<typeof setTimeout> | null = null

const open = () => {
  if (hoverTimeout) { clearTimeout(hoverTimeout); hoverTimeout = null }
  isOpen.value = true
}

const close = () => {
  if (hoverTimeout) { clearTimeout(hoverTimeout); hoverTimeout = null }
  isOpen.value = false
}

const toggle = () => {
  if (isOpen.value) close()
  else open()
}

const handleMouseEnter = () => {
  if (hoverTimeout) { clearTimeout(hoverTimeout); hoverTimeout = null }
  isOpen.value = true
}

const handleMouseLeave = () => {
  hoverTimeout = setTimeout(() => { isOpen.value = false }, 150)
}

const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && isOpen.value) {
    close()
    buttonRef.value?.focus()
  }
}

const handleClickOutside = (e: MouseEvent) => {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target as Node)) {
    close()
  }
}

const handleNavigate = () => {
  close()
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
  document.removeEventListener('click', handleClickOutside)
  if (hoverTimeout) clearTimeout(hoverTimeout)
})
</script>

<template>
  <div ref="dropdownRef" class="relative" @mouseenter="handleMouseEnter" @mouseleave="handleMouseLeave">
    <button
      ref="buttonRef"
      @click="toggle"
      class="flex items-center gap-1 px-5 py-2.5 rounded-lg transition-all duration-200"
      :class="[
        'border-b-2',
        active
          ? 'text-ink-900 border-ochre'
          : 'text-ink-500 border-transparent hover:text-ink-900 hover:bg-cream-200'
      ]"
      :aria-expanded="isOpen"
      aria-haspopup="true"
    >
      {{ label }}
      <svg
        class="w-4 h-4 transition-transform duration-200"
        :class="{ 'rotate-180': isOpen }"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        aria-hidden="true"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>

    <Transition
      enter-active-class="transition-all duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div
        v-if="isOpen"
        class="absolute top-full left-1/2 -translate-x-1/2 mt-2 w-[420px] bg-cream-50 border-2 border-ink-200 rounded-lg shadow-lg z-[60] overflow-hidden"
      >
        <!-- Product items grid -->
        <div class="grid grid-cols-2 gap-1 p-3">
          <template v-for="item in items" :key="item.path + item.name">
            <a
              v-if="item.external"
              :href="item.path"
              target="_blank"
              rel="noopener noreferrer"
              class="mega-dropdown-item"
              @click="handleNavigate"
            >
              <div class="flex items-start gap-3">
                <svg
                  v-if="item.icon && navIconPaths[item.icon]"
                  class="w-5 h-5 mt-0.5 text-ochre shrink-0"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
                </svg>
                <div class="min-w-0">
                  <div class="flex items-center gap-1.5">
                    <span class="text-sm font-medium text-ink-800">{{ item.name }}</span>
                    <svg class="w-3 h-3 text-ink-300 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                  </div>
                  <p v-if="item.desc" class="text-xs text-ink-400 mt-0.5 leading-snug">{{ item.desc }}</p>
                </div>
              </div>
            </a>
            <router-link
              v-else-if="item.path.startsWith('/')"
              :to="item.path"
              class="mega-dropdown-item"
              @click="handleNavigate"
            >
              <div class="flex items-start gap-3">
                <svg
                  v-if="item.icon && navIconPaths[item.icon]"
                  class="w-5 h-5 mt-0.5 text-ochre shrink-0"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
                </svg>
                <div class="min-w-0">
                  <span class="text-sm font-medium text-ink-800">{{ item.name }}</span>
                  <p v-if="item.desc" class="text-xs text-ink-400 mt-0.5 leading-snug">{{ item.desc }}</p>
                </div>
              </div>
            </router-link>
            <a
              v-else
              :href="item.path"
              class="mega-dropdown-item"
              @click="handleNavigate"
            >
              <div class="flex items-start gap-3">
                <svg
                  v-if="item.icon && navIconPaths[item.icon]"
                  class="w-5 h-5 mt-0.5 text-ochre shrink-0"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  aria-hidden="true"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
                </svg>
                <div class="min-w-0">
                  <span class="text-sm font-medium text-ink-800">{{ item.name }}</span>
                  <p v-if="item.desc" class="text-xs text-ink-400 mt-0.5 leading-snug">{{ item.desc }}</p>
                </div>
              </div>
            </a>
          </template>
        </div>

        <!-- Solution tags (for business audience) -->
        <div v-if="solutionTags && solutionTags.length > 0" class="px-4 pb-2">
          <p class="text-xs text-ink-300 mb-1.5">行业方案</p>
          <div class="flex flex-wrap gap-1.5">
            <router-link
              v-for="tag in solutionTags"
              :key="tag"
              to="/solutions"
              class="text-xs px-2.5 py-1 bg-cream-200 text-ink-500 rounded hover:bg-cream-300 hover:text-ink-700 transition-colors"
              @click="handleNavigate"
            >
              {{ tag }}
            </router-link>
          </div>
        </div>

        <!-- Footer link -->
        <div v-if="footerLink" class="border-t border-ink-100 px-4 py-2.5">
          <router-link
            v-if="footerLink.path.startsWith('/')"
            :to="footerLink.path"
            class="text-sm text-ochre hover:text-ochre/80 font-medium transition-colors"
            @click="handleNavigate"
          >
            {{ footerLink.name }}
          </router-link>
          <a
            v-else
            :href="footerLink.path"
            :target="footerLink.external ? '_blank' : undefined"
            :rel="footerLink.external ? 'noopener noreferrer' : undefined"
            class="text-sm text-ochre hover:text-ochre/80 font-medium transition-colors"
            @click="handleNavigate"
          >
            {{ footerLink.name }}
          </a>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.mega-dropdown-item {
  display: block;
  padding: 0.625rem 0.75rem;
  border-radius: 0.5rem;
  transition: all 0.15s ease;
}

.mega-dropdown-item:hover {
  background-color: var(--color-cream-200);
}
</style>
