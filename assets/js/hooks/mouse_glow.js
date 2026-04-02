// Mouse-following glow effect for hero sections
const MouseGlow = {
  mounted() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.glow = document.createElement("div")
    this.glow.style.cssText = `
      position: absolute;
      width: 400px;
      height: 400px;
      border-radius: 50%;
      background: radial-gradient(circle, rgba(212, 168, 39, 0.08), transparent 70%);
      pointer-events: none;
      transform: translate(-50%, -50%);
      transition: opacity 0.3s ease;
      opacity: 0;
      z-index: 0;
    `

    this.el.style.position = "relative"
    this.el.style.overflow = "hidden"
    this.el.appendChild(this.glow)

    this.onMove = (e) => {
      const rect = this.el.getBoundingClientRect()
      this.glow.style.left = (e.clientX - rect.left) + "px"
      this.glow.style.top = (e.clientY - rect.top) + "px"
      this.glow.style.opacity = "1"
    }

    this.onLeave = () => {
      this.glow.style.opacity = "0"
    }

    this.el.addEventListener("mousemove", this.onMove)
    this.el.addEventListener("mouseleave", this.onLeave)
  },

  destroyed() {
    if (this.onMove) {
      this.el.removeEventListener("mousemove", this.onMove)
      this.el.removeEventListener("mouseleave", this.onLeave)
    }
    if (this.glow && this.glow.parentNode) {
      this.glow.parentNode.removeChild(this.glow)
    }
  }
}

export default MouseGlow
