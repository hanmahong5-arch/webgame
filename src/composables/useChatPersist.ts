/**
 * Chat persistence composable
 * Handles localStorage save/restore for chat history
 */

import { ref, watch, onMounted, onUnmounted } from 'vue'
import type { ChatMessage } from '../types/chat'

const STORAGE_KEY = 'lurus-ai-chat'
const MAX_MESSAGES = 50
const PERSIST_DEBOUNCE_MS = 1000

interface PersistedState {
  messages: Array<{
    id: string
    role: 'user' | 'assistant' | 'system'
    content: string
    timestamp: string
    status: 'sending' | 'sent' | 'failed' | 'timeout'
    isOptimistic?: boolean
    retryCount?: number
    errorCode?: string
  }>
  model: string
}

export const useChatPersist = () => {
  const messages = ref<ChatMessage[]>([])
  const selectedModel = ref('deepseek-chat')
  const isRestored = ref(false)

  /**
   * Restore state from localStorage
   */
  const restore = () => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY)
      if (saved) {
        const data: PersistedState = JSON.parse(saved)

        // Convert timestamp strings back to Date objects
        // Filter out any 'sending' status messages (incomplete from previous session)
        messages.value = data.messages
          .filter(m => m.status !== 'sending')
          .map(m => ({
            ...m,
            timestamp: new Date(m.timestamp),
            // Reset failed messages to allow retry
            status: m.status === 'failed' || m.status === 'timeout' ? m.status : 'sent'
          })) as ChatMessage[]

        selectedModel.value = data.model || 'deepseek-chat'
      }
    } catch (error) {
      console.error('Failed to restore chat state:', error)
      // Clear corrupted data
      localStorage.removeItem(STORAGE_KEY)
    }
    isRestored.value = true
  }

  /**
   * Save state to localStorage
   */
  const persist = () => {
    try {
      const data: PersistedState = {
        // Only keep last MAX_MESSAGES
        // Don't persist 'sending' status messages
        messages: messages.value
          .filter(m => m.status !== 'sending')
          .slice(-MAX_MESSAGES)
          .map(m => ({
            ...m,
            timestamp: m.timestamp.toISOString()
          })) as PersistedState['messages'],
        model: selectedModel.value
      }
      localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
    } catch (error) {
      console.error('Failed to persist chat state:', error)
    }
  }

  /**
   * Clear all persisted data
   */
  const clear = () => {
    messages.value = []
    localStorage.removeItem(STORAGE_KEY)
  }

  // Restore on mount
  onMounted(() => {
    restore()
  })

  // Auto-save on changes — debounced to avoid hammering localStorage during streaming
  // (streaming fires ~50-100 token updates/second; without debounce each triggers a persist)
  let persistTimer: ReturnType<typeof setTimeout> | null = null

  watch(
    [messages, selectedModel],
    () => {
      if (!isRestored.value) return
      if (persistTimer) clearTimeout(persistTimer)
      persistTimer = setTimeout(() => {
        persist()
        persistTimer = null
      }, PERSIST_DEBOUNCE_MS)
    },
    { deep: true }
  )

  // Flush pending persist immediately on page hide (user closing tab / switching away)
  const handleVisibilityChange = () => {
    if (document.visibilityState === 'hidden' && persistTimer) {
      clearTimeout(persistTimer)
      persistTimer = null
      persist()
    }
  }

  onMounted(() => {
    document.addEventListener('visibilitychange', handleVisibilityChange)
  })

  onUnmounted(() => {
    document.removeEventListener('visibilitychange', handleVisibilityChange)
    // Flush any pending persist on unmount
    if (persistTimer) {
      clearTimeout(persistTimer)
      persistTimer = null
      persist()
    }
  })

  return {
    messages,
    selectedModel,
    isRestored,
    clear,
    persist
  }
}
