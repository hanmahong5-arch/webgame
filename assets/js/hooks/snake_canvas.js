import { GameAudio } from "./game_audio"

const PUP_COLORS = { speed: "#00F0FF", blade: "#FF4466", shield: "#00FF87", magnet: "#FFB800", star: "#E6DB74" }
const PUP_ICONS = { speed: "\u26A1", blade: "\u2694", shield: "\uD83D\uDEE1", magnet: "\uD83E\uDDF2", star: "\u2B50" }
const SEG_R = 6

const SnakeCanvas = {
  mounted() {
    this.canvas = this.el
    this.ctx = this.canvas.getContext("2d")
    this.state = null
    this.playerId = this.el.dataset.playerId
    this.raf = null
    this.audio = new GameAudio()
    this.particles = []
    this.cam = { x: 900, y: 600, scale: 1 }
    this.mouse = { x: 0, y: 0 }
    this.boosting = false

    this._onResize = () => this.resize()
    window.addEventListener("resize", this._onResize)
    this.resize()

    // Mouse steering (desktop)
    this.canvas.addEventListener("mousemove", (e) => {
      this.mouse.x = e.clientX
      this.mouse.y = e.clientY
      this.sendSteer()
    })
    this.canvas.addEventListener("mousedown", () => { this.setBoosting(true) })
    this.canvas.addEventListener("mouseup", () => { this.setBoosting(false) })

    // Touch steering (mobile)
    this.canvas.addEventListener("touchmove", (e) => {
      e.preventDefault()
      this.mouse.x = e.touches[0].clientX
      this.mouse.y = e.touches[0].clientY
      this.sendSteer()
    }, { passive: false })
    this.canvas.addEventListener("touchstart", (e) => {
      if (e.touches.length >= 2) this.setBoosting(true)
      this.mouse.x = e.touches[0].clientX
      this.mouse.y = e.touches[0].clientY
      this.sendSteer()
      // Respawn on touch if dead
      const me = this.state?.players?.[this.playerId]
      if (me && !me.alive) this.pushEvent("respawn", {})
    }, { passive: true })
    this.canvas.addEventListener("touchend", (e) => {
      if (e.touches.length < 2) this.setBoosting(false)
    }, { passive: true })

    // Click to respawn when dead
    this.canvas.addEventListener("click", () => {
      const me = this.state?.players?.[this.playerId]
      if (me && !me.alive) this.pushEvent("respawn", {})
    })

    // Keyboard boost (space)
    this._onKey = (e) => {
      if (e.code === "Space") {
        e.preventDefault()
        this.setBoosting(e.type === "keydown")
      }
      // Respawn on any key
      if (e.type === "keydown") {
        const me = this.state?.players?.[this.playerId]
        if (me && !me.alive) this.pushEvent("respawn", {})
      }
    }
    window.addEventListener("keydown", this._onKey)
    window.addEventListener("keyup", this._onKey)

    this.handleEvent("game_state", (s) => this.onState(s))
    this.loop()
  },

  destroyed() {
    window.removeEventListener("resize", this._onResize)
    window.removeEventListener("keydown", this._onKey)
    window.removeEventListener("keyup", this._onKey)
    if (this.raf) cancelAnimationFrame(this.raf)
  },

  resize() {
    const p = this.el.parentElement
    if (!p) return
    this.canvas.width = p.clientWidth
    this.canvas.height = p.clientHeight
  },

  sendSteer() {
    const me = this.state?.players?.[this.playerId]
    if (!me?.alive || !me.segments?.length) return

    // Convert mouse position to world angle
    const [hx, hy] = me.segments[0]
    const screenX = (hx - this.cam.x) * this.cam.scale + this.canvas.width / 2
    const screenY = (hy - this.cam.y) * this.cam.scale + this.canvas.height / 2
    const angle = Math.atan2(this.mouse.y - screenY, this.mouse.x - screenX)
    this.pushEvent("steer", { angle })
  },

  setBoosting(active) {
    if (this.boosting !== active) {
      this.boosting = active
      this.pushEvent("boost", { active })
    }
  },

  onState(state) {
    this.state = state
    if (state.events) {
      for (const ev of state.events) {
        switch (ev[0]) {
          case "food_eaten": this.audio.play("eat", ev[2] === "golden"); break
          case "player_died": {
            const isSelf = ev[1] === this.playerId
            this.audio.play("die", isSelf)
            const dp = state.players?.[ev[1]]
            if (dp?.segments?.length) {
              const [dx, dy] = dp.segments[0]
              for (let i = 0; i < 25; i++) {
                this.particles.push({
                  x: dx, y: dy,
                  vx: (Math.random() - 0.5) * 4,
                  vy: (Math.random() - 0.5) * 4,
                  life: 35 + Math.random() * 25,
                  color: dp.color, size: 3 + Math.random() * 4
                })
              }
            }
            break
          }
          case "powerup": this.audio.play("powerup"); break
          case "game_started": this.audio.play("start"); break
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

    const [W, H] = state.size
    const meRaw = state.players?.[this.playerId]
    const me = meRaw ? {
      alive: meRaw.al !== undefined ? meRaw.al : meRaw.alive,
      segments: meRaw.s || meRaw.segments,
      score: meRaw.sc !== undefined ? meRaw.sc : meRaw.score,
      boosting: meRaw.b !== undefined ? meRaw.b : meRaw.boosting,
    } : null

    // Camera follow player
    if (me?.alive && me.segments?.length) {
      const [tx, ty] = me.segments[0]
      this.cam.x += (tx - this.cam.x) * 0.1
      this.cam.y += (ty - this.cam.y) * 0.1
    }

    const scale = this.cam.scale
    const cx = canvas.width / 2
    const cy = canvas.height / 2
    const camX = this.cam.x
    const camY = this.cam.y

    const toScreen = (wx, wy) => [(wx - camX) * scale + cx, (wy - camY) * scale + cy]

    // Background
    ctx.fillStyle = "#060610"
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    // Grid
    ctx.strokeStyle = "rgba(255,255,255,0.02)"
    ctx.lineWidth = 1
    const gs = 40
    const startX = Math.floor((camX - cx / scale) / gs) * gs
    const startY = Math.floor((camY - cy / scale) / gs) * gs
    for (let gx = startX; gx < camX + cx / scale; gx += gs) {
      const [sx] = toScreen(gx, 0)
      ctx.beginPath(); ctx.moveTo(sx, 0); ctx.lineTo(sx, canvas.height); ctx.stroke()
    }
    for (let gy = startY; gy < camY + cy / scale; gy += gs) {
      const [, sy] = toScreen(0, gy)
      ctx.beginPath(); ctx.moveTo(0, sy); ctx.lineTo(canvas.width, sy); ctx.stroke()
    }

    // World border
    const [bx0, by0] = toScreen(0, 0)
    const [bx1, by1] = toScreen(W, H)
    ctx.strokeStyle = "rgba(255,68,102,0.25)"
    ctx.lineWidth = 3
    ctx.strokeRect(bx0, by0, bx1 - bx0, by1 - by0)

    // Food (format: [x, y, type] where type is 0=normal, 1=golden or string)
    for (const [fx, fy, type] of state.food) {
      const [sx, sy] = toScreen(fx, fy)
      if (sx < -20 || sx > canvas.width + 20 || sy < -20 || sy > canvas.height + 20) continue
      const golden = type === 1 || type === "golden"
      const r = (golden ? 4 : 3) * scale
      const color = golden ? "#FFB800" : "#FF4466"
      ctx.save()
      ctx.shadowColor = color
      ctx.shadowBlur = 8
      ctx.fillStyle = color
      ctx.globalAlpha = 0.8
      ctx.beginPath(); ctx.arc(sx, sy, r, 0, Math.PI * 2); ctx.fill()
      ctx.restore()
    }

    // Powerups (format: [x, y, idx] where idx maps to type)
    const PUP_NAMES = ["blade", "shield", "magnet", "star"]
    const pups = state.pups || state.powerups || []
    if (pups.length) {
      const t = Date.now() / 1000
      for (const [px, py, typeOrIdx] of pups) {
        const [sx, sy] = toScreen(px, py)
        if (sx < -30 || sx > canvas.width + 30 || sy < -30 || sy > canvas.height + 30) continue
        const type = typeof typeOrIdx === "number" ? PUP_NAMES[typeOrIdx] : typeOrIdx
        const color = PUP_COLORS[type] || "#fff"
        const pulse = 0.8 + 0.2 * Math.sin(t * 4)
        ctx.save()
        ctx.shadowColor = color
        ctx.shadowBlur = 16 * pulse
        ctx.fillStyle = color
        ctx.globalAlpha = 0.3
        ctx.beginPath(); ctx.arc(sx, sy, 14 * scale, 0, Math.PI * 2); ctx.fill()
        ctx.globalAlpha = 1
        ctx.beginPath(); ctx.arc(sx, sy, 8 * scale, 0, Math.PI * 2); ctx.fill()
        ctx.restore()
        ctx.fillStyle = "#000"
        ctx.font = `${12 * scale}px sans-serif`
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        ctx.fillText(PUP_ICONS[type] || "?", sx, sy)
        ctx.textBaseline = "alphabetic"
      }
    }

    // Snakes
    for (const [id, p] of Object.entries(state.players)) {
      // Support both full and compact payload keys
      const segs = p.s || p.segments
      const alive = p.al !== undefined ? p.al : p.alive
      const color = p.c || p.color
      const name = p.n || p.name
      const angle = p.a !== undefined ? p.a : (p.angle || 0)
      const score = p.sc !== undefined ? p.sc : (p.score || 0)
      const boosting = p.b !== undefined ? p.b : p.boosting
      const effects = p.ef || p.effects || []
      const hasShield = p.sh !== undefined ? p.sh : p.has_shield

      if (!segs?.length) continue
      const isMe = id === this.playerId
      const r = SEG_R * scale

      // Draw body as smooth path
      ctx.globalAlpha = alive ? 0.85 : 0.15
      ctx.strokeStyle = color
      ctx.lineWidth = r * 2
      ctx.lineCap = "round"
      ctx.lineJoin = "round"
      ctx.beginPath()
      for (let i = 0; i < segs.length; i++) {
        const [sx, sy] = toScreen(segs[i][0], segs[i][1])
        if (i === 0) ctx.moveTo(sx, sy)
        else ctx.lineTo(sx, sy)
      }
      ctx.stroke()

      // Head glow
      const [hx, hy] = toScreen(segs[0][0], segs[0][1])
      if (alive) {
        ctx.globalAlpha = 1
        ctx.save()
        let glowColor = color
        if (effects.includes("star")) glowColor = "#E6DB74"
        if (effects.includes("blade")) glowColor = "#FF4466"
        if (boosting) glowColor = "#00F0FF"
        ctx.shadowColor = glowColor
        ctx.shadowBlur = isMe ? 18 : 10
        ctx.fillStyle = color
        ctx.beginPath(); ctx.arc(hx, hy, r * 1.3, 0, Math.PI * 2); ctx.fill()
        ctx.restore()

        // Eyes
        ctx.fillStyle = "#fff"
        const ea = angle
        const ed = r * 0.5
        ctx.beginPath()
        ctx.arc(hx + Math.cos(ea - 0.4) * ed, hy + Math.sin(ea - 0.4) * ed, r * 0.35, 0, Math.PI * 2)
        ctx.arc(hx + Math.cos(ea + 0.4) * ed, hy + Math.sin(ea + 0.4) * ed, r * 0.35, 0, Math.PI * 2)
        ctx.fill()
        ctx.fillStyle = "#000"
        ctx.beginPath()
        ctx.arc(hx + Math.cos(ea - 0.4) * ed * 1.1, hy + Math.sin(ea - 0.4) * ed * 1.1, r * 0.18, 0, Math.PI * 2)
        ctx.arc(hx + Math.cos(ea + 0.4) * ed * 1.1, hy + Math.sin(ea + 0.4) * ed * 1.1, r * 0.18, 0, Math.PI * 2)
        ctx.fill()

        // Shield ring
        if (hasShield) {
          ctx.strokeStyle = "#00FF87"
          ctx.lineWidth = 2
          ctx.globalAlpha = 0.5 + 0.3 * Math.sin(Date.now() / 200)
          ctx.beginPath(); ctx.arc(hx, hy, r * 2.2, 0, Math.PI * 2); ctx.stroke()
        }
      }

      // Name
      ctx.globalAlpha = alive ? 0.9 : 0.2
      ctx.fillStyle = "#fff"
      ctx.font = `bold ${Math.max(10, 11 * scale)}px sans-serif`
      ctx.textAlign = "center"
      let label = name
      if (boosting && alive) label += " \u{1F4A8}"
      ctx.fillText(label, hx, hy - r * 2.5)
      ctx.globalAlpha = 1
    }

    // Particles
    this.particles = this.particles.filter(p => {
      p.x += p.vx; p.y += p.vy; p.vy += 0.02; p.life--
      if (p.life <= 0) return false
      const [sx, sy] = toScreen(p.x, p.y)
      ctx.globalAlpha = Math.min(1, p.life / 15)
      ctx.fillStyle = p.color
      ctx.shadowColor = p.color
      ctx.shadowBlur = 6
      ctx.beginPath(); ctx.arc(sx, sy, p.size * scale, 0, Math.PI * 2); ctx.fill()
      ctx.shadowBlur = 0
      ctx.globalAlpha = 1
      return true
    })

    // Minimap
    this.drawMinimap(ctx, canvas, state, W, H)

    // Leaderboard
    if (state.leaderboard?.length) {
      const lx = canvas.width - 160, ly = 10
      const lh = Math.min(state.leaderboard.length, 5) * 18 + 24
      ctx.fillStyle = "rgba(6,6,16,0.75)"
      ctx.beginPath()
      if (ctx.roundRect) ctx.roundRect(lx, ly, 150, lh, 6)
      else ctx.rect(lx, ly, 150, lh)
      ctx.fill()
      ctx.fillStyle = "#55556A"
      ctx.font = "bold 9px sans-serif"
      ctx.textAlign = "left"
      ctx.fillText("LEADERBOARD", lx + 8, ly + 14)
      state.leaderboard.slice(0, 5).forEach((e, i) => {
        const ey = ly + 26 + i * 18
        const eColor = e.c || e.color
        const eName = e.n || e.name
        const eScore = e.ts || e.total_score || 0
        ctx.fillStyle = eColor
        ctx.fillRect(lx + 8, ey - 4, 4, 4)
        ctx.fillStyle = e.id === this.playerId ? "#fff" : "#9090A8"
        ctx.font = `${e.id === this.playerId ? "bold " : ""}10px sans-serif`
        ctx.fillText(eName, lx + 18, ey)
        ctx.fillStyle = "#00F0FF"
        ctx.textAlign = "right"
        ctx.fillText(eScore, lx + 142, ey)
        ctx.textAlign = "left"
      })
    }

    // Boost indicator (bottom center)
    if (me?.alive) {
      const len = me.segments?.length || 0
      const barW = 120, barH = 6
      const bx = (canvas.width - barW) / 2, by = canvas.height - 30
      ctx.fillStyle = "rgba(6,6,16,0.6)"
      ctx.fillRect(bx - 2, by - 2, barW + 4, barH + 4)
      ctx.fillStyle = me.boosting ? "#00F0FF" : "#252535"
      ctx.fillRect(bx, by, barW * Math.min(1, len / 50), barH)
      ctx.fillStyle = "#55556A"
      ctx.font = "9px sans-serif"
      ctx.textAlign = "center"
      ctx.fillText(me.boosting ? "BOOST" : `Length: ${len}`, canvas.width / 2, by - 4)
    }
  },

  drawMinimap(ctx, canvas, state, W, H) {
    const mw = 120, mh = 80
    const mx = 10, my = canvas.height - mh - 10
    const sx = mw / W, sy = mh / H

    ctx.fillStyle = "rgba(6,6,16,0.75)"
    ctx.strokeStyle = "rgba(255,255,255,0.1)"
    ctx.lineWidth = 1
    ctx.fillRect(mx, my, mw, mh)
    ctx.strokeRect(mx, my, mw, mh)

    // Players on minimap
    for (const [id, p] of Object.entries(state.players)) {
      const pAlive = p.al !== undefined ? p.al : p.alive
      const pSegs = p.s || p.segments
      const pColor = p.c || p.color
      if (!pAlive || !pSegs?.length) continue
      const [px, py] = pSegs[0]
      ctx.fillStyle = pColor
      const r = id === this.playerId ? 3 : 2
      ctx.beginPath(); ctx.arc(mx + px * sx, my + py * sy, r, 0, Math.PI * 2); ctx.fill()
    }

    // Camera viewport on minimap
    const vx = (this.cam.x - canvas.width / 2) * sx
    const vy = (this.cam.y - canvas.height / 2) * sy
    const vw = canvas.width * sx
    const vh = canvas.height * sy
    ctx.strokeStyle = "rgba(0,240,255,0.3)"
    ctx.strokeRect(mx + vx, my + vy, vw, vh)
  }
}

export default SnakeCanvas
