/**
 * Network status detection composable
 * Monitors online/offline state, provides reactive status,
 * and shows toast notifications on state transitions.
 *
 * Uses module-level singleton: event listeners are registered once,
 * and the reactive `isOnline` ref is shared across all callers.
 */

import { ref } from 'vue'
import { useToast } from './useToast'

// Module-level singleton state
const isOnline = ref(typeof navigator !== 'undefined' ? navigator.onLine : true)
let wasOffline = false
let offlineToastId: number | null = null
let listenersRegistered = false

function handleOnline() {
  isOnline.value = true

  if (offlineToastId !== null) {
    const toast = useToast()
    toast.dismiss(offlineToastId)
    offlineToastId = null
  }

  if (wasOffline) {
    const toast = useToast()
    toast.success('已恢复连接', '网络连接已恢复。')
  }
}

function handleOffline() {
  isOnline.value = false
  wasOffline = true

  const toast = useToast()
  offlineToastId = toast.addToast({
    type: 'warning',
    title: '网络已断开',
    message: '部分功能可能不可用，恢复连接后将自动重连。',
    duration: 0,
  })
}

// Register listeners once at module level (safe: singleton, never removed — app-lifetime)
function ensureListeners() {
  if (listenersRegistered || typeof window === 'undefined') return
  window.addEventListener('online', handleOnline)
  window.addEventListener('offline', handleOffline)
  listenersRegistered = true
}

export const useNetworkStatus = () => {
  ensureListeners()
  return { isOnline }
}
