import { ref, onMounted, onUnmounted, type Ref } from 'vue'

interface UseCountUpOptions {
  /** Duration in ms (default 1500) */
  duration?: number
  /** IntersectionObserver threshold (default 0.5) */
  threshold?: number
}

/**
 * Scroll-triggered count-up animation for numeric stat values.
 * Extracts the leading number from a string like "99.9%", "50+", "<100ms", "1M+"
 * and animates it from 0 to the target value.
 *
 * Returns the animated display string (preserving prefix/suffix).
 * Respects prefers-reduced-motion by showing the final value immediately.
 */
export function useCountUp(
  targetEl: Ref<HTMLElement | null>,
  rawValue: string,
  options: UseCountUpOptions = {}
) {
  const { duration = 1500, threshold = 0.5 } = options

  const displayValue = ref(rawValue)
  let observer: IntersectionObserver | null = null
  let animationFrame = 0

  // Parse prefix (non-numeric chars), numeric portion, and suffix
  const match = rawValue.match(/^([^0-9]*)([\d.]+)(.*)$/)
  if (!match) {
    // No numeric part found, return as-is (e.g. infinity symbol)
    return { displayValue }
  }

  const [, prefix, numStr, suffix] = match
  const targetNum = parseFloat(numStr)
  const decimals = numStr.includes('.') ? numStr.split('.')[1].length : 0

  const prefersReducedMotion =
    typeof window !== 'undefined' &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches

  const animate = () => {
    if (prefersReducedMotion) {
      displayValue.value = rawValue
      return
    }

    const startTime = performance.now()

    const step = (currentTime: number) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      // Ease-out cubic
      const eased = 1 - Math.pow(1 - progress, 3)
      const current = eased * targetNum

      displayValue.value = prefix + current.toFixed(decimals) + suffix

      if (progress < 1) {
        animationFrame = requestAnimationFrame(step)
      } else {
        displayValue.value = rawValue
      }
    }

    animationFrame = requestAnimationFrame(step)
  }

  onMounted(() => {
    if (!targetEl.value) return

    if (prefersReducedMotion) {
      displayValue.value = rawValue
      return
    }

    // Show "0" initially
    displayValue.value = prefix + (0).toFixed(decimals) + suffix

    observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          animate()
          observer?.disconnect()
        }
      },
      { threshold }
    )
    observer.observe(targetEl.value)
  })

  onUnmounted(() => {
    observer?.disconnect()
    if (animationFrame) cancelAnimationFrame(animationFrame)
  })

  return { displayValue }
}
