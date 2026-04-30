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
    this.laserBeams = []         // active beam segments to draw briefly
    // Particle pool sized just under what feels lively — anything more is
    // silent waste since most particles fade in <1s and bursts overlap.
    this.MAX_PARTICLES = 150
    this.MAX_RAINDROPS = 150
    this.MAX_LASERS = 24
    // Pooled per-id segment arrays. Re-used in draw() for interpolated positions
    // so we don't allocate ~1000 small [x,y] arrays/frame at high length, which
    // was triggering periodic GC stalls past 4000 score.
    this._rsegsCache = {}
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
    this.canvas.addEventListener("mousedown", (e) => {
      // Right-click = laser eye (don't trigger boost)
      if (e.button === 2) { e.preventDefault(); this.fireLaser(); return }
      if (e.button === 0) this.setBoosting(true)
    })
    this.canvas.addEventListener("mouseup", (e) => {
      if (e.button === 0) this.setBoosting(false)
    })
    // Suppress browser context menu so right-click can be used as a game button
    this.canvas.addEventListener("contextmenu", (e) => e.preventDefault())
    // Clear stuck boost when pointer leaves canvas
    this.canvas.addEventListener("mouseleave", () => this.setBoosting(false))

    // Touch — single finger steers; long-press (>180ms) anywhere boosts.
    // Multi-touch also boosts (legacy gesture). The two work together so
    // mobile players don't need an on-screen button.
    this._touchPressTimer = null
    this._touchBoostByPress = false

    const startBoostTimer = () => {
      if (this._touchPressTimer) clearTimeout(this._touchPressTimer)
      this._touchPressTimer = setTimeout(() => {
        this._touchBoostByPress = true
        this.setBoosting(true)
      }, 180)
    }
    const cancelBoostTimer = () => {
      if (this._touchPressTimer) { clearTimeout(this._touchPressTimer); this._touchPressTimer = null }
      if (this._touchBoostByPress) { this._touchBoostByPress = false; this.setBoosting(false) }
    }

    this.canvas.addEventListener("touchmove", (e) => {
      e.preventDefault()
      // First significant move cancels the press-to-boost timer so dragging
      // (steering) doesn't accidentally trigger boost. Already-active boost
      // from press is preserved — players can boost-then-steer.
      if (this._touchPressTimer && !this._touchBoostByPress) {
        clearTimeout(this._touchPressTimer)
        this._touchPressTimer = null
      }
      this.mouse.x = e.touches[0].clientX; this.mouse.y = e.touches[0].clientY
      this.sendSteer()
    }, { passive: false })
    this.canvas.addEventListener("touchstart", (e) => {
      if (e.touches.length >= 2) this.setBoosting(true)
      this.mouse.x = e.touches[0].clientX; this.mouse.y = e.touches[0].clientY
      this.sendSteer()
      this.tryRespawn()
      if (e.touches.length === 1) startBoostTimer()
    }, { passive: true })
    this.canvas.addEventListener("touchend", (e) => {
      // Multi-touch boost ends when any finger lifts; press-and-hold boost
      // ends only when the last finger lifts.
      if (e.touches.length < 2) this.setBoosting(false)
      cancelBoostTimer()
    }, { passive: true })
    this.canvas.addEventListener("touchcancel", () => {
      this.setBoosting(false); cancelBoostTimer()
    }, { passive: true })

    this.canvas.addEventListener("click", () => this.tryRespawn())

    // Visible boost button (rendered for touch devices via CSS media query).
    // Press-hold pattern, intentionally separate from canvas touch handlers.
    const boostBtn = document.getElementById("touch-boost-btn")
    if (boostBtn) {
      const onPress = (e) => { e.preventDefault(); this.setBoosting(true) }
      const onRelease = (e) => { e.preventDefault(); this.setBoosting(false) }
      boostBtn.addEventListener("touchstart", onPress, { passive: false })
      boostBtn.addEventListener("touchend", onRelease, { passive: false })
      boostBtn.addEventListener("touchcancel", onRelease, { passive: false })
      boostBtn.addEventListener("mousedown", onPress)
      boostBtn.addEventListener("mouseup", onRelease)
      boostBtn.addEventListener("mouseleave", onRelease)
      this._boostBtnHandlers = { btn: boostBtn, onPress, onRelease }
    }

    // Visible laser button — tap-fire, no hold semantics.
    const laserBtn = document.getElementById("touch-laser-btn")
    if (laserBtn) {
      const onLaserTap = (e) => { e.preventDefault(); this.fireLaser() }
      laserBtn.addEventListener("touchstart", onLaserTap, { passive: false })
      laserBtn.addEventListener("click", onLaserTap)
      this._laserBtnHandlers = { btn: laserBtn, onLaserTap }
    }

    // Gacha button — server validates eligibility, button just sends the event.
    const gachaBtn = document.getElementById("gacha-btn")
    if (gachaBtn) {
      const onGachaTap = (e) => { e.preventDefault(); this.fireGacha() }
      gachaBtn.addEventListener("touchstart", onGachaTap, { passive: false })
      gachaBtn.addEventListener("click", onGachaTap)
      this._gachaBtnHandlers = { btn: gachaBtn, onGachaTap }
    }

    // Keyboard. Multiple boost keys so any layout works:
    //   Space / Shift / Enter / W (also press-anywhere on mobile)
    // Browsers fire keydown repeatedly while held; setBoosting de-dupes the
    // PubSub push so holding space gives one cast, not 30/sec.
    const BOOST_KEYS = new Set(["Space", "ShiftLeft", "ShiftRight", "Enter", "KeyW"])
    const LASER_KEYS = new Set(["KeyV", "KeyF"])
    const GACHA_KEYS = new Set(["KeyG"])
    this._onKey = (e) => {
      if (BOOST_KEYS.has(e.code)) {
        if (e.code === "Space") e.preventDefault()
        this.setBoosting(e.type === "keydown")
        return
      }
      if (LASER_KEYS.has(e.code)) {
        if (e.type === "keydown" && !e.repeat) this.fireLaser()
        return
      }
      if (GACHA_KEYS.has(e.code)) {
        if (e.type === "keydown" && !e.repeat) this.fireGacha()
        return
      }
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
    this.handleEvent("server_shutdown", () => {
      // Pod is rolling out. Show a banner; LV will auto-reconnect on the new pod
      // and resume_player will restore our snake by localStorage id.
      this.flashBanner = {
        text: "Server restarting — reconnecting…",
        color: "#FFB800",
        until: performance.now() + 8000
      }
    })

    this.loop()
  },

  destroyed() {
    window.removeEventListener("resize", this._onResize)
    window.removeEventListener("keydown", this._onKey)
    window.removeEventListener("keyup", this._onKey)
    if (this.raf) cancelAnimationFrame(this.raf)
    if (this._steerTrailing) { clearTimeout(this._steerTrailing); this._steerTrailing = null }
    if (this._touchPressTimer) { clearTimeout(this._touchPressTimer); this._touchPressTimer = null }
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
    this._buildBackgroundCache()
  },

  // Pre-render stars + ambient glow into a single world-space offscreen
  // canvas. Lets `draw()` blit a viewport region per frame instead of
  // looping 400 stars + 8 radial-gradient blobs every time. Big perf win
  // on long sessions / high-segment scenes.
  // Trade-off: stars no longer twinkle, ambient no longer drifts. Both
  // were minor cosmetics; the perf savings dominate.
  _buildBackgroundCache() {
    const BG_W = 3000, BG_H = 2200, OX = 200, OY = 200
    const off = document.createElement("canvas")
    off.width = BG_W; off.height = BG_H
    const c = off.getContext("2d")

    // Solid base
    c.fillStyle = "#05050C"
    c.fillRect(0, 0, BG_W, BG_H)

    // Ambient glow blobs
    for (const a of this._ambient) {
      const cx = a.x + OX, cy = a.y + OY
      const grad = c.createRadialGradient(cx, cy, 0, cx, cy, a.r)
      grad.addColorStop(0, a.c + "20")
      grad.addColorStop(0.5, a.c + "10")
      grad.addColorStop(1, a.c + "00")
      c.fillStyle = grad
      c.fillRect(cx - a.r, cy - a.r, a.r * 2, a.r * 2)
    }

    // Stars
    c.globalAlpha = 0.6
    for (const s of this._stars) {
      const cx = s.x + OX, cy = s.y + OY
      c.fillStyle = s.c
      c.fillRect(cx - s.r / 2, cy - s.r / 2, s.r, s.r)
    }
    c.globalAlpha = 1

    this._bgCache = off
    this._bgOX = OX
    this._bgOY = OY
    this._bgW = BG_W
    this._bgH = BG_H
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

  // Display table for gacha results — emoji + label + tier color.
  // Keep static at module scope inside the hook so it's allocated once.
  _gachaInfo(type, tier) {
    const T = {
      magnet:        ["🧲", "Magnet"],
      shield:        ["🛡",  "Shield"],
      star:          ["⭐", "Star"],
      ghost:         ["👻", "Ghost"],
      blade:         ["⚔",  "Blade"],
      mega:          ["💥", "Mega Head"],
      armor_pierce:  ["🗡",  "Armor Pierce"],
      thorn_tail:    ["🌵", "Thorn Tail"],
      laser_charged: ["⚡", "Laser+"]
    }
    const TIER_COLOR = { 1: "#9090A8", 2: "#4A9EFF", 3: "#FFB800" }
    const LEGENDARY = type === "star" && tier === 3
    const PERMANENT = type === "thorn_tail" || type === "laser_charged"
    const [icon, name] = T[type] || ["✦", type]
    const color = LEGENDARY ? "#FF6BCC" : (PERMANENT ? "#FFD700" : (TIER_COLOR[tier] || "#9090A8"))
    return { icon, name, color, legendary: LEGENDARY, permanent: PERMANENT }
  },

  // Trigger a 1.6s reveal: 0.9s spinning emoji cycle, then 0.7s settle on
  // the actual prize with a tier-colored halo. Client knows the result up
  // front (server already applied it) — animation is purely cosmetic.
  _startGachaAnim(type, tier) {
    const info = this._gachaInfo(type, tier)
    this.gachaAnim = {
      start: performance.now(),
      spinDuration: 900,
      holdDuration: 700,
      finalIcon: info.icon,
      finalName: info.name,
      color: info.color,
      legendary: info.legendary,
      permanent: info.permanent
    }
    // Burst particles immediately at center for spin-up feedback
    for (let i = 0; i < 24; i++) {
      const a = Math.random() * Math.PI * 2
      const cx = this.cam.x, cy = this.cam.y
      this.particles.push({
        x: cx + Math.cos(a) * 30, y: cy + Math.sin(a) * 30,
        vx: Math.cos(a) * 3, vy: Math.sin(a) * 3,
        life: 30, color: info.color, size: 2.5
      })
    }
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

  fireLaser() {
    // Server enforces actual cooldown / cost / validity. We only debounce the
    // event push so a button-mash sends one event per ~250ms.
    const now = performance.now()
    if (this._lastLaserAt && now - this._lastLaserAt < 250) return
    this._lastLaserAt = now
    this.pushEvent("laser", {})
  },

  fireGacha() {
    // Server enforces min length + score. Local debounce stops mash-clicks.
    const now = performance.now()
    if (this._lastGachaAt && now - this._lastGachaAt < 400) return
    this._lastGachaAt = now
    this.pushEvent("gacha", {})
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

    // Drop pooled segment arrays for players who left so the cache doesn't leak.
    for (const id in this._rsegsCache) {
      if (!state.players[id]) delete this._rsegsCache[id]
    }

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
        case "lcharge": {
          // Someone is charging laser. Per-snake state for telegraph ring is
          // already in `lc` field; charge sound is played here.
          if (ev[1] === this.playerId) this.audio.play("powerup")
          break
        }
        case "lfire": {
          // ev = ["lfire", attacker_id, victim_id, hit_x, hit_y, severed_count]
          const [_, atk, vic, hx, hy, severed] = ev
          this.audio.play(atk === this.playerId ? "powerup" : "die", false)
          this.laserBeams.push({
            x0: state.players?.[atk]?.s?.[0]?.[0] ?? hx,
            y0: state.players?.[atk]?.s?.[0]?.[1] ?? hy,
            x1: hx, y1: hy,
            attacker: atk,
            until: now + 200
          })
          // Particle burst at hit point
          const color = vic ? (state.players?.[vic]?.c || "#FF66AA") : "#FF66AA"
          for (let i = 0; i < 16; i++) {
            this.particles.push({
              x: hx + (Math.random() - 0.5) * 8,
              y: hy + (Math.random() - 0.5) * 8,
              vx: (Math.random() - 0.5) * 5,
              vy: (Math.random() - 0.5) * 5,
              life: 24 + Math.random() * 16,
              color, size: 2 + Math.random() * 2.5
            })
          }
          if (vic === this.playerId && severed > 0) {
            this.flashBanner = { text: `−${severed} SEVERED`, color: "#FF3355", until: now + 1200 }
          }
          break
        }
        case "lblock": {
          // Shield absorbed the laser. Ring flash on victim.
          const [_, _atk, _vic, hx, hy] = ev
          for (let i = 0; i < 12; i++) {
            const a = (i / 12) * Math.PI * 2
            this.particles.push({
              x: hx, y: hy,
              vx: Math.cos(a) * 3, vy: Math.sin(a) * 3,
              life: 18, color: "#00FF87", size: 2
            })
          }
          break
        }
        case "larmor": {
          // Beam hit the armored head-side body. Visible "spark deflect" but
          // no damage. Tells the attacker they need to aim further back.
          const [_, atk, _vic, hx, hy] = ev
          if (atk === this.playerId) {
            this.flashBanner = {
              text: "ARMORED — aim for the tail",
              color: "#9090FF", until: now + 1100
            }
          }
          for (let i = 0; i < 10; i++) {
            const a = Math.random() * Math.PI * 2
            this.particles.push({
              x: hx, y: hy,
              vx: Math.cos(a) * 2.5, vy: Math.sin(a) * 2.5,
              life: 15, color: "#B0B0FF", size: 1.5
            })
          }
          break
        }
        case "gacha": {
          // ev = ["gacha", id, type, tier, ttl] — server already paid cost +
          // applied effect. Trigger the wheel animation only for self; others
          // get a small toast.
          const [_, gid, gtype, gtier, _gttl] = ev
          if (gid === this.playerId) {
            this.audio.play("powerup")
            this._startGachaAnim(gtype, gtier)
          }
          break
        }
        case "thorn": {
          // ev = ["thorn", victim, killer, segs_cut]
          const [_, _vic, atk, cut] = ev
          if (atk === this.playerId) {
            this.flashBanner = {
              text: `🌵 THORNED − ${cut} SEGS`,
              color: "#9CFF6B", until: now + 1400
            }
            this.audio.play("die", false)
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

    // Build interpolated segments per player (snap if segment counts differ — growth/death frame).
    // Re-use pooled [x,y] sub-arrays so a 250-segment x 5-snake frame doesn't churn 1k+
    // tiny allocations through GC.
    const rsegs = {}
    const cache = this._rsegsCache
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
          let pool = cache[id]
          if (!pool) pool = cache[id] = []
          while (pool.length < cs.length) pool.push([0, 0])
          pool.length = cs.length
          for (let i = 0; i < cs.length; i++) {
            const a = pool[i]
            a[0] = ps[i][0] + (cs[i][0] - ps[i][0]) * ialpha
            a[1] = ps[i][1] + (cs[i][1] - ps[i][1]) * ialpha
          }
          rsegs[id] = pool
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

    // BG — blit pre-rendered stars + ambient glow from cache. Replaces the
    // per-frame 400-star loop + 8-blob radial-gradient loop. ~8x faster on
    // typical hardware.
    if (this._bgCache) {
      const sx = camX - cx + this._bgOX
      const sy = camY - cy + this._bgOY
      // Source rect must stay inside the cache bounds; clip + base-fill any
      // overflow so we don't get a black bar when camera wanders to edges.
      ctx.fillStyle = "#05050C"
      ctx.fillRect(0, 0, W_CSS, H_CSS)
      const srcX = Math.max(0, sx)
      const srcY = Math.max(0, sy)
      const srcW = Math.min(this._bgW - srcX, W_CSS - (srcX - sx))
      const srcH = Math.min(this._bgH - srcY, H_CSS - (srcY - sy))
      if (srcW > 0 && srcH > 0) {
        const dstX = srcX - sx
        const dstY = srcY - sy
        ctx.drawImage(this._bgCache, srcX, srcY, srcW, srcH, dstX, dstY, srcW, srcH)
      }
    } else {
      ctx.fillStyle = "#05050C"; ctx.fillRect(0, 0, W_CSS, H_CSS)
    }

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

    // Food — batch by color, NO shadowBlur (use pre-rendered glow sprite).
    // World-space AABB cull first so off-screen items skip the screen-space
    // transform entirely. With 600 food items and a viewport showing ~80, this
    // drops 87% of the per-frame work.
    const foodGlow = this._glowCache?.food
    const goldenGlow = this._glowCache?.golden
    const fMinX = camX - cx - 10, fMaxX = camX + cx + 10
    const fMinY = camY - cy - 10, fMaxY = camY + cy + 10
    ctx.globalAlpha = 0.8
    for (const f of state.food) {
      const fx = f[0], fy = f[1]
      if (fx < fMinX || fx > fMaxX || fy < fMinY || fy > fMaxY) continue
      const fsx = fx - camX + cx, fsy = fy - camY + cy
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
      // Server marks far-away snakes oof: true and ships only their head.
      // Skip body/head paint entirely — minimap + leaderboard read separately.
      if (p.oof) continue
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

      // Body — split into ARMORED head-side (full alpha + thick) and
      // SEVERABLE tail (dimmer + thinner). Boundary index `ar` comes from
      // server, already adjusted for LOD downsampling. Severable region is
      // the only zone where lasers can cut.
      const armorIdx = Math.min(p.ar ?? Math.min(segs.length, 6 + (level - 1) * 3), segs.length)
      ctx.lineCap = "round"; ctx.lineJoin = "round"

      // Severable tail (drawn first, underneath head). Overlap one segment
      // with the armor zone so the line is visually continuous.
      if (segs.length > armorIdx && armorIdx > 0) {
        ctx.globalAlpha = alive ? (0.45 * invisAlpha) : 0.08
        ctx.strokeStyle = color
        ctx.lineWidth = r * 1.55
        ctx.beginPath()
        for (let i = armorIdx - 1; i < segs.length; i++) {
          const sx2 = toSx(segs[i][0]), sy2 = toSy(segs[i][1])
          if (i === armorIdx - 1) ctx.moveTo(sx2, sy2); else ctx.lineTo(sx2, sy2)
        }
        ctx.stroke()
      }

      // Armored head-side body — full thickness, optional level-flash white.
      ctx.globalAlpha = alive ? (0.92 * invisAlpha) : 0.12
      ctx.strokeStyle = levelFlash > 0.3 ? "#FFFFFF" : color
      ctx.lineWidth = r * 2
      ctx.beginPath()
      const armorEnd = Math.min(armorIdx, segs.length)
      for (let i = 0; i < armorEnd; i++) {
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
        // Head color shifts on active effect / boost — replaces the old shadowBlur
        // glow as effect feedback at zero perf cost. shadowBlur was the single
        // most expensive op per frame at high snake count.
        let gc = color
        if (effects.includes("star")) gc = "#E6DB74"
        else if (effects.includes("blade")) gc = "#FF4466"
        else if (effects.includes("freeze") || effects.includes("slowmo_target")) gc = "#66D9EF"
        else if (boosting) gc = "#00F0FF"
        ctx.fillStyle = gc
        ctx.beginPath(); ctx.arc(hsx, hsy, headR, 0, Math.PI * 2); ctx.fill()

        // Forward + perpendicular unit vectors for head accessories
        const fxv = Math.cos(angle), fyv = Math.sin(angle)
        const pxv = -fyv, pyv = fxv

        // Crown (Lv 15+) — golden spikes behind the eyes, drawn first so eyes overlay
        if (level >= 15) {
          ctx.fillStyle = level >= 25 ? "#FFD700" : "#C8A040"
          for (const i of [-1.2, -0.4, 0.4, 1.2]) {
            const baseX = hsx + fxv * (-headR * 0.45) + pxv * i * headR * 0.35
            const baseY = hsy + fyv * (-headR * 0.45) + pyv * i * headR * 0.35
            const tipX = baseX + fxv * (-headR * 0.65)
            const tipY = baseY + fyv * (-headR * 0.65)
            ctx.beginPath()
            ctx.moveTo(baseX - pxv * 1.5, baseY - pyv * 1.5)
            ctx.lineTo(baseX + pxv * 1.5, baseY + pyv * 1.5)
            ctx.lineTo(tipX, tipY)
            ctx.closePath()
            ctx.fill()
          }
        }

        // Horns (Lv 5+) — two short curved spikes
        if (level >= 5) {
          const hornLen = headR * (0.5 + Math.min(level - 5, 15) * 0.04)
          ctx.fillStyle = level >= 20 ? "#FFD700" : "#3A3A4A"
          for (const sign of [-1, 1]) {
            const baseX = hsx + fxv * (-headR * 0.1) + pxv * sign * headR * 0.7
            const baseY = hsy + fyv * (-headR * 0.1) + pyv * sign * headR * 0.7
            const tipX = baseX + fxv * (-hornLen * 0.4) + pxv * sign * hornLen * 0.7
            const tipY = baseY + fyv * (-hornLen * 0.4) + pyv * sign * hornLen * 0.7
            ctx.beginPath()
            ctx.moveTo(baseX - pxv * sign * headR * 0.18, baseY - pyv * sign * headR * 0.18)
            ctx.lineTo(baseX + pxv * sign * headR * 0.18, baseY + pyv * sign * headR * 0.18)
            ctx.lineTo(tipX, tipY)
            ctx.closePath()
            ctx.fill()
          }
        }

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

        // Tongue flick (Lv 10+) — animated red forked tongue extending from front
        if (level >= 10) {
          // Per-snake phase from id so all snakes don't flick in sync
          const phase = isMe ? 0 : ((id.charCodeAt(0) || 0) % 7) * 0.4
          const flick = Math.max(0, Math.sin(t * 4 + phase))
          if (flick > 0.1) {
            const tlen = headR * (0.4 + flick * 0.7)
            const baseX = hsx + fxv * headR * 0.95
            const baseY = hsy + fyv * headR * 0.95
            const tipX = baseX + fxv * tlen
            const tipY = baseY + fyv * tlen
            ctx.strokeStyle = "#FF3355"
            ctx.lineWidth = Math.max(1, headR * 0.15)
            ctx.lineCap = "round"
            ctx.beginPath()
            // Two-prong fork
            ctx.moveTo(baseX, baseY)
            ctx.lineTo(tipX + pxv * tlen * 0.25, tipY + pyv * tlen * 0.25)
            ctx.moveTo(baseX, baseY)
            ctx.lineTo(tipX - pxv * tlen * 0.25, tipY - pyv * tlen * 0.25)
            ctx.stroke()
          }
        }

        // Elder aura (Lv 30+) — slow rainbow ring
        if (level >= 30) {
          const auraR = headR * (1.85 + 0.15 * Math.sin(t * 3))
          ctx.strokeStyle = `hsla(${(t * 50) % 360}, 80%, 65%, 0.55)`
          ctx.lineWidth = 2
          ctx.beginPath(); ctx.arc(hsx, hsy, auraR, 0, Math.PI * 2); ctx.stroke()
        }

        // Laser charge telegraph — red expanding ring while lc > 0.
        // Visible to ALL players (gives victims a chance to dodge).
        const charge = p.lc || 0
        if (charge > 0) {
          // charge counts DOWN ticks; max is @laser_charge_ticks (4 in engine)
          const progress = 1 - charge / 4
          const ringR = headR * (1.4 + progress * 1.2)
          ctx.strokeStyle = "#FF3355"
          ctx.lineWidth = 2 + progress * 3
          ctx.globalAlpha = 0.4 + progress * 0.5
          ctx.beginPath(); ctx.arc(hsx, hsy, ringR, 0, Math.PI * 2); ctx.stroke()
          // Forward-pointing arc indicating direction
          ctx.strokeStyle = "#FF6688"
          ctx.lineWidth = 3
          ctx.beginPath()
          ctx.arc(hsx, hsy, ringR, angle - 0.5, angle + 0.5)
          ctx.stroke()
          ctx.globalAlpha = 1
        }

        // Shield rings — one stroke for all stacks. moveTo before each arc so
        // they don't lineTo into each other across the head.
        if (shieldStacks > 0) {
          ctx.strokeStyle = "#00FF87"
          ctx.lineWidth = 2
          ctx.globalAlpha = 0.4 + 0.3 * Math.sin(t * 5)
          ctx.beginPath()
          for (let s = 0; s < shieldStacks; s++) {
            const sr = headR * (1.5 + s * 0.35)
            ctx.moveTo(hsx + sr, hsy)
            ctx.arc(hsx, hsy, sr, 0, Math.PI * 2)
          }
          ctx.stroke()
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

    // Laser beams — bright pink line + outer glow, fades over 200ms
    if (this.laserBeams.length) {
      this.laserBeams = this.laserBeams.filter(b => {
        if (nowMs > b.until) return false
        const remaining = b.until - nowMs
        const a = Math.min(1, remaining / 200)
        const x0 = toSx(b.x0), y0 = toSy(b.y0)
        const x1 = toSx(b.x1), y1 = toSy(b.y1)
        // Outer glow
        ctx.globalAlpha = a * 0.4
        ctx.strokeStyle = "#FF66AA"
        ctx.lineWidth = 8
        ctx.lineCap = "round"
        ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); ctx.stroke()
        // Core
        ctx.globalAlpha = a
        ctx.strokeStyle = "#FFD0E5"
        ctx.lineWidth = 2.5
        ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); ctx.stroke()
        ctx.globalAlpha = 1
        return true
      })
      // Cap to prevent unbounded growth from rapid fire
      if (this.laserBeams.length > this.MAX_LASERS) {
        this.laserBeams.splice(0, this.laserBeams.length - this.MAX_LASERS)
      }
    }

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

    // Laser cooldown bar — placed just above boost bar so player sees readiness.
    if (me?.alive && state.players?.[this.playerId]) {
      const meRaw = state.players[this.playerId]
      const lcd = meRaw.lcd || 0    // ticks remaining of cooldown (0 = ready)
      const lc  = meRaw.lc  || 0    // ticks remaining of charge
      const bw = 100, bh = 4, bx2 = (W_CSS - bw) / 2, by2 = H_CSS - 38
      ctx.fillStyle = "rgba(6,6,16,0.5)"; ctx.fillRect(bx2 - 1, by2 - 1, bw + 2, bh + 2)
      // Cooldown progress (full when ready, drains as you fire)
      const ready = lcd === 0
      const fillRatio = ready ? 1 : 1 - lcd / 160   // matches @laser_cooldown=160
      ctx.fillStyle = lc > 0 ? "#FF3355" : (ready ? "#FF66AA" : "#552233")
      ctx.fillRect(bx2, by2, bw * fillRatio, bh)
      ctx.fillStyle = "#55556A"; ctx.font = "8px sans-serif"; ctx.textAlign = "center"
      const label = lc > 0 ? "CHARGING…" : (ready ? "LASER 👁 READY (V)" : `LASER ${(lcd * 0.05).toFixed(1)}s`)
      ctx.fillText(label, W_CSS / 2, by2 - 3)
    }

    // Stale-state overlay: server stopped sending broadcasts. Tells the user
    // the game is paused, not that their input is broken. LV will auto-reconnect.
    const staleMs = this.lastStateAt ? nowMs - this.lastStateAt : 0
    if (staleMs > 2500) {
      ctx.fillStyle = "rgba(6,6,16,0.55)"
      ctx.fillRect(0, 0, W_CSS, H_CSS)
      ctx.fillStyle = "#FFB800"
      ctx.font = "bold 28px sans-serif"
      ctx.textAlign = "center"
      ctx.shadowColor = "#FFB800"; ctx.shadowBlur = 16
      ctx.fillText("Reconnecting…", W_CSS / 2, H_CSS / 2 - 10)
      ctx.shadowBlur = 0
      ctx.font = "12px sans-serif"
      ctx.fillStyle = "#B0B0C8"
      const secs = Math.floor(staleMs / 1000)
      ctx.fillText(`No signal for ${secs}s — auto-reconnect in progress`, W_CSS / 2, H_CSS / 2 + 18)
    }

    // Gacha reveal — 0.9s spin, 0.7s hold. Final result is known at start
    // so the spin is pure cosmetic; we cycle through icons as a teaser.
    if (this.gachaAnim) {
      const ga = this.gachaAnim
      const elapsed = nowMs - ga.start
      const total = ga.spinDuration + ga.holdDuration
      if (elapsed > total) {
        this.gachaAnim = null
      } else {
        const spinning = elapsed < ga.spinDuration
        const cx2 = W_CSS / 2, cy2 = H_CSS * 0.42
        const panelW = 260, panelH = 130

        ctx.fillStyle = "rgba(6,6,16,0.85)"
        ctx.fillRect(cx2 - panelW / 2, cy2 - panelH / 2, panelW, panelH)
        ctx.strokeStyle = ga.color
        ctx.lineWidth = 3
        ctx.strokeRect(cx2 - panelW / 2, cy2 - panelH / 2, panelW, panelH)

        ctx.textAlign = "center"
        ctx.fillStyle = ga.color
        ctx.font = "bold 14px sans-serif"
        ctx.fillText("🎰  GACHA  🎰", cx2, cy2 - panelH / 2 + 22)

        // The big icon — cycles fast while spinning, settles on final.
        if (spinning) {
          const cycle = ["🧲", "🛡", "⭐", "👻", "⚔", "💥", "🗡", "🌵", "⚡"]
          const idx = Math.floor(elapsed / 70) % cycle.length
          ctx.font = "44px sans-serif"
          ctx.fillStyle = "#FFFFFF"
          ctx.fillText(cycle[idx], cx2, cy2 + 14)
        } else {
          // Hold: shake + glow on the final icon. legendary/permanent add a halo.
          const tHold = elapsed - ga.spinDuration
          const shake = Math.max(0, 1 - tHold / 200) * 4
          const dx = (Math.random() - 0.5) * shake
          const dy = (Math.random() - 0.5) * shake
          if (ga.legendary || ga.permanent) {
            ctx.shadowColor = ga.color
            ctx.shadowBlur = 30
          }
          ctx.font = "52px sans-serif"
          ctx.fillStyle = ga.color
          ctx.fillText(ga.finalIcon, cx2 + dx, cy2 + 18 + dy)
          ctx.shadowBlur = 0

          ctx.font = "bold 16px sans-serif"
          ctx.fillStyle = ga.color
          let label = ga.finalName
          if (ga.legendary) label = "★ LEGENDARY  " + label + "  ★"
          else if (ga.permanent) label = "PERMANENT  " + label
          ctx.fillText(label, cx2, cy2 + panelH / 2 - 12)
        }
      }
    }

    // Flash banner (streak / food rain / events / shutdown)
    if (this.flashBanner && nowMs < this.flashBanner.until) {
      const remaining = this.flashBanner.until - nowMs
      // Fade-out window: last 400ms ramps from 1→0; otherwise full alpha
      const a = remaining < 400 ? remaining / 400 : 1
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
