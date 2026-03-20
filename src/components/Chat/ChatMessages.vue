<script setup lang="ts">
import { ref, watch, nextTick, onUnmounted } from 'vue'
import type { ChatMessage } from '../../types/chat'
import ChatMessageBubble from './ChatMessageBubble.vue'
import TypingIndicator from './TypingIndicator.vue'

// Messages list component with auto-scroll and empty state

const props = defineProps<{
  messages: ChatMessage[]
  isTyping: boolean
  isStreamingComplete: boolean
}>()

const emit = defineEmits<{
  retry: [id: string]
  delete: [id: string]
}>()

const containerRef = ref<HTMLElement | null>(null)

// Auto-scroll to bottom when new messages arrive
const scrollToBottom = () => {
  nextTick(() => {
    if (containerRef.value) {
      containerRef.value.scrollTop = containerRef.value.scrollHeight
    }
  })
}

// Watch for new messages, typing state, and streaming content changes
watch(
  () => {
    const lastMsg = props.messages[props.messages.length - 1]
    return [props.messages.length, props.isTyping, lastMsg?.content?.length || 0]
  },
  () => {
    scrollToBottom()
  }
)

// Track streaming completion for screen reader announcement
const streamingJustCompleted = ref(false)
let streamCompleteTimer: ReturnType<typeof setTimeout> | null = null
watch(() => props.isStreamingComplete, (complete) => {
  if (complete) {
    streamingJustCompleted.value = true
    if (streamCompleteTimer) clearTimeout(streamCompleteTimer)
    streamCompleteTimer = setTimeout(() => {
      streamingJustCompleted.value = false
      streamCompleteTimer = null
    }, 1000)
  }
})

onUnmounted(() => {
  if (streamCompleteTimer) {
    clearTimeout(streamCompleteTimer)
    streamCompleteTimer = null
  }
})

const handleRetry = (id: string) => {
  emit('retry', id)
}

const handleDelete = (id: string) => {
  emit('delete', id)
}
</script>

<template>
  <div
    ref="containerRef"
    class="messages-container"
    role="log"
    aria-live="polite"
    aria-label="聊天消息"
  >
    <!-- Empty state -->
    <div v-if="messages.length === 0 && !isTyping" class="empty-state">
      <div class="empty-icon" aria-hidden="true">
        <svg viewBox="0 0 24 24" fill="none">
          <path
            d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </div>
      <p class="empty-title">开始对话</p>
      <p class="empty-subtitle">选择模板或直接输入问题</p>
      <p class="empty-hint">支持学术、金融、技术等多领域</p>
    </div>

    <!-- Message list -->
    <div v-else class="messages-list">
      <ChatMessageBubble
        v-for="msg in messages"
        :key="msg.id"
        :message="msg"
        @retry="handleRetry"
        @delete="handleDelete"
      />

      <!-- Typing indicator -->
      <TypingIndicator v-if="isTyping" />

      <!-- Screen reader announcement for streaming completion -->
      <div
        v-if="streamingJustCompleted"
        class="sr-only"
        role="status"
        aria-live="polite"
      >
        AI 回复完成
      </div>
    </div>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.messages-container {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  scroll-behavior: smooth;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  padding: 32px;
  text-align: center;
}

.empty-icon {
  width: 64px;
  height: 64px;
  margin-bottom: 16px;
  color: var(--color-text-secondary);
  opacity: 0.5;
}

.empty-icon svg {
  width: 100%;
  height: 100%;
}

.empty-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--color-text-muted);
  margin: 0 0 8px 0;
}

.empty-subtitle {
  font-size: 14px;
  color: var(--color-text-secondary);
  margin: 0 0 4px 0;
}

.empty-hint {
  font-size: 12px;
  color: var(--color-text-secondary);
  margin: 0;
  opacity: 0.8;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

.messages-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
</style>
