import { GameAudio } from "./game_audio"

const POWERUP_COLORS = {
  speed: "#00F0FF",
  blade: "#FF4466",
  shield: "#00FF87",
  magnet: "#FFB800",
  star: "#E6DB74"
}

const POWERUP_ICONS = {
  speed: "\u26A1",   // lightning
  blade: "\u2694",   // swords
  shield: "\uD83D\uDEE1", // shield
  magnet: "\uD83E\uDDF2", // magnet
  star: "\u2B50"     // star
}

const SnakeCanvas = {
  mounted() {
    this.canvas = this.el
    this.ctx = this.canvas.getContext("2d")
    this.state = null
    this.playerId = this.el.dataset.playerId
    this.raf = null
    this.audio = new GameAudio()
    this.particles = []
    this.shakeAmount = 0
    this.shakeDecay = 0.92

    this._onResize = () => this.resize()
    window.addEventListener("resize", this._onResize)
    this.resize()

    this._onKey = (e) => this.onKey(e)
    window.addEventListener("keydown", this._onKey)

    let tx = 0, ty = 0
    this.canvas.addEventListener("touchstart", (e) => {
      tx = e.touches[0].clientX; ty = e.touches[0].clientY
    }, { passive: true })
    this.canvas.addEventListener("touchend", (e) => {
      const dx = e.changedTouches[0].clientX - tx
      const dy = e.changedTouches[0].clientY - ty
      if (Math.abs(dx) < 30 && Math.abs(dy) < 30) return
      const me = this.state?.players?.[this.playerId]
      if (me && !me.alive) this.pushEvent("respawn", {})
      if (Math.abs(dx) > Math.abs(dy))
        this.pushEvent("input", { direction: dx > 0 ? "right" : "left" })
      else
        this.pushEvent("input", { direction: dy > 0 ? "down" : "up" })
    }, { passive: true })

    this.handleEvent("game_state", (s) => this.onState(s))
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
      const me = this.state?.players?.[this.playerId]
      if (me && !me.alive) this.pushEvent("respawn", {})
      this.pushEvent("input", { direction: dir })
    }
  },

  onState(state) {
    this.state = state
    if (state.events) {
      for (const ev of state.events) {
        switch (ev[0]) {
          case "food_eaten":
            this.audio.play("eat", ev[2] === "golden")
            break
          case "player_died": {
            const isSelf = ev[1] === this.playerId
            this.audio.play("die", isSelf)
            if (isSelf) this.shakeAmount = 12
            // Spawn death particles
            const deadP = this.state?.players?.[ev[1]]
            if (deadP?.segments?.length) {
              const [dx, dy] = deadP.segments[0]
              for (let i = 0; i < 20; i++) {
                this.particles.push({
                  x: dx, y: dy,
                  vx: (Math.random() - 0.5) * 3,
                  vy: (Math.random() - 0.5) * 3,
                  life: 30 + Math.random() * 20,
                  color: deadP.color,
                  size: 0.3 + Math.random() * 0.4
                })
              }
            }
            break
          }
          case "game_started": this.audio.play("start"); break
          case "powerup":
            this.audio.play("powerup")
            break
          case "blade_cut":
            this.audio.play("blade")
            this.shakeAmount = 6
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
    let ox = Math.floor((canvas.width - cols * cs) / 2)
    let oy = Math.floor((canvas.height - rows * cs) / 2)

    // Screen shake
    if (this.shakeAmount > 0.5) {
      ox += (Math.random() - 0.5) * this.shakeAmount
      oy += (Math.random() - 0.5) * this.shakeAmount
      this.shakeAmount *= this.shakeDecay
    } else {
      this.shakeAmount = 0
    }

    // Background
    ctx.fillStyle = "#060610"
    ctx.fillRect(0, 0, canvas.width, canvas.height)
    ctx.fillStyle = "#0A0A18"
    ctx.fillRect(ox, oy, cols * cs, rows * cs)

    // Grid lines
    ctx.strokeStyle = "rgba(255,255,255,0.02)"
    ctx.lineWidth = 1
    for (let x = 0; x <= cols; x++) {
      ctx.beginPath(); ctx.moveTo(ox + x * cs, oy); ctx.lineTo(ox + x * cs, oy + rows * cs); ctx.stroke()
    }
    for (let y = 0; y <= rows; y++) {
      ctx.beginPath(); ctx.moveTo(ox, oy + y * cs); ctx.lineTo(ox + cols * cs, oy + y * cs); ctx.stroke()
    }
    ctx.strokeStyle = "rgba(0,240,255,0.1)"
    ctx.lineWidth = 2
    ctx.strokeRect(ox, oy, cols * cs, rows * cs)

    // Food
    for (const [fx, fy, type] of state.food) {
      const cx = ox + fx * cs + cs / 2, cy = oy + fy * cs + cs / 2
      const r = cs * 0.28
      const color = type === "golden" ? "#FFB800" : "#FF4466"
      ctx.save()
      ctx.shadowColor = color
      ctx.shadowBlur = cs * 0.6
      ctx.fillStyle = color
      ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2); ctx.fill()
      ctx.restore()
    }

    // Powerups
    if (state.powerups) {
      const t = Date.now() / 1000
      for (const [px, py, type] of state.powerups) {
        const cx = ox + px * cs + cs / 2, cy = oy + py * cs + cs / 2
        const color = POWERUP_COLORS[type] || "#fff"
        const pulse = 0.8 + 0.2 * Math.sin(t * 4)

        ctx.save()
        ctx.shadowColor = color
        ctx.shadowBlur = cs * 1.2 * pulse
        ctx.fillStyle = color
        ctx.globalAlpha = 0.25
        ctx.beginPath(); ctx.arc(cx, cy, cs * 0.45, 0, Math.PI * 2); ctx.fill()
        ctx.globalAlpha = 1
        ctx.fillStyle = color
        ctx.beginPath(); ctx.arc(cx, cy, cs * 0.3, 0, Math.PI * 2); ctx.fill()
        ctx.restore()

        // Icon
        ctx.fillStyle = "#000"
        ctx.font = `${cs * 0.4}px sans-serif`
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        ctx.fillText(POWERUP_ICONS[type] || "?", cx, cy)
        ctx.textBaseline = "alphabetic"
      }
    }

    // Snakes
    for (const [id, p] of Object.entries(state.players)) {
      if (p.segments.length === 0) continue
      const alive = p.alive
      const isMe = id === this.playerId
      const hasSpeed = p.effects?.includes("speed")
      const hasBlade = p.effects?.includes("blade")
      const hasShield = p.has_shield
      const hasStar = p.effects?.includes("star")

      // Body
      for (let i = p.segments.length - 1; i >= 0; i--) {
        const [sx, sy] = p.segments[i]
        const x = ox + sx * cs, y = oy + sy * cs
        const pad = cs * 0.08
        const fade = 0.35 + 0.65 * (1 - i / Math.max(p.segments.length, 1))

        ctx.globalAlpha = alive ? fade : fade * 0.15
        ctx.fillStyle = p.color

        const r = cs * 0.18
        if (ctx.roundRect) {
          ctx.beginPath()
          ctx.roundRect(x + pad, y + pad, cs - pad * 2, cs - pad * 2, r)
          ctx.fill()
        } else {
          ctx.fillRect(x + pad, y + pad, cs - pad * 2, cs - pad * 2)
        }
      }

      // Head
      const [hx, hy] = p.segments[0]
      const headX = ox + hx * cs, headY = oy + hy * cs

      ctx.globalAlpha = alive ? 1 : 0.2
      if (alive) {
        ctx.save()
        let glowColor = p.color
        if (hasStar) glowColor = "#E6DB74"
        if (hasBlade) glowColor = "#FF4466"
        if (hasSpeed) glowColor = "#00F0FF"
        ctx.shadowColor = glowColor
        ctx.shadowBlur = cs * (isMe ? 0.9 : 0.5)
      }
      ctx.fillStyle = p.color
      if (ctx.roundRect) {
        ctx.beginPath()
        ctx.roundRect(headX + 1, headY + 1, cs - 2, cs - 2, cs * 0.22)
        ctx.fill()
      } else {
        ctx.fillRect(headX + 1, headY + 1, cs - 2, cs - 2)
      }
      if (alive) ctx.restore()

      // Shield indicator
      if (hasShield && alive) {
        ctx.strokeStyle = "#00FF87"
        ctx.lineWidth = 2
        ctx.globalAlpha = 0.6 + 0.3 * Math.sin(Date.now() / 200)
        ctx.beginPath()
        ctx.arc(headX + cs / 2, headY + cs / 2, cs * 0.6, 0, Math.PI * 2)
        ctx.stroke()
        ctx.globalAlpha = 1
      }

      // Eyes
      if (alive) {
        ctx.fillStyle = "#000"
        const es = cs * 0.1
        const d = p.direction
        let e1x, e1y, e2x, e2y
        if (d === "right") { e1x = 0.65; e1y = 0.28; e2x = 0.65; e2y = 0.72 }
        else if (d === "left") { e1x = 0.35; e1y = 0.28; e2x = 0.35; e2y = 0.72 }
        else if (d === "up") { e1x = 0.28; e1y = 0.35; e2x = 0.72; e2y = 0.35 }
        else { e1x = 0.28; e1y = 0.65; e2x = 0.72; e2y = 0.65 }
        ctx.beginPath()
        ctx.arc(headX + cs * e1x, headY + cs * e1y, es, 0, Math.PI * 2)
        ctx.fill()
        ctx.beginPath()
        ctx.arc(headX + cs * e2x, headY + cs * e2y, es, 0, Math.PI * 2)
        ctx.fill()
      }

      // Name + effects
      ctx.globalAlpha = alive ? 0.85 : 0.2
      ctx.fillStyle = "#fff"
      ctx.font = `bold ${Math.max(9, cs * 0.55)}px sans-serif`
      ctx.textAlign = "center"
      let label = p.name
      if (hasSpeed) label += " \u26A1"
      if (hasBlade) label += " \u2694"
      if (hasStar) label += " \u2B50"
      ctx.fillText(label, headX + cs / 2, headY - cs * 0.25)
      ctx.globalAlpha = 1
    }

    // Particles
    this.particles = this.particles.filter(p => {
      p.x += p.vx
      p.y += p.vy
      p.vy += 0.03
      p.life--
      if (p.life <= 0) return false

      const px = ox + p.x * cs + cs / 2
      const py = oy + p.y * cs + cs / 2
      const alpha = Math.min(1, p.life / 15)
      ctx.globalAlpha = alpha
      ctx.fillStyle = p.color
      ctx.shadowColor = p.color
      ctx.shadowBlur = cs * 0.4
      ctx.beginPath()
      ctx.arc(px, py, cs * p.size, 0, Math.PI * 2)
      ctx.fill()
      ctx.shadowBlur = 0
      ctx.globalAlpha = 1
      return true
    })

    // Leaderboard (top-left, inside grid)
    if (state.leaderboard && state.leaderboard.length > 0) {
      const lx = ox + 8, ly = oy + 8
      ctx.fillStyle = "rgba(6,6,16,0.7)"
      const lh = Math.min(state.leaderboard.length, 5) * 18 + 24
      if (ctx.roundRect) {
        ctx.beginPath(); ctx.roundRect(lx, ly, 140, lh, 6); ctx.fill()
      } else {
        ctx.fillRect(lx, ly, 140, lh)
      }

      ctx.fillStyle = "#55556A"
      ctx.font = "bold 9px sans-serif"
      ctx.textAlign = "left"
      ctx.fillText("LEADERBOARD", lx + 8, ly + 14)

      state.leaderboard.slice(0, 5).forEach((entry, i) => {
        const ey = ly + 26 + i * 18
        ctx.fillStyle = entry.color
        ctx.fillRect(lx + 8, ey - 4, 4, 4)
        ctx.fillStyle = entry.id === this.playerId ? "#fff" : "#9090A8"
        ctx.font = `${entry.id === this.playerId ? "bold " : ""}10px sans-serif`
        ctx.fillText(entry.name, lx + 18, ey)
        ctx.fillStyle = "#00F0FF"
        ctx.textAlign = "right"
        ctx.fillText(entry.total_score, lx + 132, ey)
        ctx.textAlign = "left"
      })
    }
  }
}

export default SnakeCanvas
