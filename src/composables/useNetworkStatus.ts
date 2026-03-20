/**
 * Network status detection composable
 * Monitors online/offline state, provides reactive status,
 * and shows toast notifications on state transitions.
 */

import { ref, onMounted, onUnmounted } from 'vue'
import { useToast } from './useToast'

// Track whether user has been offline at least once this session,
// so we don't show "back online" on initial page load.
let wasOffline = false
let offlineToastId: number | null = null

export const useNetworkStatus = () => {
  const isOnline = ref(navigator.onLine)

  const handleOnline = () => {
    isOnline.value = true

    // Dismiss the offline toast if still visible
    if (offlineToastId !== null) {
      const toast = useToast()
      toast.dismiss(offlineToastId)
      offlineToastId = null
    }

    // Only show "back online" if user was actually offline
    if (wasOffline) {
      const toast = useToast()
      toast.success('已恢复连接', '网络连接已恢复。')
    }
  }

  const handleOffline = () => {
    isOnline.value = false
    wasOffline = true

    const toast = useToast()
    offlineToastId = toast.addToast({
      type: 'warning',
      title: '网络已断开',
      message: '部分功能可能不可用，恢复连接后将自动重连。',
      duration: 0, // persistent
    })
  }

  onMounted(() => {
    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)
  })

  onUnmounted(() => {
    window.removeEventListener('online', handleOnline)
    window.removeEventListener('offline', handleOffline)
  })

  return { isOnline }
}
