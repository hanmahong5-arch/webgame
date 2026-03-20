/**
 * AI Chat core logic composable
 * Handles message sending with debounce, mutex lock, optimistic updates, and retry
 */

import { ref, computed } from 'vue'
import type { ChatMessage } from '../types/chat'
import { useChatPersist } from './useChatPersist'
import { useChatApi, getErrorCode } from './useChatApi'
import { useNetworkStatus } from './useNetworkStatus'
import { useToast } from './useToast'
import { chatModels, quickPrompts, chatConfig, DOCS_URL } from '../data/chatModels'
import { checkRateLimit } from '../utils/rateLimiter'

// Debounce settings from centralized config
const DEBOUNCE_MS = chatConfig.debounceMs

export const useAIChat = () => {
  // Composables
  const { messages, selectedModel, clear: clearPersist } = useChatPersist()
  const { sendStreamMessage } = useChatApi()
  const { isOnline } = useNetworkStatus()

  // Local state
  const isLoading = ref(false)
  const isTyping = ref(false)
  const inputMessage = ref('')
  const isStreamingComplete = ref(false)

  // Mutex lock and debounce state
  let sendingPromise: Promise<void> | null = null
  let lastSendTime = 0

  // AbortController for active streaming — allows cancellation on navigation/unmount
  let streamController: AbortController | null = null

  // Computed
  const canSend = computed(() => {
    return inputMessage.value.trim().length > 0 && !isLoading.value && isOnline.value
  })

  const hasMessages = computed(() => messages.value.length > 0)

  /**
   * Check if the latest user message has exhausted all retries.
   * This indicates the Chat backend is persistently unavailable,
   * so the ChatErrorBanner with docs link should be shown.
   */
  const hasRetriesExhausted = computed(() => {
    if (messages.value.length === 0) return false
    const lastUserMessage = [...messages.value]
      .reverse()
      .find(m => m.role === 'user')
    if (!lastUserMessage) return false
    return (
      (lastUserMessage.status === 'failed' || lastUserMessage.status === 'timeout') &&
      !isLoading.value
    )
  })

  /**
   * Generate unique message ID
   */
  const generateId = (): string => {
    return `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }

  /**
   * Find and update a message by ID
   */
  const updateMessage = (id: string, updates: Partial<ChatMessage>) => {
    const index = messages.value.findIndex(m => m.id === id)
    if (index !== -1) {
      messages.value[index] = { ...messages.value[index], ...updates }
    }
  }


  /**
   * Send message with streaming.
   * Creates assistant message placeholder, then progressively updates content.
   */
  const sendMessage = async (content?: string) => {
    const messageContent = (content || inputMessage.value).trim()
    if (!messageContent) return

    // Rate limit check — notify via toast, don't throw (caller doesn't catch)
    const rateResult = checkRateLimit()
    if (!rateResult.allowed) {
      const waitSec = Math.ceil((rateResult.retryAfterMs || 0) / 1000)
      const toast = useToast()
      toast.warning('请求过于频繁', `请等待 ${waitSec} 秒后再发送。`)
      return
    }

    // Debounce check
    const now = Date.now()
    if (now - lastSendTime < DEBOUNCE_MS) return

    // Mutex lock check
    if (sendingPromise) return

    lastSendTime = now
    inputMessage.value = ''
    isStreamingComplete.value = false

    // Create optimistic user message
    const userMsgId = generateId()
    messages.value.push({
      id: userMsgId,
      role: 'user',
      content: messageContent,
      timestamp: new Date(),
      status: 'sending',
      isOptimistic: true,
      retryCount: 0
    })

    // Create assistant message placeholder for streaming
    const assistantMsgId = generateId()
    messages.value.push({
      id: assistantMsgId,
      role: 'assistant',
      content: '',
      timestamp: new Date(),
      status: 'streaming'
    })

    sendingPromise = (async () => {
      isLoading.value = true
      isTyping.value = true

      // Create fresh AbortController for this stream
      streamController?.abort()
      const controller = new AbortController()
      streamController = controller

      try {
        // Prepare messages for API (exclude streaming placeholder)
        const apiMessages = messages.value
          .filter(m => m.status !== 'failed' && m.status !== 'timeout' && m.status !== 'streaming')
          .map(m => ({
            role: m.role,
            content: m.content
          }))

        // Mark user message as sent
        updateMessage(userMsgId, {
          status: 'sent',
          isOptimistic: false
        })

        // Stream tokens into the assistant message (pass abort signal)
        await sendStreamMessage(apiMessages, selectedModel.value, (token) => {
          const idx = messages.value.findIndex(m => m.id === assistantMsgId)
          if (idx !== -1) {
            messages.value[idx] = {
              ...messages.value[idx],
              content: messages.value[idx].content + token
            }
          }
        }, controller.signal)

        // Stream complete - finalize assistant message
        const finalMsg = messages.value.find(m => m.id === assistantMsgId)
        const finalContent = finalMsg?.content || ''

        if (!finalContent) {
          updateMessage(assistantMsgId, {
            content: '抱歉，未收到有效回复',
            status: 'sent'
          })
        } else {
          updateMessage(assistantMsgId, { status: 'sent' })
        }

        isStreamingComplete.value = true
      } catch (error) {
        // User-initiated cancel (navigation away, clearChat) — clean up silently
        if (error instanceof DOMException && error.name === 'AbortError') {
          const assistantIdx = messages.value.findIndex(m => m.id === assistantMsgId)
          if (assistantIdx !== -1 && !messages.value[assistantIdx].content) {
            messages.value.splice(assistantIdx, 1)
          }
          return
        }

        const errorCode = getErrorCode(error)
        const assistantMsg = messages.value.find(m => m.id === assistantMsgId)

        if (assistantMsg && !assistantMsg.content) {
          // No content received - remove empty placeholder, mark user msg failed
          const assistantIdx = messages.value.findIndex(m => m.id === assistantMsgId)
          if (assistantIdx !== -1) {
            messages.value.splice(assistantIdx, 1)
          }
          updateMessage(userMsgId, {
            status: errorCode === 'TIMEOUT' ? 'timeout' : 'failed',
            errorCode,
            retryCount: (messages.value.find(m => m.id === userMsgId)?.retryCount || 0) + 1
          })
        } else {
          // Partial content - mark assistant message as failed
          updateMessage(assistantMsgId, {
            status: 'failed',
            errorCode
          })
        }
      } finally {
        isLoading.value = false
        isTyping.value = false
        sendingPromise = null
        if (streamController === controller) {
          streamController = null
        }
      }
    })()

    await sendingPromise
  }

  /**
   * Retry a failed message using streaming
   */
  const retryMessage = async (messageId: string) => {
    const message = messages.value.find(m => m.id === messageId)
    if (!message || message.role !== 'user') return

    updateMessage(messageId, {
      status: 'sending',
      errorCode: undefined
    })

    isLoading.value = true
    isTyping.value = true
    isStreamingComplete.value = false

    // Create assistant placeholder for streaming retry
    const assistantMsgId = generateId()
    messages.value.push({
      id: assistantMsgId,
      role: 'assistant',
      content: '',
      timestamp: new Date(),
      status: 'streaming'
    })

    // Create fresh AbortController for this retry stream
    streamController?.abort()
    const controller = new AbortController()
    streamController = controller

    try {
      const messageIndex = messages.value.findIndex(m => m.id === messageId)
      const apiMessages = messages.value
        .slice(0, messageIndex + 1)
        .filter(m => (m.status !== 'failed' && m.status !== 'timeout' && m.status !== 'streaming') || m.id === messageId)
        .map(m => ({
          role: m.role,
          content: m.content
        }))

      updateMessage(messageId, {
        status: 'sent',
        isOptimistic: false
      })

      await sendStreamMessage(apiMessages, selectedModel.value, (token) => {
        const idx = messages.value.findIndex(m => m.id === assistantMsgId)
        if (idx !== -1) {
          messages.value[idx] = {
            ...messages.value[idx],
            content: messages.value[idx].content + token
          }
        }
      }, controller.signal)

      updateMessage(assistantMsgId, { status: 'sent' })
      isStreamingComplete.value = true
    } catch (error) {
      // User-initiated cancel — clean up silently
      if (error instanceof DOMException && error.name === 'AbortError') {
        const idx = messages.value.findIndex(m => m.id === assistantMsgId)
        if (idx !== -1 && !messages.value[idx].content) {
          messages.value.splice(idx, 1)
        }
        return
      }

      const errorCode = getErrorCode(error)
      const currentRetryCount = message.retryCount || 0
      const assistantMsg = messages.value.find(m => m.id === assistantMsgId)

      if (assistantMsg && !assistantMsg.content) {
        const idx = messages.value.findIndex(m => m.id === assistantMsgId)
        if (idx !== -1) messages.value.splice(idx, 1)
      } else if (assistantMsg) {
        updateMessage(assistantMsgId, { status: 'failed', errorCode })
      }

      updateMessage(messageId, {
        status: errorCode === 'TIMEOUT' ? 'timeout' : 'failed',
        errorCode,
        retryCount: currentRetryCount + 1
      })
    } finally {
      isLoading.value = false
      isTyping.value = false
      if (streamController === controller) {
        streamController = null
      }
    }
  }

  /**
   * Delete a message
   */
  const deleteMessage = (messageId: string) => {
    const index = messages.value.findIndex(m => m.id === messageId)
    if (index !== -1) {
      messages.value.splice(index, 1)
    }
  }

  /**
   * Cancel any active streaming request.
   * Call on component unmount to prevent stale updates.
   */
  const cancelStreaming = () => {
    streamController?.abort()
    streamController = null
    sendingPromise = null
    isLoading.value = false
    isTyping.value = false
  }

  /**
   * Clear all messages
   */
  const clearChat = () => {
    cancelStreaming()
    clearPersist()
  }

  /**
   * Apply quick prompt to input
   */
  const applyPrompt = (prompt: string) => {
    inputMessage.value = prompt
  }

  return {
    // State
    messages,
    selectedModel,
    isLoading,
    isTyping,
    inputMessage,
    isOnline,
    isStreamingComplete,

    // Computed
    canSend,
    hasMessages,
    hasRetriesExhausted,

    // Constants (from centralized data)
    models: chatModels,
    quickPrompts,
    docsUrl: DOCS_URL,

    // Methods
    sendMessage,
    retryMessage,
    deleteMessage,
    clearChat,
    applyPrompt,
    updateMessage,
    cancelStreaming
  }
}
