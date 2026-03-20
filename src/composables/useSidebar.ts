/**
 * Sidebar state management composable
 * Handles responsive sidebar behavior: expanded / collapsed / mobile drawer
 */

import { ref, onMounted, onUnmounted, watch, getCurrentInstance } from 'vue'
import { useRoute } from 'vue-router'

const BREAKPOINT_LG = 1024
const BREAKPOINT_MD = 768

// Shared singleton state
const isCollapsed = ref(false)
const isMobileOpen = ref(false)

export const useSidebar = () => {
  const toggle = () => {
    if (typeof window !== 'undefined' && window.innerWidth < BREAKPOINT_MD) {
      isMobileOpen.value = !isMobileOpen.value
      document.body.style.overflow = isMobileOpen.value ? 'hidden' : ''
    } else {
      isCollapsed.value = !isCollapsed.value
    }
  }

  const closeMobile = () => {
    isMobileOpen.value = false
    if (typeof document !== 'undefined') {
      document.body.style.overflow = ''
    }
  }

  const handleResize = () => {
    const w = window.innerWidth
    if (w >= BREAKPOINT_LG) {
      isCollapsed.value = false
      closeMobile()
    } else if (w >= BREAKPOINT_MD) {
      isCollapsed.value = true
      closeMobile()
    } else {
      // sm: sidebar hidden by default, mobile drawer mode
      isCollapsed.value = false
    }
  }

  // Close mobile drawer on route change — guarded for test environments without router
  const instance = getCurrentInstance()
  if (instance?.appContext.config.globalProperties.$router) {
    const route = useRoute()
    watch(() => route.path, () => {
      closeMobile()
    })
  }

  onMounted(() => {
    handleResize()
    window.addEventListener('resize', handleResize)
  })

  onUnmounted(() => {
    window.removeEventListener('resize', handleResize)
    // Ensure body scroll lock is released if component unmounts while mobile drawer is open
    if (isMobileOpen.value) {
      isMobileOpen.value = false
      document.body.style.overflow = ''
    }
  })

  return { isCollapsed, isMobileOpen, toggle, closeMobile }
}
