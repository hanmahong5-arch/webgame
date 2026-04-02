// Animated number counter
const CountUp = {
  mounted() {
    const target = this.el.dataset.target || this.el.textContent.trim()
    const duration = parseInt(this.el.dataset.duration || "1500", 10)

    // Extract numeric part
    const match = target.match(/^([<>]?)(\d+(?:\.\d+)?)(.*)$/)
    if (!match) return

    const [, prefix, numStr, suffix] = match
    const end = parseFloat(numStr)
    const isFloat = numStr.includes(".")

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            this.animate(prefix, end, suffix, duration, isFloat)
            this.observer.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.5 }
    )

    this.observer.observe(this.el)
  },

  animate(prefix, end, suffix, duration, isFloat) {
    const start = performance.now()

    const step = (now) => {
      const elapsed = now - start
      const progress = Math.min(elapsed / duration, 1)
      const eased = 1 - Math.pow(1 - progress, 3) // ease-out cubic
      const current = eased * end

      this.el.textContent = prefix + (isFloat ? current.toFixed(1) : Math.floor(current)) + suffix

      if (progress < 1) requestAnimationFrame(step)
    }

    requestAnimationFrame(step)
  },

  destroyed() {
    if (this.observer) this.observer.disconnect()
  }
}

export default CountUp
