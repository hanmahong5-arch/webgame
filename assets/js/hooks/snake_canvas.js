import { GameAudio } from "./game_audio"

const PUP_COLORS = {
  blade: "#FF4466", shield: "#00FF87", magnet: "#FFB800", star: "#E6DB74",
  ghost: "#B08EFF", mega: "#FF6BCC", freeze: "#66D9EF", slowmo: "#8AB8E6"
}
const PUP_ICONS = {
  blade: "\u2694", shield: "\uD83D\uDEE1", magnet: "\uD83E\uDDF2", star: "\u2B50",
  ghost: "\uD83D\uDC7B", mega: "\uD83D\uDCA5", freeze: "\u2744", slowmo: "\u23F3"
}
const PUP_NAMES = ["blade", "shield", "magnet", "star", "ghost", "mega", "freeze", "slowmo"]
const TIER_RING = { 1: "#9090A8", 2: "#4A9EFF", 3: "#FFB800" }
const SEG_R = 6

const SnakeCanvas = {
  mounted() {
    this.canvas = this.el
    this.ctx = this.canvas.getContext("2d")
    this.state = null
    this.prevState = null        // snapshot one tick behind — for interpolation
    this.lastStateAt = 0         // perf ms when current state arrived
    this.stateInterval = 50      // ms between server ticks (learned from timing)
    this.playerId = null  // Set via "joined" event
    this.raf = null
    this.audio = new GameAudio()
    this.particles = []
    this.rainDrops = []          // ambient food-rain particles
    this.MAX_PARTICLES = 400
    this.MAX_RAINDROPS = 200
    this.cam = { x: 900, y: 600 }
    this.lastDrawAt = 0
    this.lastSteerAt = 0
    this._steerTrailing = null
    this._wasAlive = false       // tracks dead→alive transition for camera snap
    this._lastKiller = null      // {name, color} captured from die event
    // Static starfield (world-space, parallax-lite)
    this._stars = []
    // Large ambient glow spots in world
    this._ambient = []
    this._seedBackground()
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
    // Clear stuck boost when pointer leaves canvas
    this.canvas.addEventListener("mouseleave", () => this.setBoosting(false))

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
    this.canvas.addEventListener("touchend", () => {
      // Always clear boost on any touchend — previous logic missed multi-tap edge cases
      this.setBoosting(false)
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

    this.handleEvent("joined", ({ player_id }) => {
      this.playerId = player_id
    })
    this.handleEvent("save_name", ({ name }) => {
      localStorage.setItem("wg_player_name", name)
    })
    this.handleEvent("game_state", (s) => {
      // Server tells us who we are on every tick — bulletproof
      if (s.my_id) this.playerId = s.my_id
      this.onState(s)
    })

    this.loop()
  },

  destroyed() {
    window.removeEventListener("resize", this._onResize)
    window.removeEventListener("keydown", this._onKey)
    window.removeEventListener("keyup", this._onKey)
    if (this.raf) cancelAnimationFrame(this.raf)
    if (this._steerTrailing) { clearTimeout(this._steerTrailing); this._steerTrailing = null }
  },

  initIdentity() {
    let id = localStorage.getItem("wg_player_id")
    if (!id) { id = "p_" + Math.random().toString(36).slice(2, 14); localStorage.setItem("wg_player_id", id) }
    // Set playerId immediately as baseline (will be overridden by "joined" event if different)
    this.playerId = id
    const name = localStorage.getItem("wg_player_name") || ""
    this.pushEvent("init_player", { id, name })
    // Also set hidden form field
    const pidInput = document.getElementById("join-pid")
    if (pidInput) pidInput.value = id
    const input = document.getElementById("player-name-input")
    if (input && name) input.value = name
  },

  resize() {
    const p = this.el.parentElement
    if (!p) return
    const dpr = window.devicePixelRatio || 1
    this.canvas.width = p.clientWidth * dpr
    this.canvas.height = p.clientHeight * dpr
    this.canvas.style.width = p.clientWidth + "px"
    this.canvas.style.height = p.clientHeight + "px"
    this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
    this.dpr = dpr
    // Pre-render glow sprites
    this._buildGlowCache()
  },

  _seedBackground() {
    // Deterministic seed based on a fixed PRNG for consistent look
    let s = 1337
    const rand = () => { s = (s * 16807) % 2147483647; return s / 2147483647 }
    // 400 stars across 2400x1600 world + margin
    const starColors = ["#FFFFFF", "#B0E0FF", "#FFE5B0", "#E0C0FF"]
    for (let i = 0; i < 400; i++) {
      this._stars.push({
        x: -200 + rand() * 2800,
        y: -200 + rand() * 2000,
        r: 0.4 + rand() * 1.4,
        c: starColors[(rand() * 4) | 0],
        twinkle: rand() * Math.PI * 2
      })
    }
    // 8 ambient glow blobs
    const glowColors = ["#4A9EFF", "#B08EFF", "#FF6BCC", "#00F0FF", "#7AFF89"]
    for (let i = 0; i < 8; i++) {
      this._ambient.push({
        x: 100 + rand() * 2200,
        y: 100 + rand() * 1400,
        r: 120 + rand() * 180,
        c: glowColors[(rand() * 5) | 0],
        drift: rand() * Math.PI * 2
      })
    }
  },

  _buildGlowCache() {
    this._glowCache = {}
    const colors = { food: "#FF4466", golden: "#FFB800", head: "#00F0FF" }
    for (const [k, c] of Object.entries(colors)) {
      const size = k === "head" ? 32 : 16
      const cv = document.createElement("canvas")
      cv.width = size * 2; cv.height = size * 2
      const g = cv.getContext("2d")
      const r = size * 0.6
      g.shadowColor = c; g.shadowBlur = size * 0.8
      g.fillStyle = c; g.beginPath(); g.arc(size, size, r, 0, Math.PI * 2); g.fill()
      this._glowCache[k] = cv
    }
  },

  tryRespawn() {
    if (!this.playerId) return
    // Send if me is dead OR me is missing entirely (cleaned up server-side)
    const me = this.getMe()
    if (!me || !me.alive) this.pushEvent("respawn", {})
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
    // Throttle to ~20Hz: skip leading, queue trailing
    const now = performance.now()
    if (now - this.lastSteerAt < 50) {
      if (!this._steerTrailing) {
        this._steerTrailing = setTimeout(() => { this._steerTrailing = null; this.sendSteer() }, 55)
      }
      return
    }
    this.lastSteerAt = now
    const [hx, hy] = me.segments[0]
    // Use CSS pixels for mouse math (canvas is scaled by DPR)
    const cw = this.canvas.width / (this.dpr || 1)
    const ch = this.canvas.height / (this.dpr || 1)
    const sx = (hx - this.cam.x) + cw / 2
    const sy = (hy - this.cam.y) + ch / 2
    const angle = Math.atan2(this.mouse.y - sy, this.mouse.x - sx)
    this.pushEvent("steer", { angle })
  },

  setBoosting(active) {
    if (this.boosting !== active) { this.boosting = active; this.pushEvent("boost", { active }) }
  },

  pushKillerToLV() {
    if (!this._lastKiller) return
    this.pushEvent("set_killer", { name: this._lastKiller.name, color: this._lastKiller.color })
  },

  onState(state) {
    const now = performance.now()
    if (this.state && this.lastStateAt) {
      const dt = now - this.lastStateAt
      // Smooth moving-average, clamp to sane range
      if (dt > 20 && dt < 200) this.stateInterval = this.stateInterval * 0.8 + dt * 0.2
    }
    this.prevState = this.state
    this.state = state
    this.lastStateAt = now

    // Cap visual particle arrays so they can't grow unbounded across long sessions / rain bursts
    if (this.rainDrops.length > this.MAX_RAINDROPS) {
      this.rainDrops.splice(0, this.rainDrops.length - this.MAX_RAINDROPS)
    }
    if (this.particles.length > this.MAX_PARTICLES) {
      this.particles.splice(0, this.particles.length - this.MAX_PARTICLES)
    }

    // Camera snap on dead→alive transition (avoid 1-frame jitter from old cam position)
    const me = state.players?.[this.playerId]
    const isAliveNow = me && (me.al !== undefined ? me.al : me.alive)
    if (isAliveNow && !this._wasAlive) {
      const segs = me.s || me.segments
      if (segs?.[0]) { this.cam.x = segs[0][0]; this.cam.y = segs[0][1] }
      this._lastKiller = null
    }
    this._wasAlive = !!isAliveNow

    if (!state.events) return
    for (const ev of state.events) {
      if (!ev) continue
      switch (ev[0]) {
        case "eat": this.audio.play("eat", ev[2] === 1); break
        case "die": {
          const wasMe = ev[1] === this.playerId
          this.audio.play("die", wasMe)
          // Capture killer info if I was the victim
          if (wasMe) {
            const killerId = ev[2]
            const killerName = ev[3]
            if (killerId && killerId !== ev[1]) {
              const kp = state.players?.[killerId]
              this._lastKiller = {
                name: killerName || (kp?.n || kp?.name || "?"),
                color: kp?.c || kp?.color || "#FF4466"
              }
            } else {
              this._lastKiller = { name: "the wall", color: "#FF4466" }
            }
            this.pushKillerToLV()
          }
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
        case "lv":
          if (ev[1] === this.playerId) this.audio.play("powerup")
          break
        case "fat":
          if (ev[1] === this.playerId) this.audio.play("powerup")
          break
        case "streak": {
          if (ev[1] === this.playerId) this.audio.play("powerup")
          this.flashBanner = { text: `${ev[2]}x KILLSTREAK!`, color: "#FFB800", until: now + 1400 }
          break
        }
        case "rain": {
          this.flashBanner = { text: "FOOD RAIN!", color: "#00F0FF", until: now + 1800 }
          // Seed ambient drops from screen top
          const burst = Math.min(40, ev[1] || 20)
          for (let i = 0; i < burst; i++) {
            this.rainDrops.push({
              x: Math.random() * 2400, y: -40 - Math.random() * 200,
              vx: (Math.random() - 0.5) * 0.5, vy: 2 + Math.random() * 2,
              life: 120 + Math.random() * 60,
              golden: Math.random() < 0.25
            })
          }
          break
        }
      }
    }
  },

  loop() { this.draw(); this.raf = requestAnimationFrame(() => this.loop()) },

  draw() {
    const { ctx, canvas, state } = this
    // Use CSS pixel dimensions for layout math
    const dpr = this.dpr || 1
    const W_CSS = canvas.width / dpr, H_CSS = canvas.height / dpr

    if (!state || !state.size) {
      ctx.fillStyle = "#060610"; ctx.fillRect(0, 0, W_CSS, H_CSS)
      ctx.fillStyle = "#55556A"; ctx.font = "16px sans-serif"; ctx.textAlign = "center"
      ctx.fillText("Connecting...", W_CSS / 2, H_CSS / 2)
      return
    }

    const [W, H] = state.size
    const me = this.getMe()
    const nowMs = performance.now()
    const t = nowMs / 1000
    const dtMs = this.lastDrawAt ? Math.min(50, nowMs - this.lastDrawAt) : 16
    this.lastDrawAt = nowMs

    // Interpolation alpha 0..1 between prevState and state over stateInterval
    const interval = Math.max(20, this.stateInterval || 50)
    const rawAlpha = this.lastStateAt ? (nowMs - this.lastStateAt) / interval : 1
    // Render "one tick behind" for smoothness — map [0..1] onto prev→curr; clamp light overshoot
    const ialpha = Math.max(0, Math.min(1.15, rawAlpha))

    // Build interpolated segments per player (snap if segment counts differ — growth/death frame)
    const rsegs = {}
    if (this.prevState?.players) {
      for (const id in state.players) {
        const cur = state.players[id]
        const prev = this.prevState.players[id]
        const cs = cur.s || cur.segments
        const ps = prev?.s || prev?.segments
        if (!cs?.length) continue
        if (!ps || ps.length !== cs.length) {
          rsegs[id] = cs
        } else {
          const out = new Array(cs.length)
          for (let i = 0; i < cs.length; i++) {
            out[i] = [
              ps[i][0] + (cs[i][0] - ps[i][0]) * ialpha,
              ps[i][1] + (cs[i][1] - ps[i][1]) * ialpha
            ]
          }
          rsegs[id] = out
        }
      }
    } else {
      for (const id in state.players) {
        const cur = state.players[id]
        const cs = cur.s || cur.segments
        if (cs?.length) rsegs[id] = cs
      }
    }

    // Camera lerp — dt-based so feel is consistent across 30/60/120Hz displays
    const camHead = me?.alive ? rsegs[this.playerId]?.[0] || me.segments[0] : null
    if (camHead) {
      const lerpF = 1 - Math.pow(1 - 0.12, dtMs / 16.67)
      this.cam.x += (camHead[0] - this.cam.x) * lerpF
      this.cam.y += (camHead[1] - this.cam.y) * lerpF
    }

    const cx = W_CSS / 2, cy = H_CSS / 2
    const camX = this.cam.x, camY = this.cam.y
    // Inline transform (avoid array allocation per call)
    const toSx = (wx) => wx - camX + cx
    const toSy = (wy) => wy - camY + cy

    // BG — dark base
    ctx.fillStyle = "#05050C"; ctx.fillRect(0, 0, W_CSS, H_CSS)

    // Ambient glow blobs (big soft circles drifting)
    for (const a of this._ambient) {
      const asx = toSx(a.x), asy = toSy(a.y)
      if (asx < -a.r - 50 || asx > W_CSS + a.r + 50 || asy < -a.r - 50 || asy > H_CSS + a.r + 50) continue
      const drift = Math.sin(t * 0.2 + a.drift) * 20
      const grad = ctx.createRadialGradient(asx + drift, asy + drift * 0.6, 0, asx + drift, asy + drift * 0.6, a.r)
      grad.addColorStop(0, a.c + "20")
      grad.addColorStop(0.5, a.c + "10")
      grad.addColorStop(1, a.c + "00")
      ctx.fillStyle = grad
      ctx.fillRect(asx + drift - a.r, asy + drift * 0.6 - a.r, a.r * 2, a.r * 2)
    }

    // Starfield — twinkling dots
    for (const s of this._stars) {
      const ssx = toSx(s.x), ssy = toSy(s.y)
      if (ssx < -2 || ssx > W_CSS + 2 || ssy < -2 || ssy > H_CSS + 2) continue
      const tw = 0.4 + 0.6 * Math.abs(Math.sin(t * 1.5 + s.twinkle))
      ctx.globalAlpha = tw * 0.7
      ctx.fillStyle = s.c
      ctx.fillRect(ssx - s.r / 2, ssy - s.r / 2, s.r, s.r)
    }
    ctx.globalAlpha = 1

    // Grid — single batched path, stronger inside arena
    ctx.strokeStyle = "rgba(100,140,200,0.05)"; ctx.lineWidth = 1
    ctx.beginPath()
    const gs = 60
    const gsx = Math.floor((camX - cx) / gs) * gs
    const gsy = Math.floor((camY - cy) / gs) * gs
    for (let gx = gsx; gx < camX + cx; gx += gs) {
      const x = toSx(gx); ctx.moveTo(x, 0); ctx.lineTo(x, H_CSS)
    }
    for (let gy = gsy; gy < camY + cy; gy += gs) {
      const y = toSy(gy); ctx.moveTo(0, y); ctx.lineTo(W_CSS, y)
    }
    ctx.stroke()

    // Border — glowing danger zone
    const bx0 = toSx(0), by0 = toSy(0), bx1 = toSx(W), by1 = toSy(H)
    // Outer red glow
    ctx.strokeStyle = "rgba(255,68,102,0.4)"
    ctx.lineWidth = 4
    ctx.strokeRect(bx0 - 1, by0 - 1, bx1 - bx0 + 2, by1 - by0 + 2)
    // Inner crisp line
    ctx.strokeStyle = "rgba(255,100,130,0.9)"
    ctx.lineWidth = 1
    ctx.strokeRect(bx0, by0, bx1 - bx0, by1 - by0)

    // Food — batch by color, NO shadowBlur (use pre-rendered glow sprite)
    const foodGlow = this._glowCache?.food
    const goldenGlow = this._glowCache?.golden
    ctx.globalAlpha = 0.8
    for (const f of state.food) {
      const fsx = toSx(f[0]), fsy = toSy(f[1])
      if (fsx < -10 || fsx > W_CSS + 10 || fsy < -10 || fsy > H_CSS + 10) continue
      const golden = f[2] === 1 || f[2] === "golden"
      const sprite = golden ? goldenGlow : foodGlow
      if (sprite) {
        ctx.drawImage(sprite, fsx - 8, fsy - 8, 16, 16)
      } else {
        ctx.fillStyle = golden ? "#FFB800" : "#FF4466"
        ctx.beginPath(); ctx.arc(fsx, fsy, golden ? 4 : 3, 0, Math.PI * 2); ctx.fill()
      }
    }
    ctx.globalAlpha = 1

    // Powerups — tier-based ring, no shadowBlur
    const pups = state.pups || state.powerups || []
    for (const pup of pups) {
      const px = pup[0], py = pup[1], ti = pup[2], tier = pup[3] || 1
      const psx = toSx(px), psy = toSy(py)
      if (psx < -20 || psx > W_CSS + 20 || psy < -20 || psy > H_CSS + 20) continue
      const type = typeof ti === "number" ? PUP_NAMES[ti] : ti
      const color = PUP_COLORS[type] || "#fff"
      const ringColor = TIER_RING[tier] || "#9090A8"
      const pulse = 0.7 + 0.3 * Math.sin(t * 4 + tier)
      // Glow
      ctx.globalAlpha = 0.2 * pulse; ctx.fillStyle = color
      ctx.beginPath(); ctx.arc(psx, psy, 16 + tier * 2, 0, Math.PI * 2); ctx.fill()
      // Tier ring
      ctx.globalAlpha = 0.8
      ctx.strokeStyle = ringColor
      ctx.lineWidth = 2
      ctx.beginPath(); ctx.arc(psx, psy, 11, 0, Math.PI * 2); ctx.stroke()
      // Core
      ctx.globalAlpha = 0.9; ctx.fillStyle = color
      ctx.beginPath(); ctx.arc(psx, psy, 8, 0, Math.PI * 2); ctx.fill()
      ctx.globalAlpha = 1
      // Icon
      ctx.fillStyle = "#000"; ctx.font = "11px sans-serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle"
      ctx.fillText(PUP_ICONS[type] || "?", psx, psy); ctx.textBaseline = "alphabetic"
    }

    // Boost particle trail (emit behind boosting snakes)
    for (const id in state.players) {
      const p = state.players[id]
      const b = p.b || p.boosting
      if (!b) continue
      const segs = rsegs[id] || p.s || p.segments
      if (!segs?.length || segs.length < 3) continue
      const tailIdx = Math.min(segs.length - 1, 6)
      const [tx, ty] = segs[tailIdx]
      if (Math.random() < 0.6) {
        this.particles.push({
          x: tx + (Math.random() - 0.5) * 6,
          y: ty + (Math.random() - 0.5) * 6,
          vx: (Math.random() - 0.5) * 0.6,
          vy: (Math.random() - 0.5) * 0.6,
          life: 14 + Math.random() * 10,
          color: p.c || p.color || "#00F0FF",
          size: 1.5 + Math.random() * 1.5
        })
      }
    }

    // Snakes
    for (const id in state.players) {
      const p = state.players[id]
      const segs = rsegs[id] || p.s || p.segments; if (!segs?.length) continue
      const alive = p.al !== undefined ? p.al : p.alive
      const color = p.c || p.color
      const name = p.n || p.name
      const angle = p.a !== undefined ? p.a : 0
      const boosting = p.b || p.boosting
      const shieldStacks = p.sh !== undefined ? p.sh : (p.has_shield ? 1 : 0)
      // effects: array of strings OR array of [type, tier, ttl]
      const rawEff = p.ef || p.effects || []
      const effects = rawEff.map(e => Array.isArray(e) ? e[0] : e)
      const level = p.lv || 1
      const invincible = !!p.inv
      const justLeveled = !!p.ul
      const combo = p.cmb || 0
      const streak = p.st || 0
      const girth = p.g || 1.0
      const isMe = id === this.playerId
      // Body thickness: level adds slight, girth (rogue-like fatten) multiplies
      const r = (SEG_R + Math.min(level - 1, 20) * 0.15) * girth

      // Invincibility: blink
      const invisAlpha = invincible ? (0.35 + 0.35 * Math.abs(Math.sin(t * 8))) : 1
      // Just leveled up: white flash for 1 second
      const levelFlash = justLeveled ? Math.max(0, 1 - (state.tick % 20) / 20) : 0

      // Body
      ctx.globalAlpha = alive ? (0.85 * invisAlpha) : 0.12
      ctx.strokeStyle = levelFlash > 0.3 ? "#FFFFFF" : color
      ctx.lineWidth = r * 2
      ctx.lineCap = "round"; ctx.lineJoin = "round"
      ctx.beginPath()
      for (let i = 0; i < segs.length; i++) {
        const sx2 = toSx(segs[i][0]), sy2 = toSy(segs[i][1])
        if (i === 0) ctx.moveTo(sx2, sy2); else ctx.lineTo(sx2, sy2)
      }
      ctx.stroke()

      // Ghost effect: semi-transparent
      if (effects.includes("ghost") && alive) {
        ctx.globalAlpha = 0.4
      }

      // Head
      const hsx = toSx(segs[0][0]), hsy = toSy(segs[0][1])
      if (alive) {
        ctx.globalAlpha = invisAlpha
        // Mega: larger head
        const headR = effects.includes("mega") ? r * 2.2 : r * 1.3
        let gc = color
        if (effects.includes("star")) gc = "#E6DB74"
        else if (effects.includes("blade")) gc = "#FF4466"
        else if (effects.includes("freeze") || effects.includes("slowmo_target")) gc = "#66D9EF"
        else if (boosting) gc = "#00F0FF"
        // Only use shadowBlur on own head (expensive)
        if (isMe) { ctx.save(); ctx.shadowColor = gc; ctx.shadowBlur = 14 }
        ctx.fillStyle = color
        ctx.beginPath(); ctx.arc(hsx, hsy, headR, 0, Math.PI * 2); ctx.fill()
        if (isMe) ctx.restore()

        // Eyes
        ctx.fillStyle = "#fff"; const ed = headR * 0.4
        ctx.beginPath()
        ctx.arc(hsx + Math.cos(angle - 0.4) * ed, hsy + Math.sin(angle - 0.4) * ed, headR * 0.28, 0, Math.PI * 2)
        ctx.arc(hsx + Math.cos(angle + 0.4) * ed, hsy + Math.sin(angle + 0.4) * ed, headR * 0.28, 0, Math.PI * 2)
        ctx.fill()
        ctx.fillStyle = "#000"; ctx.beginPath()
        ctx.arc(hsx + Math.cos(angle - 0.4) * ed * 1.15, hsy + Math.sin(angle - 0.4) * ed * 1.15, headR * 0.14, 0, Math.PI * 2)
        ctx.arc(hsx + Math.cos(angle + 0.4) * ed * 1.15, hsy + Math.sin(angle + 0.4) * ed * 1.15, headR * 0.14, 0, Math.PI * 2)
        ctx.fill()

        // Shield rings (one per stack)
        if (shieldStacks > 0) {
          ctx.strokeStyle = "#00FF87"
          ctx.lineWidth = 2
          for (let s = 0; s < shieldStacks; s++) {
            ctx.globalAlpha = 0.4 + 0.3 * Math.sin(t * 5 + s)
            ctx.beginPath()
            ctx.arc(hsx, hsy, headR * (1.5 + s * 0.35), 0, Math.PI * 2)
            ctx.stroke()
          }
        }
        // Invincibility halo (respawn safety)
        if (invincible) {
          ctx.strokeStyle = "#FFFFFF"; ctx.lineWidth = 2
          ctx.globalAlpha = 0.3 + 0.3 * Math.abs(Math.sin(t * 10))
          ctx.beginPath(); ctx.arc(hsx, hsy, headR * 2, 0, Math.PI * 2); ctx.stroke()
        }
        // Killstreak flame ring (>= 3 kills within window)
        if (streak >= 3) {
          const flameR = headR * (1.7 + 0.15 * Math.sin(t * 9))
          ctx.strokeStyle = streak >= 7 ? "#FF4466" : "#FFB800"
          ctx.lineWidth = 3
          ctx.globalAlpha = 0.55 + 0.35 * Math.abs(Math.sin(t * 7))
          ctx.beginPath(); ctx.arc(hsx, hsy, flameR, 0, Math.PI * 2); ctx.stroke()
          // Inner spark ring
          ctx.strokeStyle = "#FFE5B0"; ctx.lineWidth = 1
          ctx.globalAlpha = 0.8
          ctx.beginPath(); ctx.arc(hsx, hsy, flameR * 0.75, 0, Math.PI * 2); ctx.stroke()
        }
        ctx.globalAlpha = 1
      }

      // Name + Lv + status icons
      ctx.globalAlpha = alive ? 0.9 : 0.18
      ctx.fillStyle = "#fff"; ctx.font = `bold 11px sans-serif`; ctx.textAlign = "center"
      const isBot = !!p.bot
      let label = `Lv${level} ${name}`
      if (isBot) label = "🤖 " + label
      if (boosting && alive) label += " \u{1F4A8}"
      ctx.fillText(label, hsx, hsy - r * 2.5)

      // Combo indicator above head (own player only, if comboing)
      if (isMe && combo >= 3 && alive) {
        ctx.fillStyle = "#FFB800"
        ctx.font = "bold 13px sans-serif"
        ctx.fillText(`x${combo} COMBO!`, hsx, hsy - r * 4)
      }
      // Streak indicator above head for anyone with streak >= 3
      if (streak >= 3 && alive) {
        ctx.fillStyle = streak >= 7 ? "#FF4466" : "#FFB800"
        ctx.font = "bold 12px sans-serif"
        ctx.fillText(`\uD83D\uDD25 ${streak} STREAK`, hsx, hsy - r * 3.5)
      }
      ctx.globalAlpha = 1
    }

    // Particles
    this.particles = this.particles.filter(p => {
      p.x += p.vx; p.y += p.vy; p.vy += 0.02; p.life--
      if (p.life <= 0) return false
      const psx = toSx(p.x), psy = toSy(p.y)
      ctx.globalAlpha = Math.min(1, p.life / 12); ctx.fillStyle = p.color
      ctx.beginPath(); ctx.arc(psx, psy, p.size, 0, Math.PI * 2); ctx.fill()
      ctx.globalAlpha = 1; return true
    })

    // Food-rain ambient drops (purely cosmetic — server seeds real food separately)
    if (this.rainDrops.length) {
      this.rainDrops = this.rainDrops.filter(d => {
        d.x += d.vx; d.y += d.vy; d.life--
        if (d.life <= 0 || d.y > H + 40) return false
        const dsx = toSx(d.x), dsy = toSy(d.y)
        if (dsx < -6 || dsx > W_CSS + 6 || dsy < -6 || dsy > H_CSS + 6) return true
        ctx.globalAlpha = Math.min(0.8, d.life / 60)
        ctx.fillStyle = d.golden ? "#FFB800" : "#FF4466"
        ctx.beginPath(); ctx.arc(dsx, dsy, d.golden ? 3 : 2.2, 0, Math.PI * 2); ctx.fill()
        ctx.globalAlpha = 1
        return true
      })
    }

    // Minimap
    const mw = 100, mh = 70, mx = 8, my = H_CSS - mh - 8
    ctx.fillStyle = "rgba(6,6,16,0.7)"; ctx.fillRect(mx, my, mw, mh)
    ctx.strokeStyle = "rgba(255,255,255,0.08)"; ctx.lineWidth = 1; ctx.strokeRect(mx, my, mw, mh)
    for (const id in state.players) {
      const p = state.players[id]
      const pSegs = p.s || p.segments
      const pAlive = p.al !== undefined ? p.al : p.alive
      if (!pAlive || !pSegs?.length) continue
      ctx.fillStyle = p.c || p.color
      ctx.beginPath()
      ctx.arc(mx + pSegs[0][0] / W * mw, my + pSegs[0][1] / H * mh, id === this.playerId ? 3 : 2, 0, Math.PI * 2)
      ctx.fill()
    }
    ctx.strokeStyle = "rgba(0,240,255,0.2)"
    ctx.strokeRect(mx + (camX - cx) / W * mw, my + (camY - cy) / H * mh, W_CSS / W * mw, H_CSS / H * mh)

    // Leaderboard with level
    if (state.leaderboard?.length) {
      const lx = W_CSS - 160, ly = 8
      const lh = Math.min(state.leaderboard.length, 5) * 18 + 22
      ctx.fillStyle = "rgba(6,6,16,0.7)"; ctx.fillRect(lx, ly, 152, lh)
      ctx.fillStyle = "#55556A"; ctx.font = "bold 9px sans-serif"; ctx.textAlign = "left"
      ctx.fillText("LEADERBOARD", lx + 8, ly + 13)
      state.leaderboard.slice(0, 5).forEach((e, i) => {
        const ey = ly + 25 + i * 18
        const eColor = e.c || e.color
        const eName = e.n || e.name
        const eLevel = e.lv || 1
        const eScore = e.ts || e.total_score || 0
        const eBot = !!e.bot
        ctx.fillStyle = eColor; ctx.fillRect(lx + 8, ey - 4, 3, 3)
        ctx.fillStyle = e.id === this.playerId ? "#fff" : "#8888A0"
        ctx.font = `${e.id === this.playerId ? "bold " : ""}10px sans-serif`
        const prefix = eBot ? "🤖 " : ""
        ctx.fillText(`${prefix}L${eLevel} ${eName}`, lx + 16, ey)
        ctx.fillStyle = "#00F0FF"; ctx.textAlign = "right"
        ctx.fillText(eScore, lx + 146, ey); ctx.textAlign = "left"
      })
    }

    // Boost bar
    if (me?.alive) {
      const len = me.segments.length
      const bw = 100, bh = 5, bx2 = (W_CSS - bw) / 2, by2 = H_CSS - 24
      ctx.fillStyle = "rgba(6,6,16,0.5)"; ctx.fillRect(bx2 - 1, by2 - 1, bw + 2, bh + 2)
      ctx.fillStyle = me.boosting ? "#00F0FF" : "#252535"
      ctx.fillRect(bx2, by2, bw * Math.min(1, len / 50), bh)
      ctx.fillStyle = "#55556A"; ctx.font = "8px sans-serif"; ctx.textAlign = "center"
      ctx.fillText(me.boosting ? "BOOST" : `Length: ${len}`, W_CSS / 2, by2 - 3)
    }

    // Flash banner (streak / food rain / events)
    if (this.flashBanner && nowMs < this.flashBanner.until) {
      const remaining = this.flashBanner.until - nowMs
      const totalDur = 1400
      const a = Math.min(1, remaining / 400) * Math.min(1, (totalDur - remaining) / 150 + 0.2)
      ctx.globalAlpha = a
      ctx.fillStyle = this.flashBanner.color
      ctx.font = "bold 42px sans-serif"
      ctx.textAlign = "center"
      ctx.shadowColor = this.flashBanner.color; ctx.shadowBlur = 24
      ctx.fillText(this.flashBanner.text, W_CSS / 2, H_CSS * 0.22)
      ctx.shadowBlur = 0
      ctx.globalAlpha = 1
    } else if (this.flashBanner) {
      this.flashBanner = null
    }

    // Rain overlay tint (subtle cyan haze while rain active)
    if (state.rain) {
      ctx.fillStyle = "rgba(0,240,255,0.035)"
      ctx.fillRect(0, 0, W_CSS, H_CSS)
    }
  }
}

export default SnakeCanvas
