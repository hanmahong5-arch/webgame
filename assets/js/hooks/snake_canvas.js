import { GameAudio } from "./game_audio"

const PUP_COLORS = { blade: "#FF4466", shield: "#00FF87", magnet: "#FFB800", star: "#E6DB74" }
const PUP_ICONS = { blade: "\u2694", shield: "\uD83D\uDEE1", magnet: "\uD83E\uDDF2", star: "\u2B50" }
const PUP_NAMES = ["blade", "shield", "magnet", "star"]
const SEG_R = 6

const SnakeCanvas = {
  mounted() {
    this.canvas = this.el
    this.ctx = this.canvas.getContext("2d")
    this.state = null
    this.playerId = null  // Set via "joined" event
    this.raf = null
    this.audio = new GameAudio()
    this.particles = []
    this.cam = { x: 900, y: 600 }
    this.mouse = { x: 0, y: 0 }
    this.boosting = false

    this._onResize = () => this.resize()
    window.addEventListener("resize", this._onResize)
    this.resize()

    // Mouse
    this.canvas.addEventListener("mousemove", (e) => {
      this.mouse.x = e.clientX; this.mouse.y = e.clientY; this.sendSteer()
    })
    this.canvas.addEventListener("mousedown", () => this.setBoosting(true))
    this.canvas.addEventListener("mouseup", () => this.setBoosting(false))

    // Touch
    this.canvas.addEventListener("touchmove", (e) => {
      e.preventDefault()
      this.mouse.x = e.touches[0].clientX; this.mouse.y = e.touches[0].clientY
      this.sendSteer()
    }, { passive: false })
    this.canvas.addEventListener("touchstart", (e) => {
      if (e.touches.length >= 2) this.setBoosting(true)
      this.mouse.x = e.touches[0].clientX; this.mouse.y = e.touches[0].clientY
      this.sendSteer()
      this.tryRespawn()
    }, { passive: true })
    this.canvas.addEventListener("touchend", (e) => {
      if (e.touches.length < 2) this.setBoosting(false)
    }, { passive: true })

    this.canvas.addEventListener("click", () => this.tryRespawn())

    this._onKey = (e) => {
      if (e.code === "Space") { e.preventDefault(); this.setBoosting(e.type === "keydown") }
      if (e.type === "keydown") this.tryRespawn()
    }
    window.addEventListener("keydown", this._onKey)
    window.addEventListener("keyup", this._onKey)

    // Identity from localStorage
    this.initIdentity()

    // Server events
    this.handleEvent("joined", ({ player_id }) => {
      this.playerId = player_id
    })
    this.handleEvent("save_name", ({ name }) => {
      localStorage.setItem("wg_player_name", name)
    })
    this.handleEvent("game_state", (s) => this.onState(s))

    this.loop()
  },

  destroyed() {
    window.removeEventListener("resize", this._onResize)
    window.removeEventListener("keydown", this._onKey)
    window.removeEventListener("keyup", this._onKey)
    if (this.raf) cancelAnimationFrame(this.raf)
  },

  initIdentity() {
    let id = localStorage.getItem("wg_player_id")
    if (!id) { id = "p_" + Math.random().toString(36).slice(2, 14); localStorage.setItem("wg_player_id", id) }
    const name = localStorage.getItem("wg_player_name") || ""
    this.pushEvent("init_player", { id, name })
    const input = document.getElementById("player-name-input")
    if (input && name) input.value = name
  },

  resize() {
    const p = this.el.parentElement
    if (!p) return
    this.canvas.width = p.clientWidth
    this.canvas.height = p.clientHeight
  },

  tryRespawn() {
    if (!this.playerId || !this.state) return
    const me = this.getMe()
    if (me && !me.alive) this.pushEvent("respawn", {})
  },

  getMe() {
    if (!this.state?.players || !this.playerId) return null
    const p = this.state.players[this.playerId]
    if (!p) return null
    return {
      alive: p.al !== undefined ? p.al : p.alive,
      segments: p.s || p.segments || [],
      score: p.sc !== undefined ? p.sc : (p.score || 0),
      kills: p.k !== undefined ? p.k : (p.kills || 0),
      boosting: p.b !== undefined ? p.b : p.boosting,
      angle: p.a !== undefined ? p.a : (p.angle || 0),
    }
  },

  sendSteer() {
    const me = this.getMe()
    if (!me?.alive || !me.segments.length) return
    const [hx, hy] = me.segments[0]
    const sx = (hx - this.cam.x) + this.canvas.width / 2
    const sy = (hy - this.cam.y) + this.canvas.height / 2
    const angle = Math.atan2(this.mouse.y - sy, this.mouse.x - sx)
    this.pushEvent("steer", { angle })
  },

  setBoosting(active) {
    if (this.boosting !== active) { this.boosting = active; this.pushEvent("boost", { active }) }
  },

  onState(state) {
    this.state = state
    if (!state.events) return
    for (const ev of state.events) {
      if (!ev) continue
      switch (ev[0]) {
        case "eat": this.audio.play("eat", ev[2] === 1); break
        case "die": {
          this.audio.play("die", ev[1] === this.playerId)
          const dp = state.players?.[ev[1]]
          const dSegs = dp?.s || dp?.segments
          if (dSegs?.length) {
            const [dx, dy] = dSegs[0]
            const dColor = dp.c || dp.color
            for (let i = 0; i < 20; i++)
              this.particles.push({ x: dx, y: dy, vx: (Math.random() - 0.5) * 4, vy: (Math.random() - 0.5) * 4, life: 30 + Math.random() * 20, color: dColor, size: 3 + Math.random() * 3 })
          }
          break
        }
        case "pup": this.audio.play("powerup"); break
        case "start": this.audio.play("start"); break
      }
    }
  },

  loop() { this.draw(); this.raf = requestAnimationFrame(() => this.loop()) },

  draw() {
    const { ctx, canvas, state } = this
    if (!state || !state.size) {
      ctx.fillStyle = "#060610"; ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.fillStyle = "#55556A"; ctx.font = "16px sans-serif"; ctx.textAlign = "center"
      ctx.fillText("Connecting...", canvas.width / 2, canvas.height / 2)
      return
    }

    const [W, H] = state.size
    const me = this.getMe()

    // Camera
    if (me?.alive && me.segments.length) {
      const [tx, ty] = me.segments[0]
      this.cam.x += (tx - this.cam.x) * 0.12
      this.cam.y += (ty - this.cam.y) * 0.12
    }

    const cx = canvas.width / 2, cy = canvas.height / 2
    const toS = (wx, wy) => [wx - this.cam.x + cx, wy - this.cam.y + cy]

    // BG
    ctx.fillStyle = "#060610"; ctx.fillRect(0, 0, canvas.width, canvas.height)

    // Grid
    ctx.strokeStyle = "rgba(255,255,255,0.02)"; ctx.lineWidth = 1
    const gs = 40
    const sx = Math.floor((this.cam.x - cx) / gs) * gs
    const sy = Math.floor((this.cam.y - cy) / gs) * gs
    for (let gx = sx; gx < this.cam.x + cx; gx += gs) {
      const [x] = toS(gx, 0); ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height); ctx.stroke()
    }
    for (let gy = sy; gy < this.cam.y + cy; gy += gs) {
      const [, y] = toS(0, gy); ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(canvas.width, y); ctx.stroke()
    }

    // Border
    const [bx0, by0] = toS(0, 0), [bx1, by1] = toS(W, H)
    ctx.strokeStyle = "rgba(255,68,102,0.2)"; ctx.lineWidth = 2
    ctx.strokeRect(bx0, by0, bx1 - bx0, by1 - by0)

    // Food
    for (const f of state.food) {
      const [fx, fy, t] = f
      const [fsx, fsy] = toS(fx, fy)
      if (fsx < -10 || fsx > canvas.width + 10 || fsy < -10 || fsy > canvas.height + 10) continue
      const golden = t === 1 || t === "golden"
      const color = golden ? "#FFB800" : "#FF4466"
      ctx.save(); ctx.shadowColor = color; ctx.shadowBlur = 6
      ctx.fillStyle = color; ctx.globalAlpha = 0.75
      ctx.beginPath(); ctx.arc(fsx, fsy, golden ? 4 : 3, 0, Math.PI * 2); ctx.fill()
      ctx.restore()
    }

    // Powerups
    const pups = state.pups || state.powerups || []
    const t = Date.now() / 1000
    for (const [px, py, ti] of pups) {
      const [psx, psy] = toS(px, py)
      if (psx < -20 || psx > canvas.width + 20 || psy < -20 || psy > canvas.height + 20) continue
      const type = typeof ti === "number" ? PUP_NAMES[ti] : ti
      const color = PUP_COLORS[type] || "#fff"
      ctx.save(); ctx.shadowColor = color; ctx.shadowBlur = 14 * (0.8 + 0.2 * Math.sin(t * 4))
      ctx.fillStyle = color; ctx.globalAlpha = 0.3
      ctx.beginPath(); ctx.arc(psx, psy, 12, 0, Math.PI * 2); ctx.fill()
      ctx.globalAlpha = 1; ctx.beginPath(); ctx.arc(psx, psy, 7, 0, Math.PI * 2); ctx.fill()
      ctx.restore()
      ctx.fillStyle = "#000"; ctx.font = "10px sans-serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle"
      ctx.fillText(PUP_ICONS[type] || "?", psx, psy); ctx.textBaseline = "alphabetic"
    }

    // Snakes
    for (const [id, p] of Object.entries(state.players)) {
      const segs = p.s || p.segments; if (!segs?.length) continue
      const alive = p.al !== undefined ? p.al : p.alive
      const color = p.c || p.color
      const name = p.n || p.name
      const angle = p.a !== undefined ? p.a : 0
      const boosting = p.b || p.boosting
      const hasShield = p.sh || p.has_shield
      const effects = p.ef || p.effects || []
      const isMe = id === this.playerId
      const r = SEG_R

      // Body
      ctx.globalAlpha = alive ? 0.85 : 0.12
      ctx.strokeStyle = color; ctx.lineWidth = r * 2; ctx.lineCap = "round"; ctx.lineJoin = "round"
      ctx.beginPath()
      for (let i = 0; i < segs.length; i++) {
        const [sx2, sy2] = toS(segs[i][0], segs[i][1])
        if (i === 0) ctx.moveTo(sx2, sy2); else ctx.lineTo(sx2, sy2)
      }
      ctx.stroke()

      // Head
      const [hsx, hsy] = toS(segs[0][0], segs[0][1])
      if (alive) {
        ctx.globalAlpha = 1; ctx.save()
        let gc = color
        if (effects.includes("star")) gc = "#E6DB74"
        if (effects.includes("blade")) gc = "#FF4466"
        if (boosting) gc = "#00F0FF"
        ctx.shadowColor = gc; ctx.shadowBlur = isMe ? 16 : 8
        ctx.fillStyle = color; ctx.beginPath(); ctx.arc(hsx, hsy, r * 1.3, 0, Math.PI * 2); ctx.fill()
        ctx.restore()
        // Eyes
        ctx.fillStyle = "#fff"; const ed = r * 0.5
        ctx.beginPath()
        ctx.arc(hsx + Math.cos(angle - 0.4) * ed, hsy + Math.sin(angle - 0.4) * ed, r * 0.35, 0, Math.PI * 2)
        ctx.arc(hsx + Math.cos(angle + 0.4) * ed, hsy + Math.sin(angle + 0.4) * ed, r * 0.35, 0, Math.PI * 2)
        ctx.fill()
        ctx.fillStyle = "#000"; ctx.beginPath()
        ctx.arc(hsx + Math.cos(angle - 0.4) * ed * 1.1, hsy + Math.sin(angle - 0.4) * ed * 1.1, r * 0.18, 0, Math.PI * 2)
        ctx.arc(hsx + Math.cos(angle + 0.4) * ed * 1.1, hsy + Math.sin(angle + 0.4) * ed * 1.1, r * 0.18, 0, Math.PI * 2)
        ctx.fill()
        if (hasShield) {
          ctx.strokeStyle = "#00FF87"; ctx.lineWidth = 2
          ctx.globalAlpha = 0.5 + 0.3 * Math.sin(t * 5)
          ctx.beginPath(); ctx.arc(hsx, hsy, r * 2, 0, Math.PI * 2); ctx.stroke()
        }
      }
      ctx.globalAlpha = alive ? 0.85 : 0.15
      ctx.fillStyle = "#fff"; ctx.font = `bold ${Math.max(9, 10)}px sans-serif`; ctx.textAlign = "center"
      ctx.fillText(name + (boosting && alive ? " \u{1F4A8}" : ""), hsx, hsy - r * 2.5)
      ctx.globalAlpha = 1
    }

    // Particles
    this.particles = this.particles.filter(p => {
      p.x += p.vx; p.y += p.vy; p.vy += 0.02; p.life--
      if (p.life <= 0) return false
      const [psx, psy] = toS(p.x, p.y)
      ctx.globalAlpha = Math.min(1, p.life / 12); ctx.fillStyle = p.color
      ctx.beginPath(); ctx.arc(psx, psy, p.size, 0, Math.PI * 2); ctx.fill()
      ctx.globalAlpha = 1; return true
    })

    // Minimap
    const mw = 100, mh = 70, mx = 8, my = canvas.height - mh - 8
    ctx.fillStyle = "rgba(6,6,16,0.7)"; ctx.fillRect(mx, my, mw, mh)
    ctx.strokeStyle = "rgba(255,255,255,0.08)"; ctx.lineWidth = 1; ctx.strokeRect(mx, my, mw, mh)
    for (const [id, p] of Object.entries(state.players)) {
      const pSegs = p.s || p.segments; if (!(p.al ?? p.alive) || !pSegs?.length) continue
      ctx.fillStyle = p.c || p.color
      ctx.beginPath(); ctx.arc(mx + pSegs[0][0] / W * mw, my + pSegs[0][1] / H * mh, id === this.playerId ? 3 : 2, 0, Math.PI * 2); ctx.fill()
    }
    ctx.strokeStyle = "rgba(0,240,255,0.2)"
    ctx.strokeRect(mx + (this.cam.x - cx) / W * mw, my + (this.cam.y - cy) / H * mh, canvas.width / W * mw, canvas.height / H * mh)

    // Leaderboard
    if (state.leaderboard?.length) {
      const lx = canvas.width - 150, ly = 8
      const lh = Math.min(state.leaderboard.length, 5) * 17 + 22
      ctx.fillStyle = "rgba(6,6,16,0.7)"; ctx.fillRect(lx, ly, 142, lh)
      ctx.fillStyle = "#55556A"; ctx.font = "bold 8px sans-serif"; ctx.textAlign = "left"
      ctx.fillText("LEADERBOARD", lx + 8, ly + 13)
      state.leaderboard.slice(0, 5).forEach((e, i) => {
        const ey = ly + 24 + i * 17
        ctx.fillStyle = e.c || e.color; ctx.fillRect(lx + 8, ey - 3, 3, 3)
        ctx.fillStyle = e.id === this.playerId ? "#fff" : "#8888A0"
        ctx.font = `${e.id === this.playerId ? "bold " : ""}9px sans-serif`
        ctx.fillText(e.n || e.name, lx + 16, ey)
        ctx.fillStyle = "#00F0FF"; ctx.textAlign = "right"
        ctx.fillText(e.ts || e.total_score || 0, lx + 136, ey); ctx.textAlign = "left"
      })
    }

    // Boost bar
    if (me?.alive) {
      const len = me.segments.length
      const bw = 100, bh = 5, bx2 = (canvas.width - bw) / 2, by2 = canvas.height - 24
      ctx.fillStyle = "rgba(6,6,16,0.5)"; ctx.fillRect(bx2 - 1, by2 - 1, bw + 2, bh + 2)
      ctx.fillStyle = me.boosting ? "#00F0FF" : "#252535"
      ctx.fillRect(bx2, by2, bw * Math.min(1, len / 50), bh)
      ctx.fillStyle = "#55556A"; ctx.font = "8px sans-serif"; ctx.textAlign = "center"
      ctx.fillText(me.boosting ? "BOOST" : `Length: ${len}`, canvas.width / 2, by2 - 3)
    }
  }
}

export default SnakeCanvas
