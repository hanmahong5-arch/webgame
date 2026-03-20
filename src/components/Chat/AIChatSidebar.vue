<script setup lang="ts">
/**
 * AI Chat Sidebar - Main container component
 * Handles sidebar layout, delegates logic to composables.
 * Open/close state is managed by parent (App.vue) via props/emits.
 * Toggle button has been extracted to ChatFloatingTrigger component.
 */

import { ref, watch, nextTick, onMounted, onUnmounted } from 'vue'
import { useAIChat } from '../../composables/useAIChat'
import { MOBILE_BREAKPOINT, MAX_INPUT_LENGTH, FOCUSABLE_SELECTOR } from '../../constants/ui'
import { parseDropData, buildAnalysisPrompt, hasPortalData } from '../../utils/portalDrag'

// Child components
import ChatHeader from './ChatHeader.vue'
import ChatMessages from './ChatMessages.vue'
import ChatInput from './ChatInput.vue'
import ChatQuickPrompts from './ChatQuickPrompts.vue'
import NetworkStatusBanner from './NetworkStatusBanner.vue'
import ChatErrorBanner from './ChatErrorBanner.vue'

interface PendingPrompt {
  text: string
  id: number
}

interface Props {
  isOpen: boolean
  pendingPrompt?: PendingPrompt | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  close: []
  toggle: []
  'prompt-consumed': []
}>()

const isMobile = ref(false)
const sidebarRef = ref<HTMLElement | null>(null)
const isDragOver = ref(false)
let dragLeaveTimer: ReturnType<typeof setTimeout> | null = null

/**
 * Get all focusable elements within the sidebar for focus trap
 */
const getFocusableElements = (): HTMLElement[] => {
  if (!sidebarRef.value) return []
  return Array.from(sidebarRef.value.querySelectorAll(FOCUSABLE_SELECTOR)) as HTMLElement[]
}

/**
 * Focus trap handler: keeps Tab/Shift+Tab within sidebar
 */
const handleFocusTrap = (e: KeyboardEvent) => {
  if (e.key !== 'Tab') return

  const focusable = getFocusableElements()
  if (focusable.length === 0) return

  const first = focusable[0]
  const last = focusable[focusable.length - 1]

  if (e.shiftKey) {
    // Shift+Tab: wrap from first to last
    if (document.activeElement === first) {
      e.preventDefault()
      last.focus()
    }
  } else {
    // Tab: wrap from last to first
    if (document.activeElement === last) {
      e.preventDefault()
      first.focus()
    }
  }
}

// Chat logic from composable
const {
  messages,
  selectedModel,
  isLoading,
  isTyping,
  inputMessage,
  isOnline,
  canSend: _canSend,
  hasMessages,
  hasRetriesExhausted,
  models,
  quickPrompts,
  docsUrl,
  isStreamingComplete,
  sendMessage,
  retryMessage,
  deleteMessage,
  clearChat,
} = useAIChat()

// Check if mobile on mount and resize
const checkMobile = () => {
  if (typeof window !== 'undefined') {
    isMobile.value = window.innerWidth < MOBILE_BREAKPOINT
  }
}

// Focus into sidebar when opened, add focus trap
watch(() => props.isOpen, (isOpen) => {
  if (isOpen) {
    nextTick(() => {
      const focusable = getFocusableElements()
      if (focusable.length > 0) {
        focusable[0].focus()
      }
      // Add focus trap listener
      sidebarRef.value?.addEventListener('keydown', handleFocusTrap)
    })
  } else {
    // Remove focus trap listener
    sidebarRef.value?.removeEventListener('keydown', handleFocusTrap)
  }
})

const closeSidebar = () => {
  emit('close')
}

// Handle send
const handleSend = () => {
  sendMessage()
}

// Handle quick prompt selection — auto-send the prompt as a message (FR31)
const handlePromptSelect = (prompt: string) => {
  sendMessage(prompt)
}

// Handle model change
const handleModelChange = (model: string) => {
  selectedModel.value = model
}

// Handle message retry
const handleRetry = (id: string) => {
  retryMessage(id)
}

// Handle message delete
const handleDelete = (id: string) => {
  deleteMessage(id)
}

// Handle clear chat
const handleClear = () => {
  clearChat()
}

// Accessibility: close on Escape key
const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && props.isOpen) {
    closeSidebar()
  }
}

/**
 * Watch both pendingPrompt and isOpen together.
 * - immediate: true → handles async component first-load (props already set on mount)
 * - Combined watcher → no duplicate sends when both change in same tick
 * - pendingPrompt is an object { text, id } so watch always triggers (new ref each time)
 */
watch(
  [() => props.pendingPrompt, () => props.isOpen],
  ([pending, isOpen]) => {
    if (pending?.text && isOpen) {
      nextTick(() => {
        sendMessage(pending.text)
        emit('prompt-consumed')
      })
    }
  },
  { immediate: true }
)

// Drag-and-drop handlers for receiving portal links
const handleDragOver = (e: DragEvent) => {
  if (!hasPortalData(e)) return
  e.preventDefault()
  e.dataTransfer!.dropEffect = 'copy'
}

const handleDragEnter = (e: DragEvent) => {
  if (!hasPortalData(e)) return
  if (dragLeaveTimer) {
    clearTimeout(dragLeaveTimer)
    dragLeaveTimer = null
  }
  isDragOver.value = true
}

const handleDragLeave = () => {
  // Debounce to prevent flickering when moving between child elements
  dragLeaveTimer = setTimeout(() => {
    isDragOver.value = false
  }, 50)
}

const handleDrop = (e: DragEvent) => {
  e.preventDefault()
  isDragOver.value = false
  const data = parseDropData(e)
  if (data) {
    const prompt = buildAnalysisPrompt(data)
    sendMessage(prompt)
  }
}

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <!-- Sidebar Panel -->
  <aside
    ref="sidebarRef"
    id="ai-chat-sidebar"
    class="chat-sidebar"
    :class="{
      'is-open': props.isOpen,
      'is-mobile': isMobile
    }"
    role="complementary"
    aria-label="AI 聊天助手"
    @dragover="handleDragOver"
    @dragenter="handleDragEnter"
    @dragleave="handleDragLeave"
    @drop="handleDrop"
  >
    <!-- Drag-drop overlay -->
    <Transition name="fade">
      <div v-if="isDragOver" class="drop-overlay" aria-hidden="true">
        <div class="drop-overlay-content">
          <svg class="drop-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <path d="M12 4v16m-8-8h16" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
          </svg>
          <span class="drop-text">放下链接开始分析</span>
        </div>
      </div>
    </Transition>
    <!-- Network status banner -->
    <NetworkStatusBanner :is-online="isOnline" />

    <!-- Error banner: shown when all retries exhausted (FR32) -->
    <ChatErrorBanner
      v-if="hasRetriesExhausted"
      :docs-url="docsUrl"
    />

    <!-- Header -->
    <ChatHeader
      :selected-model="selectedModel"
      :models="models"
      :has-messages="hasMessages"
      @update:selected-model="handleModelChange"
      @clear="handleClear"
      @close="closeSidebar"
    />

    <!-- Quick prompts: show only when no message history (FR31) -->
    <ChatQuickPrompts
      v-if="!hasMessages"
      :prompts="quickPrompts"
      @select="handlePromptSelect"
    />

    <!-- Messages area -->
    <ChatMessages
      :messages="messages"
      :is-typing="isTyping"
      :is-streaming-complete="isStreamingComplete"
      @retry="handleRetry"
      @delete="handleDelete"
    />

    <!-- Input area -->
    <ChatInput
      v-model="inputMessage"
      :disabled="isLoading || !isOnline"
      placeholder="输入您的问题..."
      :max-length="MAX_INPUT_LENGTH"
      @send="handleSend"
    />

    <!-- Footer -->
    <div class="chat-footer">
      <p class="footer-text">
        Powered by Lurus API
      </p>
    </div>
  </aside>

  <!-- Overlay (mobile) -->
  <Transition name="fade">
    <div
      v-if="props.isOpen && isMobile"
      @click="closeSidebar"
      class="overlay"
      aria-hidden="true"
    ></div>
  </Transition>
</template>

<style scoped>
@reference "../../styles/main.css";

/* Sidebar panel */
.chat-sidebar {
  position: fixed;
  right: 0;
  top: 0;
  height: 100%;
  width: 400px;
  background: var(--color-surface-base);
  box-shadow: -4px 0 20px rgba(0, 0, 0, 0.1);
  z-index: 40;
  display: flex;
  flex-direction: column;
  transform: translateX(100%);
  will-change: transform;
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.chat-sidebar.is-open {
  transform: translateX(0);
}

/* Mobile full-width */
@media (max-width: 640px) {
  .chat-sidebar {
    width: 100%;
  }
}

/* Footer */
.chat-footer {
  padding: 8px 16px;
  text-align: center;
  border-top: 1px solid var(--color-surface-border);
  background: var(--color-surface-raised);
}

.footer-text {
  margin: 0;
  font-size: 11px;
  color: var(--color-text-secondary);
}

/* Drag-drop overlay */
.drop-overlay {
  position: absolute;
  inset: 0;
  z-index: 10;
  background: rgba(201, 162, 39, 0.12);
  border: 3px dashed var(--color-ochre);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}

.drop-overlay-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.drop-icon {
  width: 40px;
  height: 40px;
  color: var(--color-ochre);
}

.drop-text {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-ochre);
}

/* Respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  .chat-sidebar {
    transition: none;
  }

  .fade-enter-active,
  .fade-leave-active {
    transition: none;
  }
}

/* Overlay for mobile */
.overlay {
  position: fixed;
  inset: 0;
  background: rgba(44, 36, 22, 0.2);
  z-index: 30;
  backdrop-filter: blur(2px);
}

/* Fade transition for overlay */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
