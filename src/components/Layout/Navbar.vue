<script setup lang="ts">
import { ref, nextTick, onMounted, onUnmounted } from 'vue'
import { navItems, navIconPaths } from '../../data/navItems'
import NavDropdown from './NavDropdown.vue'
import AccountBadge from '../Portal/AccountBadge.vue'
import { useActiveSection } from '../../composables/useActiveSection'
import { useAuth } from '../../composables/useAuth'

const mobileMenuOpen = ref(false)
const scrolled = ref(false)
const hamburgerButtonRef = ref<HTMLButtonElement | null>(null)
const menuPanelRef = ref<HTMLElement | null>(null)

const { activeSection } = useActiveSection()
const { isLoggedIn, userInfo, checkSession, login, logout } = useAuth()

/** Display name: prefer name, fallback to preferred_username, then email */
const displayName = (u: NonNullable<typeof userInfo.value>) =>
  u.name || u.preferred_username || u.email || 'User'
const displayInitial = (u: NonNullable<typeof userInfo.value>) =>
  (u.name || u.preferred_username || u.email || 'U').charAt(0).toUpperCase()

// Map nav items to their corresponding section IDs
const sectionMap: Record<string, string> = {
  '探索者': 'audience-hero',
  '创业者': 'audience-hero',
  '构建者': 'audience-hero',
}

const isNavItemActive = (name: string): boolean => {
  const sectionId = sectionMap[name]
  return sectionId ? activeSection.value === sectionId : false
}

// Get all focusable elements within a container
const getFocusableElements = (container: HTMLElement): HTMLElement[] => {
  const selector = 'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])'
  return Array.from(container.querySelectorAll<HTMLElement>(selector))
}

// Focus trap: keep Tab/Shift+Tab cycling within the mobile menu
const handleMenuKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    closeMobileMenu()
    return
  }

  if (event.key !== 'Tab' || !menuPanelRef.value) return

  const focusableElements = getFocusableElements(menuPanelRef.value)
  if (focusableElements.length === 0) return

  const firstFocusable = focusableElements[0]
  const lastFocusable = focusableElements[focusableElements.length - 1]

  if (event.shiftKey) {
    if (document.activeElement === firstFocusable) {
      event.preventDefault()
      lastFocusable.focus()
    }
  } else {
    if (document.activeElement === lastFocusable) {
      event.preventDefault()
      firstFocusable.focus()
    }
  }
}

const toggleMobileMenu = () => {
  if (mobileMenuOpen.value) {
    closeMobileMenu()
  } else {
    openMobileMenu()
  }
}

const openMobileMenu = async () => {
  mobileMenuOpen.value = true
  document.body.style.overflow = 'hidden'
  document.addEventListener('keydown', handleMenuKeydown)

  // Focus first focusable element in menu after render
  await nextTick()
  if (menuPanelRef.value) {
    const focusableElements = getFocusableElements(menuPanelRef.value)
    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    }
  }
}

const closeMobileMenu = () => {
  mobileMenuOpen.value = false
  document.body.style.overflow = ''
  document.removeEventListener('keydown', handleMenuKeydown)
  // Return focus to hamburger button
  hamburgerButtonRef.value?.focus()
}

const handleScroll = () => {
  scrolled.value = window.scrollY > 20
}

onMounted(async () => {
  window.addEventListener('scroll', handleScroll)
  // Check session status on mount
  await checkSession()
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
  document.removeEventListener('keydown', handleMenuKeydown)
  document.body.style.overflow = ''
})

/**
 * Handle logout button click
 * logout() redirects to Zitadel end_session then back to home
 */
function handleLogout() {
  logout()
}
</script>

<template>
  <header
    class="fixed top-0 left-0 right-0 z-50 transition-all duration-300"
    :class="[
      scrolled
        ? 'bg-cream-50/90 backdrop-blur-sm shadow-sm'
        : 'bg-transparent'
    ]"
  >
    <nav aria-label="Main navigation">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-20">
          <!-- Logo -->
          <router-link to="/" class="flex items-center gap-3 group">
            <div class="relative">
              <div class="w-10 h-10 rounded-lg bg-ochre flex items-center justify-center border-2 border-ink-300 group-hover:animate-wiggle transition-transform duration-300">
                <span class="text-cream-50 font-hand font-bold text-xl">L</span>
              </div>
            </div>
            <span class="text-ink-900 font-hand font-bold text-2xl tracking-tight">Lurus</span>
          </router-link>

          <!-- Desktop Nav -->
          <div class="hidden md:flex items-center gap-1">
            <template v-for="link in navItems" :key="link.name">
              <!-- Dropdown menu for items with children -->
              <NavDropdown
                v-if="link.children && link.children.length > 0"
                :label="link.name"
                :items="link.children"
                :active="isNavItemActive(link.name)"
                :footer-link="link.footerLink"
                :solution-tags="link.solutionTags"
              />
              <!-- External link -->
              <a
                v-else-if="link.external"
                :href="link.path"
                target="_blank"
                rel="noopener noreferrer"
                class="px-5 py-2.5 text-ink-500 hover:text-ink-900 hover:bg-cream-200 rounded-lg transition-all duration-200"
              >
                {{ link.name }}
              </a>
              <!-- Router link -->
              <router-link
                v-else-if="link.path.startsWith('/')"
                :to="link.path"
                class="px-5 py-2.5 text-ink-500 hover:text-ink-900 hover:bg-cream-200 rounded-lg transition-all duration-200"
              >
                {{ link.name }}
              </router-link>
              <!-- Anchor link -->
              <a
                v-else
                :href="link.path"
                class="px-5 py-2.5 text-ink-500 hover:text-ink-900 hover:bg-cream-200 rounded-lg transition-all duration-200"
              >
                {{ link.name }}
              </a>
            </template>
          </div>

          <!-- CTA Buttons -->
          <div class="hidden md:flex items-center gap-3">
            <a
              href="https://docs.lurus.cn"
              target="_blank"
              rel="noopener noreferrer"
              class="px-4 py-2 text-ink-500 hover:text-ink-900 transition-colors text-sm"
            >
              文档
            </a>
            <template v-if="isLoggedIn && userInfo">
              <!-- Logged in: Show user menu -->
              <div class="flex items-center gap-3">
                <!-- Lubell balance + VIP badge -->
                <AccountBadge />
                <div class="flex items-center gap-2 px-3 py-2 rounded-lg bg-cream-200">
                  <img
                    v-if="userInfo.picture"
                    :src="userInfo.picture"
                    :alt="`${displayName(userInfo)} avatar`"
                    class="w-7 h-7 rounded-full border-2 border-ink-300"
                  >
                  <div
                    v-else
                    class="w-7 h-7 rounded-full bg-ochre flex items-center justify-center border-2 border-ink-300"
                  >
                    <span class="text-cream-50 text-sm font-bold">{{ displayInitial(userInfo) }}</span>
                  </div>
                  <span class="text-ink-900 font-medium">{{ displayName(userInfo) }}</span>
                </div>
                <button
                  @click="handleLogout"
                  class="px-5 py-2.5 text-ink-500 hover:text-ink-900 hover:bg-cream-200 rounded-lg transition-all duration-200"
                >
                  退出
                </button>
              </div>
            </template>
            <template v-else>
              <!-- Not logged in: Show login/register buttons -->
              <button
                @click="login()"
                class="px-5 py-2.5 text-ink-500 hover:text-ink-900 transition-colors"
              >
                登录
              </button>
              <button
                @click="login({ prompt: 'create' })"
                class="btn-hand btn-hand-primary"
              >
                开始使用
              </button>
            </template>
          </div>

          <!-- Mobile Menu Button -->
          <button
            ref="hamburgerButtonRef"
            @click="toggleMobileMenu"
            class="md:hidden min-w-[44px] min-h-[44px] p-2.5 text-ink-500 hover:text-ink-900 hover:bg-cream-200 rounded-lg transition-all flex items-center justify-center"
            :aria-expanded="mobileMenuOpen"
            aria-label="Toggle menu"
          >
            <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <g class="transition-transform duration-300 origin-center" :class="mobileMenuOpen ? 'rotate-45' : 'rotate-0'">
                <path v-if="!mobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </g>
            </svg>
          </button>
        </div>
      </div>

      <!-- Mobile Menu Overlay -->
      <Transition
        enter-active-class="transition-all duration-300 ease-out"
        enter-from-class="opacity-0 -translate-y-4"
        enter-to-class="opacity-100 translate-y-0"
        leave-active-class="transition-all duration-300 ease-in"
        leave-from-class="opacity-100 translate-y-0"
        leave-to-class="opacity-0 -translate-y-4"
      >
        <div
          v-if="mobileMenuOpen"
          class="md:hidden fixed inset-0 top-20 z-[55]"
          role="dialog"
          aria-modal="true"
          aria-label="Navigation menu"
          @click="closeMobileMenu"
        >
          <!-- Background overlay -->
          <div class="absolute inset-0 bg-ink-900/50" aria-hidden="true"></div>

          <!-- Menu panel -->
          <div
            ref="menuPanelRef"
            class="relative bg-cream-50 h-full overflow-y-auto"
            @click.stop
          >
            <div class="px-4 py-6 space-y-1">
              <template v-for="link in navItems" :key="link.name">
                <!-- Section with children (expanded inline on mobile) -->
                <template v-if="link.children && link.children.length > 0">
                  <div class="pt-4 pb-2 px-4 text-xs font-semibold text-ink-300 uppercase tracking-wider">
                    {{ link.name }}
                  </div>
                  <template v-for="child in link.children" :key="child.path + child.name">
                    <a
                      v-if="child.external"
                      :href="child.path"
                      target="_blank"
                      rel="noopener noreferrer"
                      class="mobile-nav-link pl-6"
                      @click="closeMobileMenu"
                    >
                      <span class="flex items-center gap-3">
                        <svg
                          v-if="child.icon && navIconPaths[child.icon]"
                          class="w-5 h-5 text-ochre shrink-0"
                          fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"
                        >
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[child.icon]" />
                        </svg>
                        <span>
                          <span class="block text-ink-700 font-medium">{{ child.name }}</span>
                          <span v-if="child.desc" class="block text-xs text-ink-400">{{ child.desc }}</span>
                        </span>
                      </span>
                    </a>
                    <router-link
                      v-else-if="child.path.startsWith('/')"
                      :to="child.path"
                      class="mobile-nav-link pl-6"
                      @click="closeMobileMenu"
                    >
                      <span class="flex items-center gap-3">
                        <svg
                          v-if="child.icon && navIconPaths[child.icon]"
                          class="w-5 h-5 text-ochre shrink-0"
                          fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"
                        >
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[child.icon]" />
                        </svg>
                        <span>
                          <span class="block text-ink-700 font-medium">{{ child.name }}</span>
                          <span v-if="child.desc" class="block text-xs text-ink-400">{{ child.desc }}</span>
                        </span>
                      </span>
                    </router-link>
                    <a
                      v-else
                      :href="child.path"
                      class="mobile-nav-link pl-6"
                      @click="closeMobileMenu"
                    >
                      <span class="flex items-center gap-3">
                        <svg
                          v-if="child.icon && navIconPaths[child.icon]"
                          class="w-5 h-5 text-ochre shrink-0"
                          fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true"
                        >
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[child.icon]" />
                        </svg>
                        <span>
                          <span class="block text-ink-700 font-medium">{{ child.name }}</span>
                          <span v-if="child.desc" class="block text-xs text-ink-400">{{ child.desc }}</span>
                        </span>
                      </span>
                    </a>
                  </template>
                </template>
                <!-- Simple link -->
                <template v-else>
                  <a
                    v-if="link.external"
                    :href="link.path"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="mobile-nav-link"
                    @click="closeMobileMenu"
                  >
                    <span class="flex items-center gap-2">
                      {{ link.name }}
                      <svg class="w-3.5 h-3.5 opacity-50" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                      </svg>
                    </span>
                  </a>
                  <router-link
                    v-else-if="link.path.startsWith('/')"
                    :to="link.path"
                    class="mobile-nav-link"
                    @click="closeMobileMenu"
                  >
                    {{ link.name }}
                  </router-link>
                  <a
                    v-else
                    :href="link.path"
                    class="mobile-nav-link"
                    @click="closeMobileMenu"
                  >
                    {{ link.name }}
                  </a>
                </template>
              </template>
              <hr class="border-ink-100 my-4">
              <template v-if="isLoggedIn && userInfo">
                <!-- Logged in: Show user info and logout -->
                <div class="mobile-nav-link flex items-center gap-3 cursor-default">
                  <img
                    v-if="userInfo.picture"
                    :src="userInfo.picture"
                    :alt="`${displayName(userInfo)} avatar`"
                    class="w-10 h-10 rounded-full border-2 border-ink-300"
                  >
                  <div
                    v-else
                    class="w-10 h-10 rounded-full bg-ochre flex items-center justify-center border-2 border-ink-300"
                  >
                    <span class="text-cream-50 font-bold">{{ displayInitial(userInfo) }}</span>
                  </div>
                  <div>
                    <p class="text-ink-900 font-medium">{{ displayName(userInfo) }}</p>
                    <p class="text-ink-300 text-sm">{{ userInfo.email }}</p>
                  </div>
                </div>
                <button
                  @click="handleLogout"
                  class="mobile-nav-link text-red-600 hover:bg-red-50"
                >
                  退出登录
                </button>
              </template>
              <template v-else>
                <!-- Not logged in: Show login/register -->
                <button
                  @click="login()"
                  class="mobile-nav-link"
                >
                  登录
                </button>
                <button
                  @click="login({ prompt: 'create' })"
                  class="block btn-hand btn-hand-primary text-center min-h-[44px] flex items-center justify-center"
                >
                  开始使用
                </button>
              </template>
            </div>
          </div>
        </div>
      </Transition>
    </nav>
  </header>
</template>

<style scoped>
@reference "../../styles/main.css";

/* Mobile nav link with minimum touch target 44x44px */
.mobile-nav-link {
  display: block;
  padding: 0.875rem 1rem; /* 14px vertical = ~48px total height with line-height */
  min-height: 44px;
  color: var(--color-ink-500);
  border-radius: 0.5rem;
  transition: all 0.2s ease;
}

.mobile-nav-link:hover,
.mobile-nav-link:active {
  color: var(--color-ink-900);
  background-color: var(--color-cream-200);
}

/* Respect reduced motion preference (ADR-002) */
@media (prefers-reduced-motion: reduce) {
  .mobile-nav-link {
    transition: none;
  }
}
</style>
