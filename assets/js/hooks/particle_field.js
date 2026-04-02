// Canvas-based particle field background effect
const ParticleField = {
  mounted() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.canvas = this.el.querySelector("canvas") || this.createCanvas()
    this.ctx = this.canvas.getContext("2d")
    this.particles = []
    this.animId = null

    this.resize()
    this.initParticles()
    this.animate()

    this._onResize = () => this.resize()
    window.addEventListener("resize", this._onResize, { passive: true })
  },

  createCanvas() {
    const canvas = document.createElement("canvas")
    canvas.style.cssText = "position:absolute; inset:0; width:100%; height:100%; pointer-events:none; z-index:0;"
    this.el.style.position = "relative"
    this.el.insertBefore(canvas, this.el.firstChild)
    return canvas
  },

  resize() {
    const rect = this.el.getBoundingClientRect()
    this.canvas.width = rect.width
    this.canvas.height = rect.height
  },

  initParticles() {
    const count = Math.min(Math.floor(this.canvas.width / 20), 40)
    this.particles = Array.from({ length: count }, () => ({
      x: Math.random() * this.canvas.width,
      y: Math.random() * this.canvas.height,
      vx: (Math.random() - 0.5) * 0.3,
      vy: -Math.random() * 0.4 - 0.1,
      size: Math.random() * 2 + 0.5,
      alpha: Math.random() * 0.5 + 0.1
    }))
  },

  animate() {
    const { ctx, canvas, particles } = this
    ctx.clearRect(0, 0, canvas.width, canvas.height)

    for (const p of particles) {
      p.x += p.vx
      p.y += p.vy
      p.alpha -= 0.001

      if (p.y < -10 || p.alpha <= 0) {
        p.x = Math.random() * canvas.width
        p.y = canvas.height + 10
        p.alpha = Math.random() * 0.5 + 0.1
      }

      ctx.beginPath()
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2)
      ctx.fillStyle = `rgba(212, 168, 39, ${p.alpha})`
      ctx.fill()
    }

    this.animId = requestAnimationFrame(() => this.animate())
  },

  destroyed() {
    if (this.animId) cancelAnimationFrame(this.animId)
    if (this._onResize) window.removeEventListener("resize", this._onResize)
  }
}

export default ParticleField
