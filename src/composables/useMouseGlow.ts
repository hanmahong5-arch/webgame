import { onMounted, onUnmounted, type Ref } from 'vue'

/**
 * Adds a radial gradient glow that follows the mouse cursor.
 * Desktop only, respects prefers-reduced-motion.
 */
export function useMouseGlow(
  containerRef: Ref<HTMLElement | null>,
  color = 'rgba(212, 168, 39, 0.06)',
  size = 600
) {
  let animFrame = 0
  let mouseX = 0
  let mouseY = 0
  let currentX = 0
  let currentY = 0
  let active = false

  const prefersReducedMotion =
    typeof window !== 'undefined' &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches

  const isTouch =
    typeof window !== 'undefined' &&
    ('ontouchstart' in window || navigator.maxTouchPoints > 0)

  const lerp = (a: number, b: number, t: number) => a + (b - a) * t

  const tick = () => {
    if (!active || !containerRef.value) {
      animFrame = 0
      return
    }
    currentX = lerp(currentX, mouseX, 0.08)
    currentY = lerp(currentY, mouseY, 0.08)
    const el = containerRef.value
    el.style.setProperty('--glow-x', `${currentX}px`)
    el.style.setProperty('--glow-y', `${currentY}px`)
    el.style.setProperty('--glow-opacity', '1')
    animFrame = requestAnimationFrame(tick)
  }

  const startLoop = () => {
    if (!animFrame) {
      animFrame = requestAnimationFrame(tick)
    }
  }

  const onMouseMove = (e: MouseEvent) => {
    const el = containerRef.value
    if (!el) return
    const rect = el.getBoundingClientRect()
    mouseX = e.clientX - rect.left
    mouseY = e.clientY - rect.top
    if (!active) {
      active = true
      currentX = mouseX
      currentY = mouseY
      startLoop()
    }
  }

  const onMouseLeave = () => {
    active = false
    const el = containerRef.value
    if (el) {
      el.style.removeProperty('--glow-x')
      el.style.removeProperty('--glow-y')
      el.style.removeProperty('--glow-opacity')
    }
  }

  onMounted(() => {
    if (prefersReducedMotion || isTouch) return
    const el = containerRef.value
    if (!el) return

    el.style.setProperty('--glow-color', color)
    el.style.setProperty('--glow-size', `${size}px`)
    el.style.setProperty('--glow-opacity', '0')

    el.addEventListener('mousemove', onMouseMove, { passive: true })
    el.addEventListener('mouseleave', onMouseLeave)
  })

  onUnmounted(() => {
    const el = containerRef.value
    if (el) {
      el.removeEventListener('mousemove', onMouseMove)
      el.removeEventListener('mouseleave', onMouseLeave)
    }
    if (animFrame) cancelAnimationFrame(animFrame)
  })
}
