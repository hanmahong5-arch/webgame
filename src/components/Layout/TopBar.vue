<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { navIconPaths } from '../../data/navItems'
import AccountBadge from '../Portal/AccountBadge.vue'
import { useAuth } from '../../composables/useAuth'

const { isLoggedIn, userInfo, checkSession, login, logout } = useAuth()

const scrolled = ref(false)
const openMenu = ref<string | null>(null)
const mobileOpen = ref(false)
let closeTimer: ReturnType<typeof setTimeout> | null = null

const displayName = (u: NonNullable<typeof userInfo.value>) =>
  u.name || u.preferred_username || u.email || 'User'
const displayInitial = (u: NonNullable<typeof userInfo.value>) =>
  (u.name || u.preferred_username || u.email || 'U').charAt(0).toUpperCase()

const openDropdown = (menu: string) => {
  if (closeTimer) { clearTimeout(closeTimer); closeTimer = null }
  openMenu.value = menu
}

const scheduleClose = () => {
  closeTimer = setTimeout(() => { openMenu.value = null }, 160)
}

const handleScroll = () => { scrolled.value = window.scrollY > 20 }

const closeMobile = () => {
  mobileOpen.value = false
  document.body.style.overflow = ''
}

const toggleMobile = () => {
  mobileOpen.value = !mobileOpen.value
  document.body.style.overflow = mobileOpen.value ? 'hidden' : ''
}

const handleEsc = (e: KeyboardEvent) => {
  if (e.key === 'Escape') { openMenu.value = null; closeMobile() }
}

onMounted(async () => {
  window.addEventListener('scroll', handleScroll, { passive: true })
  document.addEventListener('keydown', handleEsc)
  await checkSession()
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
  document.removeEventListener('keydown', handleEsc)
  document.body.style.overflow = ''
  if (closeTimer) clearTimeout(closeTimer)
})

const consumerProducts = [
  { name: 'Lucrum', desc: '自然语言驱动 AI 量化交易', icon: 'chart', href: 'https://gushen.lurus.cn', external: true },
  { name: 'Lurus Creator', desc: '视频→AI 转录→多平台发布', icon: 'video', href: '/download', external: false },
  { name: 'MemX', desc: '跨会话持久 AI 记忆引擎', icon: 'database', href: '/download#memx', external: false },
]

const infraProducts = [
  { name: 'Lurus API', desc: 'LLM 统一网关，50+ 模型一端点', icon: 'api', href: 'https://api.lurus.cn', external: true },
  { name: 'Lurus Switch', desc: '统一管理所有 AI CLI 工具', icon: 'desktop', href: '/download', external: false },
]

const devProducts = [
  { name: 'Kova SDK', desc: 'Rust Agent 持久化执行框架', icon: 'cpu', href: '#', external: false },
  { name: 'Lumen', desc: 'Agent 执行可视化调试 CLI', icon: 'bug', href: '#', external: false },
  { name: 'Lurus Identity', desc: '认证 + 订阅 + 计费平台', icon: 'shield', href: 'https://identity.lurus.cn', external: true },
  { name: 'MemX SDK', desc: '为产品添加 AI 记忆层', icon: 'database', href: '/download#memx', external: false },
]
</script>

<template>
  <header
    class="app-topbar"
    :class="{ 'app-topbar--scrolled': scrolled }"
    aria-label="Main navigation"
  >
    <div class="topbar-inner">

      <!-- Logo -->
      <router-link to="/" class="topbar-logo" @click="closeMobile">
        <div class="logo-mark">L</div>
        <span class="logo-name">Lurus</span>
      </router-link>

      <!-- Desktop navigation -->
      <nav class="topbar-nav" aria-label="Primary">

        <!-- Products dropdown -->
        <div
          class="nav-item"
          @mouseenter="openDropdown('products')"
          @mouseleave="scheduleClose"
        >
          <button
            class="nav-link"
            :class="{ 'nav-link--active': openMenu === 'products' }"
            :aria-expanded="openMenu === 'products'"
            aria-haspopup="true"
          >
            产品
            <svg class="nav-chevron" :class="{ 'rotate-180': openMenu === 'products' }" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </button>

          <Transition
            enter-active-class="transition-all duration-200 ease-out"
            enter-from-class="opacity-0 translate-y-[-6px]"
            enter-to-class="opacity-100 translate-y-0"
            leave-active-class="transition-all duration-150 ease-in"
            leave-from-class="opacity-100 translate-y-0"
            leave-to-class="opacity-0 translate-y-[-6px]"
          >
            <div
              v-if="openMenu === 'products'"
              class="mega-menu"
              @mouseenter="openDropdown('products')"
              @mouseleave="scheduleClose"
              role="dialog"
              aria-label="Products menu"
            >
              <div class="mega-menu-grid">
                <!-- Consumer column -->
                <div>
                  <p class="mega-group-label">个人工具</p>
                  <template v-for="item in consumerProducts" :key="item.name">
                    <a
                      v-if="item.external"
                      :href="item.href"
                      target="_blank"
                      rel="noopener noreferrer"
                      class="mega-item"
                      @click="openMenu = null"
                    >
                      <svg class="mega-item-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
                      </svg>
                      <span>
                        <span class="mega-item-name">{{ item.name }}</span>
                        <span class="mega-item-desc">{{ item.desc }}</span>
                      </span>
                    </a>
                    <router-link
                      v-else
                      :to="item.href"
                      class="mega-item"
                      @click="openMenu = null"
                    >
                      <svg class="mega-item-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
                      </svg>
                      <span>
                        <span class="mega-item-name">{{ item.name }}</span>
                        <span class="mega-item-desc">{{ item.desc }}</span>
                      </span>
                    </router-link>
                  </template>
                  <router-link to="/for-explorers" class="mega-footer-link" @click="openMenu = null">
                    个人版全部方案 →
                  </router-link>
                </div>

                <!-- Divider -->
                <div class="mega-menu-divider" aria-hidden="true"></div>

                <!-- AI Infrastructure column -->
                <div>
                  <p class="mega-group-label">AI 基础设施</p>
                  <template v-for="item in infraProducts" :key="item.name">
                    <a
                      v-if="item.external"
                      :href="item.href"
                      target="_blank"
                      rel="noopener noreferrer"
                      class="mega-item"
                      @click="openMenu = null"
                    >
                      <svg class="mega-item-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
                      </svg>
                      <span>
                        <span class="mega-item-name">{{ item.name }}</span>
                        <span class="mega-item-desc">{{ item.desc }}</span>
                      </span>
                    </a>
                    <router-link
                      v-else
                      :to="item.href"
                      class="mega-item"
                      @click="openMenu = null"
                    >
                      <svg class="mega-item-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
                      </svg>
                      <span>
                        <span class="mega-item-name">{{ item.name }}</span>
                        <span class="mega-item-desc">{{ item.desc }}</span>
                      </span>
                    </router-link>
                  </template>
                  <router-link to="/for-entrepreneurs" class="mega-footer-link" @click="openMenu = null">
                    企业版方案 →
                  </router-link>
                </div>

                <!-- Divider -->
                <div class="mega-menu-divider" aria-hidden="true"></div>

                <!-- Dev / Platform column -->
                <div>
                  <p class="mega-group-label">开发者平台</p>
                  <template v-for="item in devProducts" :key="item.name">
                    <a
                      v-if="item.external"
                      :href="item.href"
                      target="_blank"
                      rel="noopener noreferrer"
                      class="mega-item"
                      @click="openMenu = null"
                    >
                      <svg class="mega-item-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
                      </svg>
                      <span>
                        <span class="mega-item-name">{{ item.name }}</span>
                        <span class="mega-item-desc">{{ item.desc }}</span>
                      </span>
                    </a>
                    <router-link
                      v-else
                      :to="item.href"
                      class="mega-item"
                      @click="openMenu = null"
                    >
                      <svg class="mega-item-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
                      </svg>
                      <span>
                        <span class="mega-item-name">{{ item.name }}</span>
                        <span class="mega-item-desc">{{ item.desc }}</span>
                      </span>
                    </router-link>
                  </template>
                  <router-link to="/for-builders" class="mega-footer-link" @click="openMenu = null">
                    开发者集成方案 →
                  </router-link>
                </div>
              </div>
            </div>
          </Transition>
        </div>

        <router-link to="/pricing" class="nav-link">定价</router-link>
        <a href="https://docs.lurus.cn" target="_blank" rel="noopener noreferrer" class="nav-link">文档</a>
        <router-link to="/about" class="nav-link">关于</router-link>
      </nav>

      <!-- Auth / User area (desktop) -->
      <div class="topbar-auth">
        <!-- Mail icon -->
        <a
          href="https://mail.lurus.cn"
          target="_blank"
          rel="noopener noreferrer"
          class="topbar-icon-btn"
          aria-label="Lurus Mail"
          title="Lurus Mail"
        >
          <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
          </svg>
        </a>

        <template v-if="isLoggedIn && userInfo">
          <AccountBadge />
          <div class="user-chip">
            <img
              v-if="userInfo.picture"
              :src="userInfo.picture"
              :alt="`${displayName(userInfo)} avatar`"
              class="w-6 h-6 rounded-full border border-surface-border"
            >
            <div v-else class="user-avatar">
              {{ displayInitial(userInfo) }}
            </div>
            <span class="user-name">{{ displayName(userInfo) }}</span>
          </div>
          <button @click="logout()" class="nav-link text-text-muted">退出</button>
        </template>
        <template v-else>
          <button @click="login()" class="nav-link">登录</button>
          <button @click="login({ prompt: 'create' })" class="topbar-cta">
            免费开始 <span aria-hidden="true">→</span>
          </button>
        </template>
      </div>

      <!-- Mobile hamburger -->
      <button
        class="mobile-toggle"
        @click="toggleMobile"
        :aria-expanded="mobileOpen"
        aria-label="Toggle navigation"
      >
        <svg v-if="!mobileOpen" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
        <svg v-else class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>

    <!-- Mobile menu -->
    <Transition
      enter-active-class="transition-all duration-250 ease-out"
      enter-from-class="opacity-0 -translate-y-3"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition-all duration-200 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-3"
    >
      <div
        v-if="mobileOpen"
        class="mobile-menu"
        role="dialog"
        aria-modal="true"
        aria-label="Navigation menu"
      >
        <div class="mobile-menu-inner">
          <p class="mobile-section-label">个人工具</p>
          <template v-for="item in consumerProducts" :key="item.name">
            <a
              v-if="item.external"
              :href="item.href"
              target="_blank"
              rel="noopener noreferrer"
              class="mobile-item"
              @click="closeMobile"
            >
              <svg class="w-4 h-4 text-ochre shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
              </svg>
              <span>{{ item.name }}</span>
            </a>
            <router-link
              v-else
              :to="item.href"
              class="mobile-item"
              @click="closeMobile"
            >
              <svg class="w-4 h-4 text-ochre shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
              </svg>
              <span>{{ item.name }}</span>
            </router-link>
          </template>

          <div class="mobile-divider"></div>
          <p class="mobile-section-label">AI 基础设施</p>
          <template v-for="item in infraProducts" :key="item.name">
            <a
              v-if="item.external"
              :href="item.href"
              target="_blank"
              rel="noopener noreferrer"
              class="mobile-item"
              @click="closeMobile"
            >
              <svg class="w-4 h-4 text-ochre shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
              </svg>
              <span>{{ item.name }}</span>
            </a>
            <router-link
              v-else
              :to="item.href"
              class="mobile-item"
              @click="closeMobile"
            >
              <svg class="w-4 h-4 text-ochre shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
              </svg>
              <span>{{ item.name }}</span>
            </router-link>
          </template>

          <div class="mobile-divider"></div>
          <p class="mobile-section-label">开发者平台</p>
          <template v-for="item in devProducts" :key="item.name">
            <a
              v-if="item.external"
              :href="item.href"
              target="_blank"
              rel="noopener noreferrer"
              class="mobile-item"
              @click="closeMobile"
            >
              <svg class="w-4 h-4 text-ochre shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
              </svg>
              <span>{{ item.name }}</span>
            </a>
            <router-link
              v-else
              :to="item.href"
              class="mobile-item"
              @click="closeMobile"
            >
              <svg class="w-4 h-4 text-ochre shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="navIconPaths[item.icon]" />
              </svg>
              <span>{{ item.name }}</span>
            </router-link>
          </template>

          <div class="mobile-divider"></div>
          <router-link to="/pricing" class="mobile-item" @click="closeMobile">定价</router-link>
          <a href="https://docs.lurus.cn" target="_blank" rel="noopener noreferrer" class="mobile-item" @click="closeMobile">文档</a>
          <router-link to="/about" class="mobile-item" @click="closeMobile">关于</router-link>

          <div class="mobile-divider"></div>
          <template v-if="isLoggedIn && userInfo">
            <div class="mobile-user">
              <div class="user-avatar-lg">{{ displayInitial(userInfo) }}</div>
              <div>
                <p class="text-sm font-medium" style="color: var(--color-text-primary)">{{ displayName(userInfo) }}</p>
                <p class="text-xs" style="color: var(--color-text-muted)">{{ userInfo.email }}</p>
              </div>
            </div>
            <button @click="logout(); closeMobile()" class="mobile-item" style="color: #e57373;">退出登录</button>
          </template>
          <template v-else>
            <button @click="login(); closeMobile()" class="mobile-item">登录</button>
            <button
              @click="login({ prompt: 'create' }); closeMobile()"
              class="mobile-cta"
            >
              免费开始
            </button>
          </template>
        </div>
      </div>
    </Transition>
  </header>
</template>

<style scoped>
@reference "../../styles/main.css";

/* ——— Shell ——— */
.app-topbar {
  grid-area: topbar;
  height: 64px;
  position: sticky;
  top: 0;
  z-index: 50;
  background-color: rgba(13, 11, 9, 0.85);
  border-bottom: 1px solid transparent;
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  transition: border-color 0.3s ease, background-color 0.3s ease;
}

.app-topbar--scrolled {
  background-color: rgba(13, 11, 9, 0.95);
  border-bottom-color: var(--color-surface-border);
}

.topbar-inner {
  display: flex;
  align-items: center;
  height: 100%;
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 24px;
  gap: 8px;
}

/* ——— Logo ——— */
.topbar-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  text-decoration: none;
  flex-shrink: 0;
}

.logo-mark {
  width: 32px;
  height: 32px;
  border-radius: 7px;
  background-color: var(--color-ochre);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 16px;
  color: #0D0B09;
  transition: transform 0.2s ease;
}

.topbar-logo:hover .logo-mark {
  transform: rotate(-5deg) scale(1.05);
}

.logo-name {
  font-size: 18px;
  font-weight: 700;
  color: var(--color-text-primary);
  letter-spacing: -0.02em;
}

/* ——— Desktop nav ——— */
.topbar-nav {
  display: none;
  align-items: center;
  gap: 2px;
  margin: 0 auto;
  flex: 1;
  justify-content: center;
}

@media (min-width: 768px) {
  .topbar-nav { display: flex; }
}

.nav-item {
  position: relative;
}

.nav-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 7px 14px;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-text-secondary);
  border-radius: 7px;
  cursor: pointer;
  transition: color 0.15s ease, background-color 0.15s ease;
  background: transparent;
  border: none;
  text-decoration: none;
  white-space: nowrap;
}

.nav-link:hover,
.nav-link--active {
  color: var(--color-text-primary);
  background-color: rgba(255, 255, 255, 0.06);
}

.nav-chevron {
  width: 14px;
  height: 14px;
  transition: transform 0.2s ease;
}

/* ——— Mega Menu ——— */
.mega-menu {
  position: absolute;
  top: calc(100% + 10px);
  left: 50%;
  transform: translateX(-50%);
  width: 640px;
  background-color: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  border-radius: 14px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.6), 0 0 0 1px rgba(255,255,255,0.04);
  overflow: hidden;
  z-index: 60;
}

.mega-menu-grid {
  display: grid;
  grid-template-columns: 1fr 1px 1fr 1px 1fr;
  gap: 0;
  padding: 16px;
}

.mega-menu-divider {
  background-color: var(--color-surface-border);
  margin: 0 8px;
}

.mega-group-label {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--color-text-muted);
  padding: 4px 8px 8px;
}

.mega-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 8px;
  border-radius: 8px;
  text-decoration: none;
  transition: background-color 0.15s ease;
  cursor: pointer;
}

.mega-item:hover {
  background-color: rgba(255, 255, 255, 0.06);
}

.mega-item-icon {
  width: 18px;
  height: 18px;
  color: var(--color-ochre);
  flex-shrink: 0;
  margin-top: 1px;
}

.mega-item-name {
  display: block;
  font-size: 13px;
  font-weight: 500;
  color: var(--color-text-primary);
  line-height: 1.3;
}

.mega-item-desc {
  display: block;
  font-size: 11px;
  color: var(--color-text-muted);
  margin-top: 1px;
  line-height: 1.4;
}

.mega-footer-link {
  display: block;
  margin-top: 8px;
  padding: 6px 8px;
  font-size: 12px;
  font-weight: 500;
  color: var(--color-ochre);
  text-decoration: none;
  transition: opacity 0.15s ease;
}

.mega-footer-link:hover {
  opacity: 0.8;
}

/* ——— Auth area ——— */
.topbar-auth {
  display: none;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
}

@media (min-width: 768px) {
  .topbar-auth { display: flex; }
}

.topbar-icon-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 7px;
  color: var(--color-text-muted);
  transition: color 0.15s ease, background-color 0.15s ease;
  text-decoration: none;
}

.topbar-icon-btn:hover {
  color: var(--color-ochre);
  background-color: rgba(255, 255, 255, 0.06);
}

.user-chip {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 10px 4px 4px;
  border-radius: 20px;
  background-color: rgba(255, 255, 255, 0.06);
  border: 1px solid var(--color-surface-border);
}

.user-avatar {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background-color: var(--color-ochre);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 700;
  color: #0D0B09;
}

.user-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-text-primary);
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.topbar-cta {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 7px 16px;
  font-size: 14px;
  font-weight: 600;
  background-color: var(--color-ochre);
  color: #0D0B09;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.2s ease, box-shadow 0.2s ease;
  white-space: nowrap;
  text-decoration: none;
}

.topbar-cta:hover {
  background-color: color-mix(in srgb, var(--color-ochre), #fff 15%);
  box-shadow: 0 2px 12px rgba(212, 168, 39, 0.4);
}

/* ——— Mobile toggle ——— */
.mobile-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  color: var(--color-text-secondary);
  background: transparent;
  border: none;
  cursor: pointer;
  transition: color 0.15s ease, background-color 0.15s ease;
  margin-left: auto;
}

.mobile-toggle:hover {
  color: var(--color-text-primary);
  background-color: rgba(255, 255, 255, 0.06);
}

@media (min-width: 768px) {
  .mobile-toggle { display: none; }
}

/* ——— Mobile menu ——— */
.mobile-menu {
  position: fixed;
  inset: 64px 0 0;
  background-color: var(--color-surface-overlay);
  border-top: 1px solid var(--color-surface-border);
  overflow-y: auto;
  z-index: 49;
}

.mobile-menu-inner {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.mobile-section-label {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--color-text-muted);
  padding: 8px 12px 4px;
}

.mobile-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 11px 12px;
  font-size: 14px;
  font-weight: 500;
  color: var(--color-text-secondary);
  border-radius: 8px;
  text-decoration: none;
  cursor: pointer;
  background: transparent;
  border: none;
  width: 100%;
  text-align: left;
  transition: color 0.15s ease, background-color 0.15s ease;
}

.mobile-item:hover {
  color: var(--color-text-primary);
  background-color: rgba(255, 255, 255, 0.06);
}

.mobile-divider {
  height: 1px;
  background-color: var(--color-surface-border);
  margin: 6px 0;
}

.mobile-user {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
}

.user-avatar-lg {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background-color: var(--color-ochre);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  color: #0D0B09;
  flex-shrink: 0;
}

.mobile-cta {
  margin: 8px 0;
  padding: 12px;
  font-size: 15px;
  font-weight: 600;
  background-color: var(--color-ochre);
  color: #0D0B09;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  text-align: center;
  width: 100%;
  transition: background-color 0.2s ease;
}

.mobile-cta:hover {
  background-color: color-mix(in srgb, var(--color-ochre), #fff 15%);
}

@media (prefers-reduced-motion: reduce) {
  .app-topbar,
  .nav-link,
  .mega-item,
  .mobile-item {
    transition: none;
  }
}
</style>
