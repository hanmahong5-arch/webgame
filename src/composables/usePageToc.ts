/**
 * Page TOC active anchor tracking
 * Uses IntersectionObserver to detect which section is currently in viewport
 */

import { ref, onMounted, onUnmounted, watch, type Ref } from 'vue'

const NAVBAR_HEIGHT = 80
const RATIO_THRESHOLDS = [0, 0.1, 0.2, 0.3, 0.4, 0.5]
const MIN_VISIBLE_RATIO = 0.05

export function usePageToc(anchors: Ref<string[]>) {
  const activeAnchor = ref('')
  const sectionRatios = new Map<string, number>()
  let observer: IntersectionObserver | null = null

  function updateActive() {
    let maxRatio = 0
    let maxAnchor = ''

    sectionRatios.forEach((ratio, id) => {
      if (ratio > maxRatio) {
        maxRatio = ratio
        maxAnchor = id
      }
    })

    activeAnchor.value = maxRatio > MIN_VISIBLE_RATIO ? maxAnchor : ''
  }

  function observe() {
    disconnect()
    sectionRatios.clear()

    observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          sectionRatios.set(entry.target.id, entry.intersectionRatio)
        }
        updateActive()
      },
      {
        threshold: RATIO_THRESHOLDS,
        rootMargin: `-${NAVBAR_HEIGHT}px 0px 0px 0px`,
      },
    )

    for (const anchor of anchors.value) {
      const el = document.getElementById(anchor)
      if (el) observer.observe(el)
    }
  }

  function disconnect() {
    observer?.disconnect()
    observer = null
  }

  onMounted(() => {
    observe()
  })

  watch(anchors, () => {
    observe()
  })

  onUnmounted(() => {
    disconnect()
  })

  return { activeAnchor }
}
