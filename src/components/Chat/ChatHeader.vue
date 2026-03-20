<script setup lang="ts">
import type { ModelOption } from '../../types/chat'

// Chat header component with title, model selector, and clear button

defineProps<{
  selectedModel: string
  models: ModelOption[]
  hasMessages: boolean
}>()

const emit = defineEmits<{
  'update:selectedModel': [value: string]
  clear: []
  close: []
}>()

const handleModelChange = (event: Event) => {
  const target = event.target as HTMLSelectElement
  emit('update:selectedModel', target.value)
}

const handleClear = () => {
  emit('clear')
}

const handleClose = () => {
  emit('close')
}
</script>

<template>
  <header class="chat-header">
    <div class="header-top">
      <div class="title-group">
        <span class="icon-wrapper" aria-hidden="true">
          <svg class="icon" viewBox="0 0 24 24" fill="none">
            <path
              d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </span>
        <h2 class="title">AI 助手</h2>
      </div>

      <div class="action-buttons">
        <button
          v-if="hasMessages"
          @click="handleClear"
          class="action-btn clear-btn"
          title="清空对话"
          aria-label="清空对话"
        >
          <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <path
              d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </button>
        <button
          @click="handleClose"
          class="action-btn close-btn"
          title="关闭"
          aria-label="关闭AI助手"
        >
          <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <path
              d="M6 18L18 6M6 6l12 12"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
            />
          </svg>
        </button>
      </div>
    </div>

    <div class="model-selector-wrapper">
      <label for="model-select" class="sr-only">选择AI模型</label>
      <select
        id="model-select"
        :value="selectedModel"
        @change="handleModelChange"
        class="model-select"
        aria-label="选择AI模型"
      >
        <option
          v-for="model in models"
          :key="model.id"
          :value="model.id"
        >
          {{ model.name }}
        </option>
      </select>
      <svg class="select-arrow" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>
  </header>
</template>

<style scoped>
@reference "../../styles/main.css";

.chat-header {
  padding: 16px;
  background: var(--color-surface-raised);
  border-bottom: 1px solid var(--color-surface-border);
}

.header-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.title-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: var(--color-ochre);
  border-radius: 8px;
}

.icon-wrapper .icon {
  width: 16px;
  height: 16px;
  color: var(--color-text-primary);
}

.title {
  font-size: 20px;
  font-weight: 600;
  color: var(--color-text-primary);
  margin: 0;
}

.action-buttons {
  display: flex;
  gap: 4px;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  padding: 0;
  background: transparent;
  border: none;
  border-radius: 6px;
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: all 0.15s ease;
}

.action-btn:hover {
  background: var(--color-surface-overlay);
  color: var(--color-text-muted);
}

.action-btn:focus-visible {
  outline: none;
  box-shadow: 0 0 0 2px var(--color-ochre);
}

.action-btn svg {
  width: 18px;
  height: 18px;
}

.clear-btn:hover {
  color: #dc2626;
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

.model-selector-wrapper {
  position: relative;
}

.model-select {
  width: 100%;
  padding: 10px 36px 10px 12px;
  font-size: 14px;
  font-family: inherit;
  color: var(--color-text-secondary);
  background: var(--color-surface-base);
  border: 1.5px solid var(--color-surface-border);
  border-radius: 4px 12px 6px 10px / 10px 6px 12px 4px;
  cursor: pointer;
  appearance: none;
  transition: all 0.2s ease;
}

.model-select:hover {
  border-color: var(--color-surface-border);
}

.model-select:focus {
  outline: none;
  border-color: var(--color-ochre);
  box-shadow: 0 0 0 3px rgba(201, 162, 39, 0.15);
}

.select-arrow {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  width: 16px;
  height: 16px;
  color: var(--color-text-secondary);
  pointer-events: none;
}
</style>
