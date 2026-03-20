<script setup lang="ts">
import type { ChatMessage } from '../../types/chat'
import { computed } from 'vue'

// Single message bubble component with status indicators and retry

const props = defineProps<{
  message: ChatMessage
}>()

const emit = defineEmits<{
  retry: [id: string]
  delete: [id: string]
}>()

const isUser = computed(() => props.message.role === 'user')
const isFailed = computed(() => props.message.status === 'failed' || props.message.status === 'timeout')
const isStreaming = computed(() => props.message.status === 'streaming')
const isSending = computed(() => props.message.status === 'sending')

const formattedTime = computed(() => {
  const date = props.message.timestamp
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  return `${hours}:${minutes}`
})

/**
 * User-friendly status text based on error code.
 * Tells the user what happened + what to do.
 */
const statusText = computed(() => {
  if (isSending.value) return '发送中…'
  if (!isFailed.value) return ''

  const code = props.message.errorCode
  switch (code) {
    case 'TIMEOUT':
      return '请求超时 — 请重试'
    case 'NETWORK_ERROR':
      return '网络异常 — 请检查连接'
    case 'HTTP_401':
      return '认证已过期 — 请刷新页面'
    case 'HTTP_429':
      return '请求过于频繁 — 请稍候'
    case 'HTTP_500':
    case 'HTTP_502':
    case 'HTTP_503':
      return '服务繁忙 — 请稍后重试'
    default:
      return '发送失败 — 点击重试'
  }
})

const handleRetry = () => {
  emit('retry', props.message.id)
}

const handleDelete = () => {
  emit('delete', props.message.id)
}
</script>

<template>
  <div
    class="message-wrapper"
    :class="{
      'is-user': isUser,
      'is-assistant': !isUser,
      'is-streaming': isStreaming,
      'is-sending': isSending,
      'is-failed': isFailed
    }"
  >
    <div class="message-bubble">
      <p class="content">{{ message.content }}<span v-if="isStreaming" class="streaming-cursor" aria-hidden="true"></span></p>

      <!-- Status indicator -->
      <div v-if="isSending || isFailed" class="status-bar">
        <span class="status-text" :class="{ 'text-failed': isFailed }">
          <!-- Loading spinner -->
          <svg v-if="isSending" class="spinner" viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <circle class="spinner-track" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
            <path class="spinner-path" d="M12 2a10 10 0 0 1 10 10" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          <!-- Error icon -->
          <svg v-else-if="isFailed" class="error-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
            <path d="M12 8v4m0 4h.01" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          {{ statusText }}
        </span>

        <!-- Retry and delete buttons for failed messages -->
        <div v-if="isFailed" class="action-buttons">
          <button
            @click="handleRetry"
            class="action-btn retry-btn"
            aria-label="重试发送"
          >
            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path d="M4 4v5h5M20 20v-5h-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m23 4l-4.64 4.36A9 9 0 0 1 3.51 15" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            重试
          </button>
          <button
            @click="handleDelete"
            class="action-btn delete-btn"
            aria-label="删除消息"
          >
            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path d="M6 18L18 6M6 6l12 12" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Timestamp -->
    <time class="timestamp" :datetime="message.timestamp.toISOString()">
      {{ formattedTime }}
    </time>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.message-wrapper {
  display: flex;
  flex-direction: column;
  gap: 4px;
  max-width: 85%;
  animation: fadeIn 0.2s ease-out;
}

.streaming-cursor {
  display: inline-block;
  width: 2px;
  height: 1em;
  background: var(--color-text-muted);
  margin-left: 2px;
  vertical-align: text-bottom;
  animation: blink 0.8s step-end infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0; }
}

.is-streaming .message-bubble {
  opacity: 1;
}

@media (prefers-reduced-motion: reduce) {
  .streaming-cursor {
    animation: none;
    opacity: 1;
  }

  .message-wrapper {
    animation: none;
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.message-wrapper.is-user {
  align-self: flex-end;
  align-items: flex-end;
}

.message-wrapper.is-assistant {
  align-self: flex-start;
  align-items: flex-start;
}

.message-bubble {
  padding: 12px 16px;
  font-size: 14px;
  line-height: 1.5;
  word-break: break-word;
}

.is-user .message-bubble {
  background: var(--color-ochre);
  color: var(--color-text-primary);
  border-radius: 16px 16px 4px 16px;
}

.is-assistant .message-bubble {
  background: var(--color-surface-raised);
  color: var(--color-text-primary);
  border: 1px solid var(--color-surface-border);
  border-radius: 16px 16px 16px 4px;
}

.is-sending .message-bubble {
  opacity: 0.8;
}

.is-failed.is-user .message-bubble {
  background: linear-gradient(135deg, var(--color-ochre), #b8921f);
  border: 2px solid #dc2626;
}

.content {
  margin: 0;
  white-space: pre-wrap;
}

.status-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
}

.status-text {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  opacity: 0.9;
}

.text-failed {
  color: #fecaca;
}

.spinner,
.error-icon {
  width: 14px;
  height: 14px;
}

.spinner {
  animation: spin 1s linear infinite;
}

.spinner-track {
  opacity: 0.3;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.action-buttons {
  display: flex;
  gap: 6px;
}

.action-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  font-size: 11px;
  font-weight: 500;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.15s ease;
}

.action-btn svg {
  width: 12px;
  height: 12px;
}

.retry-btn {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

.retry-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

.delete-btn {
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.8);
  padding: 4px 6px;
}

.delete-btn:hover {
  background: rgba(220, 38, 38, 0.5);
  color: white;
}

.timestamp {
  font-size: 11px;
  color: var(--color-text-secondary);
  padding: 0 4px;
}
</style>
