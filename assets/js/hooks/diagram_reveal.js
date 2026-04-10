// IntersectionObserver hook: sets data-visible="true" when element enters viewport
const DiagramReveal = {
  mounted() {
    this._observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          this.el.setAttribute("data-visible", "true")
          this._observer.disconnect()
          this._observer = null
        }
      },
      { threshold: 0.25 }
    )
    this._observer.observe(this.el)
  },
  destroyed() {
    if (this._observer) {
      this._observer.disconnect()
      this._observer = null
    }
  }
}

export default DiagramReveal
