/**
 * Global toast notification system
 * Module-level singleton — shared across all components
 * Provides non-blocking, auto-dismissing feedback messages
 */

import { ref, readonly } from 'vue'

export type ToastType = 'info' | 'success' | 'warning' | 'error'

export interface Toast {
  id: number
  type: ToastType
  title: string
  message?: string
  /** Primary action button */
  action?: {
    label: string
    handler: () => void
  }
  /** Auto-dismiss delay in ms (0 = persistent until manually closed) */
  duration: number
}

let nextId = 1
const toasts = ref<Toast[]>([])
const toastTimers = new Map<number, ReturnType<typeof setTimeout>>()
const MAX_TOASTS = 5

function addToast(options: Omit<Toast, 'id'>): number {
  const id = nextId++

  // Enforce max visible toasts — remove oldest
  if (toasts.value.length >= MAX_TOASTS) {
    const removed = toasts.value.shift()
    if (removed) clearToastTimer(removed.id)
  }

  toasts.value.push({ ...options, id })

  if (options.duration > 0) {
    toastTimers.set(id, setTimeout(() => dismiss(id), options.duration))
  }

  return id
}

function clearToastTimer(id: number): void {
  const timer = toastTimers.get(id)
  if (timer) {
    clearTimeout(timer)
    toastTimers.delete(id)
  }
}

function dismiss(id: number): void {
  clearToastTimer(id)
  const idx = toasts.value.findIndex(t => t.id === id)
  if (idx !== -1) {
    toasts.value.splice(idx, 1)
  }
}

function dismissAll(): void {
  for (const [id] of toastTimers) {
    clearToastTimer(id)
  }
  toasts.value.splice(0)
}

/** Convenience shortcuts */
function info(title: string, message?: string, duration = 4000): number {
  return addToast({ type: 'info', title, message, duration })
}

function success(title: string, message?: string, duration = 3000): number {
  return addToast({ type: 'success', title, message, duration })
}

function warning(title: string, message?: string, duration = 5000): number {
  return addToast({ type: 'warning', title, message, duration })
}

function error(
  title: string,
  message?: string,
  action?: Toast['action'],
  duration = 0,
): number {
  return addToast({ type: 'error', title, message, action, duration })
}

export function useToast() {
  return {
    toasts: readonly(toasts),
    addToast,
    dismiss,
    dismissAll,
    info,
    success,
    warning,
    error,
  }
}
