<script setup lang="ts">
/**
 * GlobalToast — Renders the toast notification stack
 * Mounted once in App.vue, receives from useToast singleton
 */
import { useToast } from '../../composables/useToast'
import type { ToastType } from '../../composables/useToast'

const { toasts, dismiss } = useToast()

function handleAction(toast: { id: number; action?: { handler: () => void } }) {
  dismiss(toast.id)
  try {
    const result = toast.action?.handler()
    // Catch async handler rejections to prevent unhandled promise errors
    if (result && typeof (result as Promise<unknown>).catch === 'function') {
      (result as Promise<unknown>).catch(() => {})
    }
  } catch {
    // Sync handler errors — toast already dismissed
  }
}

const iconMap: Record<ToastType, string> = {
  info: 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z',
  success: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
  warning: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z',
  error: 'M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z',
}
</script>

<template>
  <Teleport to="body">
    <div
      class="toast-container"
      role="region"
      aria-label="通知"
      aria-live="polite"
    >
      <TransitionGroup name="toast">
        <div
          v-for="toast in toasts"
          :key="toast.id"
          class="toast"
          :class="`toast--${toast.type}`"
          role="alert"
        >
          <svg class="toast-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <path
              :d="iconMap[toast.type]"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>

          <div class="toast-body">
            <p class="toast-title">{{ toast.title }}</p>
            <p v-if="toast.message" class="toast-message">{{ toast.message }}</p>
            <button
              v-if="toast.action"
              class="toast-action"
              @click="handleAction(toast)"
            >
              {{ toast.action.label }}
            </button>
          </div>

          <button
            class="toast-close"
            :aria-label="`关闭通知：${toast.title}`"
            @click="dismiss(toast.id)"
          >
            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path d="M6 18L18 6M6 6l12 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
            </svg>
          </button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<style scoped>
.toast-container {
  position: fixed;
  top: 76px; /* below TopBar (64px) + gap */
  right: 16px;
  z-index: 100;
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-width: 400px;
  width: calc(100vw - 32px);
  pointer-events: none;
}

.toast {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 12px 14px;
  border-radius: 10px;
  border: 1px solid;
  backdrop-filter: blur(12px);
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.3);
  pointer-events: auto;
}

.toast--info {
  background: rgba(30, 58, 95, 0.92);
  border-color: rgba(74, 158, 255, 0.3);
}

.toast--success {
  background: rgba(22, 63, 40, 0.92);
  border-color: rgba(74, 222, 128, 0.3);
}

.toast--warning {
  background: rgba(80, 60, 15, 0.92);
  border-color: rgba(201, 162, 39, 0.4);
}

.toast--error {
  background: rgba(80, 20, 20, 0.92);
  border-color: rgba(239, 68, 68, 0.4);
}

.toast-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
  margin-top: 1px;
}

.toast--info .toast-icon { color: #60a5fa; }
.toast--success .toast-icon { color: #4ade80; }
.toast--warning .toast-icon { color: #c9a227; }
.toast--error .toast-icon { color: #f87171; }

.toast-body {
  flex: 1;
  min-width: 0;
}

.toast-title {
  margin: 0;
  font-size: 13px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.95);
  line-height: 1.4;
}

.toast-message {
  margin: 3px 0 0;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.7);
  line-height: 1.4;
}

.toast-action {
  display: inline-block;
  margin-top: 6px;
  padding: 0;
  border: none;
  background: none;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  text-decoration: underline;
  text-underline-offset: 2px;
}

.toast--info .toast-action { color: #93bbfc; }
.toast--success .toast-action { color: #86efac; }
.toast--warning .toast-action { color: #e0c65e; }
.toast--error .toast-action { color: #fca5a5; }

.toast-action:hover {
  opacity: 0.8;
}

.toast-close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  padding: 0;
  border: none;
  background: none;
  color: rgba(255, 255, 255, 0.4);
  cursor: pointer;
  border-radius: 4px;
  flex-shrink: 0;
  transition: color 0.15s, background 0.15s;
}

.toast-close:hover {
  color: rgba(255, 255, 255, 0.8);
  background: rgba(255, 255, 255, 0.1);
}

.toast-close svg {
  width: 14px;
  height: 14px;
}

/* Transition */
.toast-enter-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.toast-leave-active {
  transition: all 0.2s ease-in;
}

.toast-enter-from {
  opacity: 0;
  transform: translateX(40px);
}

.toast-leave-to {
  opacity: 0;
  transform: translateX(40px) scale(0.95);
}

.toast-move {
  transition: transform 0.3s ease;
}

@media (prefers-reduced-motion: reduce) {
  .toast-enter-active,
  .toast-leave-active,
  .toast-move {
    transition: none;
  }
}

@media (max-width: 640px) {
  .toast-container {
    right: 8px;
    left: 8px;
    max-width: none;
    width: auto;
  }
}
</style>
