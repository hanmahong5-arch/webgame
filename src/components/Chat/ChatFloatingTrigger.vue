<script setup lang="ts">
/**
 * ChatFloatingTrigger - Floating action button for opening AI Chat panel.
 * Appears at bottom-right when the Hero section leaves the viewport.
 * Uses IntersectionObserver for efficient visibility detection.
 */

import { ref, onMounted, onUnmounted } from 'vue'
import { parseDropData, buildAnalysisPrompt, hasPortalData } from '../../utils/portalDrag'

/** Hero section selector used by IntersectionObserver */
const HERO_SELECTOR = '[aria-label="Hero"]'

interface Props {
  isOpen: boolean
  ariaLabel?: string
}

const props = defineProps<Props>()

/** Default aria label when not provided */
const DEFAULT_ARIA_LABEL = '打开 AI 对话'

const emit = defineEmits<{
  toggle: []
}>()

/** Whether the Hero section is currently visible in viewport */
const isHeroVisible = ref(true)

/** IntersectionObserver instance for cleanup */
let observer: IntersectionObserver | null = null

/**
 * Initialize IntersectionObserver to watch the Hero section.
 * When Hero is visible, hide the trigger. When Hero leaves viewport, show it.
 */
const initObserver = () => {
  const heroEl = document.querySelector(HERO_SELECTOR)

  if (!heroEl) {
    // Fallback: if Hero not found, always show the trigger
    isHeroVisible.value = false
    return
  }

  observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        isHeroVisible.value = entry.isIntersecting
      }
    },
    { threshold: [0] }
  )

  observer.observe(heroEl)
}

/** Clean up IntersectionObserver on unmount */
const cleanupObserver = () => {
  if (observer) {
    observer.disconnect()
    observer = null
  }
}

const handleClick = () => {
  emit('toggle')
}

const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Enter' || event.key === ' ') {
    event.preventDefault()
    emit('toggle')
  }
}

// Drag-drop support: drop portal link onto floating trigger to open chat + analyze
const isDragHover = ref(false)
let dragLeaveTimer: ReturnType<typeof setTimeout> | null = null

const handleTriggerDragOver = (e: DragEvent) => {
  if (!hasPortalData(e)) return
  e.preventDefault()
  e.dataTransfer!.dropEffect = 'copy'
}

const handleTriggerDragEnter = (e: DragEvent) => {
  if (!hasPortalData(e)) return
  if (dragLeaveTimer) {
    clearTimeout(dragLeaveTimer)
    dragLeaveTimer = null
  }
  isDragHover.value = true
}

const handleTriggerDragLeave = () => {
  dragLeaveTimer = setTimeout(() => {
    isDragHover.value = false
  }, 50)
}

const handleTriggerDrop = (e: DragEvent) => {
  e.preventDefault()
  isDragHover.value = false
  const data = parseDropData(e)
  if (data) {
    const prompt = buildAnalysisPrompt(data)
    window.dispatchEvent(new CustomEvent('lurus:open-chat', { detail: { prompt } }))
  }
}

onMounted(() => {
  initObserver()
})

onUnmounted(() => {
  cleanupObserver()
  if (dragLeaveTimer) {
    clearTimeout(dragLeaveTimer)
    dragLeaveTimer = null
  }
})

/** Computed visibility: show when Hero is NOT visible */
const isVisible = () => !isHeroVisible.value
</script>

<template>
  <Transition name="trigger-fade">
    <button
      v-show="isVisible()"
      class="floating-trigger"
      :class="{ 'is-open': props.isOpen, 'is-drag-hover': isDragHover }"
      :aria-label="props.isOpen ? '关闭 AI 对话' : (props.ariaLabel ?? DEFAULT_ARIA_LABEL)"
      :aria-expanded="props.isOpen"
      aria-controls="ai-chat-sidebar"
      @click="handleClick"
      @keydown="handleKeydown"
      @dragover="handleTriggerDragOver"
      @dragenter="handleTriggerDragEnter"
      @dragleave="handleTriggerDragLeave"
      @drop="handleTriggerDrop"
    >
      <!-- Chat icon (when closed) -->
      <svg
        v-if="!props.isOpen"
        class="trigger-icon"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <path
          d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>

      <!-- Close icon (when open) -->
      <svg
        v-else
        class="trigger-icon"
        viewBox="0 0 24 24"
        fill="none"
        aria-hidden="true"
      >
        <path
          d="M6 18L18 6M6 6l12 12"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
        />
      </svg>
    </button>
  </Transition>
</template>

<style scoped>
@reference "../../styles/main.css";

/* Floating trigger button */
.floating-trigger {
  position: fixed;
  right: 24px;
  bottom: 24px;
  bottom: calc(24px + env(safe-area-inset-bottom, 0px));
  z-index: 45;

  display: flex;
  align-items: center;
  justify-content: center;

  width: 56px;
  height: 56px;

  background-color: var(--color-ochre);
  color: var(--color-text-primary);
  border: 2px solid color-mix(in srgb, var(--color-ochre), #000 10%);
  border-radius: 6px 16px 10px 14px / 14px 10px 16px 6px;

  cursor: pointer;
  box-shadow: 3px 3px 0 var(--color-surface-border), 0 4px 16px rgba(201, 162, 39, 0.25);

  /* GPU-accelerated transition properties */
  transition: transform 0.3s ease, box-shadow 0.3s ease, opacity 0.3s ease;
}

/* Hover breathe effect */
.floating-trigger:hover {
  transform: scale(1.08);
  box-shadow: 5px 5px 0 var(--color-surface-border), 0 8px 24px rgba(201, 162, 39, 0.35);
}

/* Active press feedback */
.floating-trigger:active {
  transform: scale(0.95);
  transition-duration: 0.1s;
}

/* Focus ring for keyboard navigation */
.floating-trigger:focus-visible {
  outline: none;
  box-shadow: 3px 3px 0 var(--color-surface-border), 0 0 0 3px var(--color-ochre), 0 0 0 5px var(--color-surface-base);
}

/* Drag hover: enlarge + highlight when portal link is dragged over */
.floating-trigger.is-drag-hover {
  transform: scale(1.2);
  box-shadow: 0 0 0 4px rgba(201, 162, 39, 0.4), 5px 5px 0 var(--color-surface-border);
  background-color: color-mix(in srgb, var(--color-ochre), #fff 15%);
}

/* When Chat panel is open, subtle style change */
.floating-trigger.is-open {
  background-color: var(--color-surface-border);
  border-color: var(--color-text-muted);
  box-shadow: 2px 2px 0 var(--color-surface-border);
}

.floating-trigger.is-open:hover {
  background-color: var(--color-surface-raised);
  box-shadow: 3px 3px 0 var(--color-surface-border);
}

/* Icon sizing */
.trigger-icon {
  width: 24px;
  height: 24px;
}

/* Show/hide transition */
.trigger-fade-enter-active,
.trigger-fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.trigger-fade-enter-from {
  opacity: 0;
  transform: scale(0.8) translateY(8px);
}

.trigger-fade-leave-to {
  opacity: 0;
  transform: scale(0.8) translateY(8px);
}

/* Mobile: adjust position for smaller screens */
@media (max-width: 640px) {
  .floating-trigger {
    right: 16px;
    bottom: 16px;
    bottom: calc(16px + env(safe-area-inset-bottom, 0px));
    width: 52px;
    height: 52px;
  }

  .trigger-icon {
    width: 22px;
    height: 22px;
  }
}

/* Respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  .floating-trigger {
    transition: none;
  }

  .floating-trigger:hover {
    transform: none;
  }

  .floating-trigger:active {
    transform: none;
  }

  .trigger-fade-enter-active,
  .trigger-fade-leave-active {
    transition: none;
  }

  .trigger-fade-enter-from,
  .trigger-fade-leave-to {
    opacity: 1;
    transform: none;
  }
}
</style>
