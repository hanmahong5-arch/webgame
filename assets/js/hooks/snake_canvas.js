import { GameAudio } from "./game_audio"

const SnakeCanvas = {
  mounted() {
    this.canvas = this.el
    this.ctx = this.canvas.getContext("2d")
    this.state = null
    this.playerId = this.el.dataset.playerId
    this.raf = null
    this.audio = new GameAudio()

    // Sizing
    this._onResize = () => this.resize()
    window.addEventListener("resize", this._onResize)
    this.resize()

    // Keyboard
    this._onKey = (e) => this.onKey(e)
    window.addEventListener("keydown", this._onKey)

    // Touch (swipe)
    let tx = 0, ty = 0
    this.canvas.addEventListener("touchstart", (e) => {
      tx = e.touches[0].clientX
      ty = e.touches[0].clientY
    }, { passive: true })
    this.canvas.addEventListener("touchend", (e) => {
      const dx = e.changedTouches[0].clientX - tx
      const dy = e.changedTouches[0].clientY - ty
      if (Math.abs(dx) < 30 && Math.abs(dy) < 30) return
      if (Math.abs(dx) > Math.abs(dy)) {
        this.pushEvent("input", { direction: dx > 0 ? "right" : "left" })
      } else {
        this.pushEvent("input", { direction: dy > 0 ? "down" : "up" })
      }
    }, { passive: true })

    // Listen for state pushes from server
    this.handleEvent("game_state", (s) => this.onState(s))

    // Start render loop
    this.loop()
  },

  destroyed() {
    window.removeEventListener("resize", this._onResize)
    window.removeEventListener("keydown", this._onKey)
    if (this.raf) cancelAnimationFrame(this.raf)
  },

  resize() {
    const p = this.el.parentElement
    if (!p) return
    this.canvas.width = p.clientWidth
    this.canvas.height = p.clientHeight
  },

  onKey(e) {
    const map = {
      ArrowUp: "up", ArrowDown: "down", ArrowLeft: "left", ArrowRight: "right",
      w: "up", s: "down", a: "left", d: "right",
      W: "up", S: "down", A: "left", D: "right"
    }
    const dir = map[e.key]
    if (dir) {
      e.preventDefault()
      // Auto-respawn on arrow key if dead
      const me = this.state && this.state.players && this.state.players[this.playerId]
      if (me && !me.alive) {
        this.pushEvent("respawn", {})
      }
      this.pushEvent("input", { direction: dir })
    }
  },

  onState(state) {
    this.state = state

    // Play sounds for events
    if (state.events) {
      for (const ev of state.events) {
        switch (ev[0]) {
          case "food_eaten":
            this.audio.play("eat", ev[2] === "golden")
            break
          case "player_died":
            this.audio.play("die", ev[1] === this.playerId)
            break
          case "game_started":
            this.audio.play("start")
            break
          case "countdown":
            this.audio.play("beep")
            break
          case "game_over":
            this.audio.play("gameover")
            break
        }
      }
    }
  },

  loop() {
    this.draw()
    this.raf = requestAnimationFrame(() => this.loop())
  },

  draw() {
    const { ctx, canvas, state } = this
    if (!state) {
      ctx.fillStyle = "#060610"
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.fillStyle = "#55556A"
      ctx.font = "18px sans-serif"
      ctx.textAlign = "center"
      ctx.fillText("Connecting...", canvas.width / 2, canvas.height / 2)
      return
    }

    const [cols, rows] = state.grid
    const cs = Math.min(
      Math.floor((canvas.width - 20) / cols),
      Math.floor((canvas.height - 20) / rows)
    )
    const ox = Math.floor((canvas.width - cols * cs) / 2)
    const oy = Math.floor((canvas.height - rows * cs) / 2)

    // Background
    ctx.fillStyle = "#060610"
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    // Grid area
    ctx.fillStyle = "#0A0A18"
    ctx.fillRect(ox, oy, cols * cs, rows * cs)

    // Grid lines
    ctx.strokeStyle = "rgba(255,255,255,0.02)"
    ctx.lineWidth = 1
    for (let x = 0; x <= cols; x++) {
      ctx.beginPath()
      ctx.moveTo(ox + x * cs, oy)
      ctx.lineTo(ox + x * cs, oy + rows * cs)
      ctx.stroke()
    }
    for (let y = 0; y <= rows; y++) {
      ctx.beginPath()
      ctx.moveTo(ox, oy + y * cs)
      ctx.lineTo(ox + cols * cs, oy + y * cs)
      ctx.stroke()
    }

    // Grid border
    ctx.strokeStyle = "rgba(0,240,255,0.12)"
    ctx.lineWidth = 2
    ctx.strokeRect(ox, oy, cols * cs, rows * cs)

    // Food
    for (const [fx, fy, type] of state.food) {
      const cx = ox + fx * cs + cs / 2
      const cy = oy + fy * cs + cs / 2
      const r = cs * 0.3
      const color = type === "golden" ? "#FFB800" : "#FF4466"

      ctx.save()
      ctx.shadowColor = color
      ctx.shadowBlur = cs * 0.8
      ctx.fillStyle = color
      ctx.beginPath()
      ctx.arc(cx, cy, r, 0, Math.PI * 2)
      ctx.fill()
      ctx.restore()

      // Inner highlight
      ctx.fillStyle = "#fff"
      ctx.globalAlpha = 0.35
      ctx.beginPath()
      ctx.arc(cx - r * 0.2, cy - r * 0.2, r * 0.3, 0, Math.PI * 2)
      ctx.fill()
      ctx.globalAlpha = 1
    }

    // Snakes
    for (const [id, p] of Object.entries(state.players)) {
      if (p.segments.length === 0) continue
      const alive = p.alive
      const isMe = id === this.playerId

      // Body segments (draw tail first, head last)
      for (let i = p.segments.length - 1; i >= 0; i--) {
        const [sx, sy] = p.segments[i]
        const x = ox + sx * cs
        const y = oy + sy * cs
        const pad = cs * 0.08
        const fade = 0.35 + 0.65 * (1 - i / Math.max(p.segments.length, 1))

        ctx.globalAlpha = alive ? fade : fade * 0.2
        ctx.fillStyle = p.color

        const r = cs * 0.2
        if (ctx.roundRect) {
          ctx.beginPath()
          ctx.roundRect(x + pad, y + pad, cs - pad * 2, cs - pad * 2, r)
          ctx.fill()
        } else {
          ctx.fillRect(x + pad, y + pad, cs - pad * 2, cs - pad * 2)
        }
      }

      // Head (glow for own snake)
      const [hx, hy] = p.segments[0]
      const headX = ox + hx * cs
      const headY = oy + hy * cs

      ctx.globalAlpha = alive ? 1 : 0.25
      if (isMe && alive) {
        ctx.save()
        ctx.shadowColor = p.color
        ctx.shadowBlur = cs * 0.7
      }
      ctx.fillStyle = p.color
      const hr = cs * 0.22
      if (ctx.roundRect) {
        ctx.beginPath()
        ctx.roundRect(headX + 1, headY + 1, cs - 2, cs - 2, hr)
        ctx.fill()
      } else {
        ctx.fillRect(headX + 1, headY + 1, cs - 2, cs - 2)
      }
      if (isMe && alive) ctx.restore()

      // Eyes
      if (alive) {
        ctx.fillStyle = "#000"
        const es = cs * 0.11
        let e1x, e1y, e2x, e2y
        const d = p.direction
        if (d === "right") { e1x = 0.65; e1y = 0.28; e2x = 0.65; e2y = 0.72 }
        else if (d === "left") { e1x = 0.35; e1y = 0.28; e2x = 0.35; e2y = 0.72 }
        else if (d === "up") { e1x = 0.28; e1y = 0.35; e2x = 0.72; e2y = 0.35 }
        else { e1x = 0.28; e1y = 0.65; e2x = 0.72; e2y = 0.65 }

        ctx.globalAlpha = alive ? 0.9 : 0.2
        ctx.beginPath()
        ctx.arc(headX + cs * e1x, headY + cs * e1y, es, 0, Math.PI * 2)
        ctx.fill()
        ctx.beginPath()
        ctx.arc(headX + cs * e2x, headY + cs * e2y, es, 0, Math.PI * 2)
        ctx.fill()
      }

      // Name label
      ctx.globalAlpha = alive ? 0.85 : 0.25
      ctx.fillStyle = "#fff"
      ctx.font = `bold ${Math.max(9, cs * 0.6)}px sans-serif`
      ctx.textAlign = "center"
      ctx.fillText(p.name, headX + cs / 2, headY - cs * 0.25)

      ctx.globalAlpha = 1
    }

    // Countdown overlay
    if (state.status === "countdown" && state.countdown > 0) {
      ctx.fillStyle = "rgba(6,6,16,0.6)"
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.fillStyle = "#00F0FF"
      ctx.font = `bold ${Math.min(canvas.width, canvas.height) * 0.2}px sans-serif`
      ctx.textAlign = "center"
      ctx.textBaseline = "middle"
      ctx.fillText(state.countdown, canvas.width / 2, canvas.height / 2)
      ctx.textBaseline = "alphabetic"
    }
  }
}

export default SnakeCanvas
