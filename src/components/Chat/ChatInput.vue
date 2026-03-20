<script setup lang="ts">
import { ref, computed, watch, nextTick } from 'vue'
import { MAX_INPUT_LENGTH, MAX_TEXTAREA_HEIGHT } from '../../constants/ui'

// Auto-resizing textarea input component

const props = defineProps<{
  modelValue: string
  disabled?: boolean
  placeholder?: string
  maxLength?: number
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
  send: []
}>()

const textareaRef = ref<HTMLTextAreaElement | null>(null)
const isFocused = ref(false)

const inputValue = computed({
  get: () => props.modelValue,
  set: (value: string) => emit('update:modelValue', value)
})

const charCount = computed(() => props.modelValue.length)
const maxChars = computed(() => props.maxLength || MAX_INPUT_LENGTH)
const canSend = computed(() => inputValue.value.trim().length > 0 && !props.disabled)

// Auto-resize textarea based on content
const autoResize = () => {
  nextTick(() => {
    const el = textareaRef.value
    if (!el) return

    // Reset height to auto to get the correct scrollHeight
    el.style.height = 'auto'
    // Set new height, max height from constant
    el.style.height = Math.min(el.scrollHeight, MAX_TEXTAREA_HEIGHT) + 'px'
  })
}

// Watch for external value changes
watch(() => props.modelValue, () => {
  autoResize()
})

const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    if (canSend.value) {
      emit('send')
    }
  }
}

const handleSend = () => {
  if (canSend.value) {
    emit('send')
  }
}

const handleFocus = () => {
  isFocused.value = true
}

const handleBlur = () => {
  isFocused.value = false
}
</script>

<template>
  <div class="chat-input-wrapper" :class="{ 'is-focused': isFocused, 'is-disabled': disabled }">
    <label for="chat-input" class="sr-only">输入您的问题</label>
    <textarea
      id="chat-input"
      ref="textareaRef"
      v-model="inputValue"
      @input="autoResize"
      @keydown="handleKeydown"
      @focus="handleFocus"
      @blur="handleBlur"
      :placeholder="placeholder || '输入您的问题...'"
      :disabled="disabled"
      :maxlength="maxChars"
      rows="1"
      class="chat-textarea"
      aria-describedby="char-count"
    ></textarea>

    <div class="input-footer">
      <span id="char-count" class="char-count" :class="{ 'near-limit': charCount > maxChars * 0.9 }">
        {{ charCount }}/{{ maxChars }}
      </span>

      <div class="hint">
        <kbd>Enter</kbd> 发送 · <kbd>Shift+Enter</kbd> 换行
      </div>

      <button
        @click="handleSend"
        :disabled="!canSend"
        class="send-btn"
        aria-label="发送消息"
        type="button"
      >
        <svg class="send-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
          <path
            d="M12 19V5m0 0l-7 7m7-7l7 7"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </button>
    </div>
  </div>
</template>

<style scoped>
@reference "../../styles/main.css";

.chat-input-wrapper {
  padding: 12px 16px;
  background: var(--color-surface-raised);
  border-top: 1px solid var(--color-surface-border);
  transition: background 0.2s ease;
}

.chat-input-wrapper.is-focused {
  background: var(--color-surface-base);
}

.chat-input-wrapper.is-disabled {
  opacity: 0.6;
  pointer-events: none;
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

.chat-textarea {
  width: 100%;
  min-height: 40px;
  max-height: 150px;
  padding: 10px 12px;
  font-size: 14px;
  font-family: inherit;
  line-height: 1.5;
  color: var(--color-text-primary);
  background: var(--color-surface-base);
  border: 1.5px solid var(--color-surface-border);
  border-radius: 8px;
  resize: none;
  overflow-y: auto;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.chat-textarea::placeholder {
  color: var(--color-text-secondary);
}

.chat-textarea:focus {
  outline: none;
  border-color: var(--color-ochre);
  box-shadow: 0 0 0 3px rgba(201, 162, 39, 0.15);
}

.chat-textarea:disabled {
  background: var(--color-surface-overlay);
  cursor: not-allowed;
}

.input-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 8px;
  gap: 12px;
}

.char-count {
  font-size: 11px;
  color: var(--color-text-secondary);
  font-variant-numeric: tabular-nums;
}

.char-count.near-limit {
  color: #dc2626;
  font-weight: 500;
}

.hint {
  flex: 1;
  font-size: 11px;
  color: var(--color-text-secondary);
  text-align: center;
}

.hint kbd {
  display: inline-block;
  padding: 1px 5px;
  font-size: 10px;
  font-family: inherit;
  background: var(--color-surface-overlay);
  border: 1px solid var(--color-surface-border);
  border-radius: 3px;
}

.send-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  background: var(--color-ochre);
  color: var(--color-text-primary);
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.send-btn:hover:not(:disabled) {
  background: #b8921f;
  transform: translateY(-1px);
}

.send-btn:active:not(:disabled) {
  transform: translateY(0);
}

.send-btn:disabled {
  background: var(--color-surface-border);
  color: var(--color-text-secondary);
  cursor: not-allowed;
}

.send-btn:focus-visible {
  outline: none;
  box-shadow: 0 0 0 3px rgba(201, 162, 39, 0.4);
}

.send-icon {
  width: 18px;
  height: 18px;
}

/* Mobile adjustments */
@media (max-width: 640px) {
  .hint {
    display: none;
  }
}
</style>
