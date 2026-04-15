# WebGame Frontend Performance Audit

**Date:** 2026-04-10
**Files audited:**
- `assets/js/hooks/snake_canvas.js`
- `assets/js/hooks/game_audio.js`
- `assets/css/app.css`

---

## 1. Canvas Performance

### 1.1 Unnecessary Redraws — Off-Screen Objects

**Finding: MEDIUM severity.** Food culling exists but is incomplete. The grid and border are always fully redrawn regardless of viewport. The grid drawing loop iterates every cell even when most of the world is off-screen.

Current food culling (correct approach, good):
```js
if (fsx < -10 || fsx > canvas.width + 10 || fsy < -10 || fsy > canvas.height + 10) continue
```

Problem: Snake segments are **not culled**. A snake with 200 segments that is mostly off-screen still strokes every segment:
```js
// Current: draws every segment regardless of visibility
for (let i = 0; i < segs.length; i++) {
  const [sx2, sy2] = toS(segs[i][0], segs[i][1])
  if (i === 0) ctx.moveTo(sx2, sy2); else ctx.lineTo(sx2, sy2)
}
ctx.stroke()
```

**Fix:** Clip the path to a screen-space bounding box before stroking, and skip completely off-screen snakes entirely:
```js
function isSegVisible(sx, sy, w, h, margin = SEG_R * 2) {
  return sx > -margin && sx < w + margin && sy > -margin && sy < h + margin
}

// In snake draw loop:
// Quick AABB check — if head is far off screen, skip entire snake
const [hsx, hsy] = toS(segs[0][0], segs[0][1])
const headOffScreen = hsx < -200 || hsx > canvas.width + 200 || hsy < -200 || hsy > canvas.height + 200
if (headOffScreen && !isMe) continue   // always draw own snake for edge cases

// Draw body with segment culling
ctx.beginPath()
let inPath = false
for (let i = 0; i < segs.length; i++) {
  const [sx2, sy2] = toS(segs[i][0], segs[i][1])
  const visible = isSegVisible(sx2, sy2, canvas.width, canvas.height)
  if (!visible) { inPath = false; continue }
  if (!inPath) { ctx.moveTo(sx2, sy2); inPath = true }
  else ctx.lineTo(sx2, sy2)
}
ctx.stroke()
```

---

### 1.2 shadowBlur — Excessive Usage

**Finding: HIGH severity.** `shadowBlur` is one of the most expensive canvas operations. The browser must apply a Gaussian blur kernel to the entire path bounding box each time it is set and a draw call is made. The current code uses it in three hot paths per frame:

| Location | Cost |
|---|---|
| Food loop (every food item, every frame) | `ctx.shadowBlur = 6` |
| Powerup loop (animated, `Math.sin` each frame) | `ctx.shadowBlur = 14 * (0.8 + 0.2 * Math.sin(t * 4))` |
| Snake head (every alive snake) | `ctx.shadowBlur = isMe ? 16 : 8` |

On a 60-player room with ~30 food items and 4 powerups, this is **35+ `save/restore` + shadowBlur cycles per frame**.

**Fix A — Eliminate food shadows, use a pre-rendered glow sprite instead:**
```js
// Build once at init, or on first use
function buildGlowSprite(color, radius, blur) {
  const size = (radius + blur) * 2 + 4
  const oc = new OffscreenCanvas(size, size)
  const octx = oc.getContext("2d")
  octx.shadowColor = color
  octx.shadowBlur = blur
  octx.fillStyle = color
  octx.beginPath()
  octx.arc(size / 2, size / 2, radius, 0, Math.PI * 2)
  octx.fill()
  return oc
}

// In mounted():
this.glowSprites = {
  food_normal: buildGlowSprite("#FF4466", 3, 6),
  food_golden: buildGlowSprite("#FFB800", 4, 8),
}

// In draw():
for (const f of state.food) {
  const [fx, fy, t] = f
  const [fsx, fsy] = toS(fx, fy)
  if (fsx < -10 || fsx > canvas.width + 10 || fsy < -10 || fsy > canvas.height + 10) continue
  const sprite = (t === 1 || t === "golden") ? this.glowSprites.food_golden : this.glowSprites.food_normal
  ctx.globalAlpha = 0.75
  ctx.drawImage(sprite, fsx - sprite.width / 2, fsy - sprite.height / 2)
  ctx.globalAlpha = 1
}
```

**Fix B — Batch all shadow draws to a dedicated layer (see 1.6 layered canvases).**

**Fix C — For snake head, only apply shadow to the player's own snake:**
```js
// Current: shadowBlur on every alive snake head
ctx.shadowColor = gc; ctx.shadowBlur = isMe ? 16 : 8   // expensive for all players

// Fixed: only self gets glow; other snakes skip it
if (isMe) {
  ctx.save()
  ctx.shadowColor = gc
  ctx.shadowBlur = 16
  ctx.fillStyle = color
  ctx.beginPath(); ctx.arc(hsx, hsy, r * 1.3, 0, Math.PI * 2); ctx.fill()
  ctx.restore()
} else {
  ctx.fillStyle = color
  ctx.beginPath(); ctx.arc(hsx, hsy, r * 1.3, 0, Math.PI * 2); ctx.fill()
}
```

---

### 1.3 Object Allocation in the Draw Loop (GC Pressure)

**Finding: HIGH severity.** Multiple transient allocations per frame drive GC pauses.

**Issue A — `toS()` returns a new array every call:**
```js
const toS = (wx, wy) => [wx - this.cam.x + cx, wy - this.cam.y + cy]
// Every segment: new 2-element array → destroyed next frame
```

**Fix:** Use a pre-allocated scratch object, mutated in place:
```js
// In mounted():
this._scratch = { x: 0, y: 0 }

// Replace toS:
toScreen(wx, wy) {
  this._scratch.x = wx - this.cam.x + this._cx
  this._scratch.y = wy - this.cam.y + this._cy
  return this._scratch
}
// Cache cx/cy at draw start:
this._cx = canvas.width / 2
this._cy = canvas.height / 2

// Usage (no destructuring — read .x/.y directly):
const s = this.toScreen(segs[i][0], segs[i][1])
ctx.lineTo(s.x, s.y)
```

**Issue B — `Object.entries(state.players)` creates a new entries array every frame:**
```js
for (const [id, p] of Object.entries(state.players))  // allocates array each frame
```

**Fix:**
```js
for (const id in state.players) {
  const p = state.players[id]
  // ...
}
```

**Issue C — Particle `filter` creates a new array each frame:**
```js
this.particles = this.particles.filter(...)  // new array every frame
```

**Fix:** Swap-delete in place (avoids allocation):
```js
let i = this.particles.length
while (i--) {
  const p = this.particles[i]
  p.x += p.vx; p.y += p.vy; p.vy += 0.02; p.life--
  if (p.life <= 0) {
    this.particles[i] = this.particles[this.particles.length - 1]
    this.particles.pop()
    continue
  }
  const s = this.toScreen(p.x, p.y)
  ctx.globalAlpha = Math.min(1, p.life / 12)
  ctx.fillStyle = p.color
  ctx.beginPath(); ctx.arc(s.x, s.y, p.size, 0, Math.PI * 2); ctx.fill()
}
ctx.globalAlpha = 1
```

**Issue D — Dead particle object pool:** instead of `push(new object)` on death events, recycle from a pool:
```js
// In mounted():
this._particlePool = Array.from({ length: 200 }, () => ({ x:0,y:0,vx:0,vy:0,life:0,color:"",size:0,active:false }))

spawnParticle(x, y, vx, vy, life, color, size) {
  const p = this._particlePool.find(p => !p.active)
  if (!p) return  // pool exhausted, skip gracefully
  Object.assign(p, { x, y, vx, vy, life, color, size, active: true })
  this.particles.push(p)
}

// On death:
for (let i = 0; i < 20; i++)
  this.spawnParticle(dx, dy, (Math.random()-0.5)*4, (Math.random()-0.5)*4, 30+Math.random()*20, dColor, 3+Math.random()*3)

// In loop: set p.active = false instead of removing
```

---

### 1.4 Path Batching — beginPath / stroke Cycles

**Finding: HIGH severity.** Every grid line is its own `beginPath()` + `stroke()` call. At a 40px grid on a 1920×1080 canvas that is ~75 vertical + ~48 horizontal = **123 stroke calls per frame just for the grid**.

**Fix A — Batch all grid lines into a single path:**
```js
// Grid: one beginPath, one stroke
ctx.strokeStyle = "rgba(255,255,255,0.02)"
ctx.lineWidth = 1
ctx.beginPath()
const gs = 40
const startX = Math.floor((this.cam.x - cx) / gs) * gs
const startY = Math.floor((this.cam.y - cy) / gs) * gs
for (let gx = startX; gx < this.cam.x + cx; gx += gs) {
  const x = gx - this.cam.x + cx
  ctx.moveTo(x, 0); ctx.lineTo(x, canvas.height)
}
for (let gy = startY; gy < this.cam.y + cy; gy += gs) {
  const y = gy - this.cam.y + cy
  ctx.moveTo(0, y); ctx.lineTo(canvas.width, y)
}
ctx.stroke()  // ONE stroke call for all grid lines
```

**Fix B — Batch all food circles of the same type into one path:**
```js
// Instead of per-food save/restore/fill, batch by color:
const normalFood = [], goldenFood = []
for (const f of state.food) {
  const [fx, fy, t] = f
  const [fsx, fsy] = toS(fx, fy)
  if (fsx < -10 || fsx > canvas.width + 10 || fsy < -10 || fsy > canvas.height + 10) continue
  if (t === 1 || t === "golden") goldenFood.push([fsx, fsy])
  else normalFood.push([fsx, fsy])
}

ctx.globalAlpha = 0.75
ctx.fillStyle = "#FF4466"
ctx.beginPath()
for (const [x, y] of normalFood) ctx.arc(x, y, 3, 0, Math.PI * 2)
ctx.fill()

ctx.fillStyle = "#FFB800"
ctx.beginPath()
for (const [x, y] of goldenFood) ctx.arc(x, y, 4, 0, Math.PI * 2)
ctx.fill()
ctx.globalAlpha = 1
```

**Fix C — Batch minimap dots:**
```js
// Current: one beginPath/fill per player in minimap
// Fixed: group by color (at minimum, one pass per snake color is fine for <20 players)
ctx.beginPath()
for (const id in state.players) {
  const p = state.players[id]
  const pSegs = p.s || p.segments
  if (!(p.al ?? p.alive) || !pSegs?.length) continue
  ctx.fillStyle = p.c || p.color  // color change forces flush anyway, acceptable here
  const mx2 = mx + pSegs[0][0] / W * mw
  const my2 = my + pSegs[0][1] / H * mh
  const r2 = id === this.playerId ? 3 : 2
  ctx.beginPath(); ctx.arc(mx2, my2, r2, 0, Math.PI * 2); ctx.fill()
}
```

---

### 1.5 OffscreenCanvas and Layered Canvases

**Recommendation:** Split into three canvas layers stacked absolutely:

| Layer | Canvas | Content | Redraw frequency |
|---|---|---|---|
| Background | `bg-canvas` | Grid, border | Only on resize or camera jump |
| Game | `game-canvas` (current) | Snakes, food, particles | Every frame |
| HUD | `hud-canvas` | Minimap, leaderboard, boost bar | Every frame but cheap |

The background grid is the biggest win: it does not change unless the camera moves more than one grid cell. Cache it in an OffscreenCanvas and blit it:

```js
// In mounted():
this.bgCanvas = new OffscreenCanvas(1, 1)
this.bgCtx = this.bgCanvas.getContext("2d")
this._lastCamCell = { x: null, y: null }

// In draw(), before grid:
const camCellX = Math.floor(this.cam.x / gs)
const camCellY = Math.floor(this.cam.y / gs)
if (camCellX !== this._lastCamCell.x || camCellY !== this._lastCamCell.y ||
    this.bgCanvas.width !== canvas.width || this.bgCanvas.height !== canvas.height) {
  this.bgCanvas.width = canvas.width
  this.bgCanvas.height = canvas.height
  this._rebuildBgGrid(cx, cy, gs)
  this._lastCamCell.x = camCellX
  this._lastCamCell.y = camCellY
}
ctx.drawImage(this.bgCanvas, 0, 0)  // blit cached grid

_rebuildBgGrid(cx, cy, gs) {
  const c = this.bgCtx
  c.clearRect(0, 0, this.bgCanvas.width, this.bgCanvas.height)
  c.strokeStyle = "rgba(255,255,255,0.02)"
  c.lineWidth = 1
  c.beginPath()
  // ... same batched grid logic ...
  c.stroke()
}
```

---

### 1.6 requestAnimationFrame Usage

**Finding: LOW severity, but structural issue.** The current loop is:
```js
loop() { this.draw(); this.raf = requestAnimationFrame(() => this.loop()) }
```

**Issue 1 — No frame throttling.** On a 144 Hz monitor, `draw()` runs 144 times/second. The server tick is likely 20-30 Hz. Rendering at 144 Hz on unchanged state wastes CPU/GPU.

**Issue 2 — Arrow function wrapper allocates a new closure each frame.** Use a bound method reference instead.

**Issue 3 — No visibility awareness.** When the tab is hidden, rAF pauses automatically, but the audio `resume()` call on the next state event will fire unnecessarily.

**Fix:**
```js
// In mounted():
this._loop = this._loopFn.bind(this)
this._lastFrameTime = 0
this._targetFPS = 60  // or read from config

// Replace loop():
_loopFn(timestamp) {
  this.raf = requestAnimationFrame(this._loop)
  const elapsed = timestamp - this._lastFrameTime
  if (elapsed < 1000 / this._targetFPS) return  // skip frame
  this._lastFrameTime = timestamp - (elapsed % (1000 / this._targetFPS))
  this.draw()
},

loop() {
  this.raf = requestAnimationFrame(this._loop)
},
```

---

## 2. Visual Quality

### 2.1 Snake Body Rendering — Stroke Path vs. Individual Circles

**Finding:** The current stroke-based path (`lineCap = "round"`, `lineWidth = r * 2`) produces good results for straight segments but creates visual artifacts at sharp turns — the round join at a tight angle produces a "kink" that looks unnatural.

**Assessment:** For a game with `SEG_R = 6` (12px wide body), the stroke approach is actually acceptable and more GPU-efficient than per-segment circles for long snakes. The joints issue only manifests at angles > 90°.

**Recommended improvement:** Add `lineJoin = "round"` (already present) and increase `miterLimit` — but the real fix is to inject intermediate control points using a Catmull-Rom spline on the server-sent waypoints for smoothing:

```js
function drawSmoothedBody(ctx, segs, toS) {
  if (segs.length < 2) return
  ctx.beginPath()
  const s0 = toS(segs[0][0], segs[0][1])  // use scratch object
  ctx.moveTo(s0.x, s0.y)
  for (let i = 1; i < segs.length - 1; i++) {
    const sa = toS(segs[i][0], segs[i][1])
    const sb = toS(segs[i+1][0], segs[i+1][1])
    // Quadratic bezier: control point at sa, endpoint at midpoint sa→sb
    const mx = (sa.x + sb.x) / 2
    const my = (sa.y + sb.y) / 2
    ctx.quadraticCurveTo(sa.x, sa.y, mx, my)
  }
  const last = toS(segs[segs.length-1][0], segs[segs.length-1][1])
  ctx.lineTo(last.x, last.y)
  ctx.stroke()
}
```

This eliminates kinks at bends with minimal extra math — no new allocations if `toS` reuses the scratch object.

---

### 2.2 Anti-Aliasing

**Finding:** The canvas has no explicit `imageSmoothingEnabled` setting or device pixel ratio (DPR) correction. On a Retina / 2× DPR screen, `canvas.width = parentWidth` in CSS pixels means the canvas renders at 50% of the display's native resolution, making the snake look blurry.

This is addressed in section 4.1 (Mobile / High-DPI). The fix there resolves anti-aliasing globally.

---

### 2.3 Color Contrast and Readability

**Finding: MEDIUM severity.**

| Issue | Location | Concern |
|---|---|---|
| `"#55556A"` on `"#060610"` background | Player name labels | Contrast ratio ~2.8:1 — fails WCAG AA (4.5:1 for small text) |
| Score text `"bold 9px"` | In-canvas leaderboard | 9px is below legibility threshold on most screens |
| Dead snakes at `globalAlpha = 0.12` | Snake body | Barely distinguishable from background |
| `"8px sans-serif"` | Leaderboard title "LEADERBOARD" | Very small |

**Fixes:**
```js
// Player name: use white with opacity instead of dark grey
ctx.fillStyle = alive ? "rgba(255,255,255,0.9)" : "rgba(255,255,255,0.3)"
ctx.font = `bold 11px sans-serif`  // up from computed max(9,10)=10px

// Leaderboard: increase font sizes
ctx.fillStyle = "#8899BB"  // was #55556A
ctx.font = "bold 9px sans-serif"  // was 8px
// Score entries:
ctx.font = "10px sans-serif"  // was 9px
```

---

### 2.4 Particle System Efficiency

**Finding:** Particles use `ctx.beginPath(); ctx.arc(); ctx.fill()` per particle. With 20 particles per death and potential cascading deaths, this can spike to 100+ individual fill calls.

Batching particles by opacity band (since `globalAlpha` changes per particle) is not feasible, but particles of the same color and similar alpha can share a single path via a sort-and-batch pass:

```js
// Sort particles by color before drawing
this.particles.sort((a, b) => a.color < b.color ? -1 : 1)

let lastColor = null, lastAlpha = -1
ctx.beginPath()
for (const p of this.particles) {
  const alpha = Math.min(1, p.life / 12)
  if (p.color !== lastColor || Math.abs(alpha - lastAlpha) > 0.1) {
    if (lastColor !== null) ctx.fill()  // flush previous batch
    ctx.globalAlpha = alpha
    ctx.fillStyle = p.color
    ctx.beginPath()
    lastColor = p.color
    lastAlpha = alpha
  }
  const s = this.toScreen(p.x, p.y)
  ctx.arc(s.x, s.y, p.size, 0, Math.PI * 2)
}
if (lastColor !== null) ctx.fill()
ctx.globalAlpha = 1
```

For <50 particles (typical), the overhead of sorting may not be worth it. Profiling is recommended before applying.

---

### 2.5 Food and Powerup Visual Hierarchy

**Finding: MEDIUM severity.** The player must visually distinguish:
- Normal food (3px red circle, alpha 0.75)
- Golden food (4px amber circle, alpha 0.75)
- 4 powerup types (12px outer circle + 7px inner + emoji icon)

**Issues:**
1. Normal food (3px) and golden food (4px) are nearly the same size — the 1px difference is very hard to perceive at typical viewing distances.
2. Powerup emoji icons (`⚔️`, `🛡️`, `🧲`, `⭐`) render as OS-native emoji which vary significantly by platform and some systems render them as colored images while others render as black outlines. This is unreliable.
3. No visual animation on food (powerups have `Math.sin` pulse, but food is static).

**Fixes:**
```js
// Food: use more distinct sizing
const normalR = 3, goldenR = 6  // was 3 vs 4
// Add a slow pulse to golden food
const goldenPulse = 1 + 0.15 * Math.sin(Date.now() / 300)
ctx.arc(fsx, fsy, golden ? goldenR * goldenPulse : normalR, 0, Math.PI * 2)

// Powerup: replace emoji with canvas-drawn symbols for cross-platform consistency
function drawPupIcon(ctx, type, x, y, r) {
  ctx.fillStyle = "#000"
  ctx.strokeStyle = "#000"
  ctx.lineWidth = 1.5
  ctx.lineCap = "round"
  switch(type) {
    case "blade":
      // Simple X shape
      ctx.beginPath()
      ctx.moveTo(x - r*0.5, y - r*0.5); ctx.lineTo(x + r*0.5, y + r*0.5)
      ctx.moveTo(x + r*0.5, y - r*0.5); ctx.lineTo(x - r*0.5, y + r*0.5)
      ctx.stroke(); break
    case "shield":
      // Shield outline
      ctx.beginPath()
      ctx.moveTo(x, y - r*0.6); ctx.lineTo(x + r*0.5, y - r*0.2)
      ctx.lineTo(x + r*0.5, y + r*0.2); ctx.lineTo(x, y + r*0.6)
      ctx.lineTo(x - r*0.5, y + r*0.2); ctx.lineTo(x - r*0.5, y - r*0.2)
      ctx.closePath(); ctx.stroke(); break
    case "magnet":
      ctx.beginPath()
      ctx.arc(x, y + r*0.1, r*0.45, Math.PI, 0)
      ctx.stroke()
      ctx.fillRect(x - r*0.5, y - r*0.4, r*0.2, r*0.5)
      ctx.fillRect(x + r*0.3, y - r*0.4, r*0.2, r*0.5); break
    case "star":
      // 4-point star
      for (let a = 0; a < Math.PI * 2; a += Math.PI / 2) {
        ctx.beginPath()
        ctx.moveTo(x, y)
        ctx.lineTo(x + Math.cos(a) * r*0.6, y + Math.sin(a) * r*0.6)
        ctx.stroke()
      }; break
  }
}
```

---

## 3. Client-Side Prediction

### 3.1 Current State Assessment

The renderer is a pure server-state mirror: every `game_state` event replaces `this.state` and the next `draw()` call reflects it. At a typical server tick of 20 Hz, each state arrives every 50ms. The player sees the snake "teleport" 50ms worth of movement per frame on a 60 Hz display — that is a visible stutter at high speed.

### 3.2 Recommended Architecture

Add a lightweight prediction layer that extrapolates the player's own snake head position between server ticks, while leaving all other snakes as pure server state.

**Step 1 — Store last confirmed server state and last-known velocity:**
```js
// In mounted():
this.serverState = null      // last confirmed state from server
this.predictedHead = null    // { x, y, angle } — extrapolated position
this.lastTickTime = 0        // performance.now() when last state arrived
this.tickInterval = 50       // estimate; update dynamically

// In onState():
onState(state) {
  const now = performance.now()
  if (this.lastTickTime > 0) {
    // Exponential moving average of tick interval
    this.tickInterval = this.tickInterval * 0.8 + (now - this.lastTickTime) * 0.2
  }
  this.lastTickTime = now
  this.serverState = state
  this.state = state  // keep as fallback
  // Reset prediction to confirmed position
  const me = this.getMe()
  if (me?.alive && me.segments.length) {
    this.predictedHead = {
      x: me.segments[0][0],
      y: me.segments[0][1],
      angle: me.angle
    }
  }
  // ... rest of existing onState logic ...
}
```

**Step 2 — Extrapolate head position in draw():**
```js
// In draw(), when calculating camera and drawing own snake head:
getInterpolatedHead() {
  if (!this.predictedHead || !this.serverState) return null
  const me = this.getMe()
  if (!me?.alive) return null

  const elapsed = performance.now() - this.lastTickTime
  const t = Math.min(elapsed / this.tickInterval, 1.5)  // cap at 1.5 ticks ahead

  // Extrapolate using current angle and speed (speed derived from segment spacing)
  const speed = me.boosting ? 5 : 3  // match server-side constants
  return {
    x: this.predictedHead.x + Math.cos(me.angle) * speed * t,
    y: this.predictedHead.y + Math.sin(me.angle) * speed * t,
  }
}
```

**Step 3 — Camera follows predicted head, not server head:**
```js
// In draw(), camera update section:
const predHead = this.getInterpolatedHead()
const camTarget = predHead || (me?.alive && me.segments.length ? { x: me.segments[0][0], y: me.segments[0][1] } : null)
if (camTarget) {
  this.cam.x += (camTarget.x - this.cam.x) * 0.12
  this.cam.y += (camTarget.y - this.cam.y) * 0.12
}
```

**Step 4 — Draw predicted head on top of server body:**
```js
// After drawing server body path, overdraw the head at predicted position:
if (isMe && predHead) {
  const [px, py] = toS(predHead.x, predHead.y)
  ctx.save()
  ctx.shadowColor = "#00F0FF"; ctx.shadowBlur = 16
  ctx.fillStyle = color
  ctx.globalAlpha = 1
  ctx.beginPath(); ctx.arc(px, py, r * 1.3, 0, Math.PI * 2); ctx.fill()
  ctx.restore()
}
```

### 3.3 Server Divergence Correction

When the server state differs from prediction by more than a threshold, snap or lerp back to server state:

```js
onState(state) {
  // ... existing code ...
  const me = this.getMe()
  if (me?.alive && me.segments.length && this.predictedHead) {
    const serverX = me.segments[0][0]
    const serverY = me.segments[0][1]
    const dx = serverX - this.predictedHead.x
    const dy = serverY - this.predictedHead.y
    const dist = Math.sqrt(dx*dx + dy*dy)
    if (dist > 20) {
      // Large divergence: hard snap
      this.predictedHead = { x: serverX, y: serverY, angle: me.angle }
    } else {
      // Small divergence: smooth blend (50% correction per tick)
      this.predictedHead.x += dx * 0.5
      this.predictedHead.y += dy * 0.5
    }
  }
}
```

### 3.4 Interpolation for Other Snakes

For remote snakes, interpolate between the previous and current server state rather than snapping:

```js
// In mounted():
this.prevState = null
this.interpT = 0

// In onState():
this.prevState = this.serverState ? JSON.parse(JSON.stringify(this.serverState)) : null
// (Use structured clone for non-JSON-safe data, but state is pure arrays/objects)

// In draw(), interpolation factor:
const elapsed = performance.now() - this.lastTickTime
this.interpT = Math.min(elapsed / this.tickInterval, 1)

// When drawing non-self snakes:
function getLerpedHead(id, t) {
  const cur = this.state.players[id]
  const prev = this.prevState?.players[id]
  if (!prev || !cur) return null
  const cs = cur.s || cur.segments
  const ps = prev.s || prev.segments
  if (!cs?.length || !ps?.length) return null
  return {
    x: ps[0][0] + (cs[0][0] - ps[0][0]) * t,
    y: ps[0][1] + (cs[0][1] - ps[0][1]) * t,
  }
}
```

---

## 4. Mobile Optimization

### 4.1 High-DPI Canvas (Retina / DPR)

**Finding: HIGH severity.** The current `resize()` sets canvas dimensions to CSS pixel dimensions:
```js
this.canvas.width = p.clientWidth
this.canvas.height = p.clientHeight
```
On a device with `devicePixelRatio = 2` (all modern phones, MacBook Retina), the canvas resolution is half the display resolution, making all text and circles visibly blurry.

**Fix — Scale canvas by DPR, then counter-scale the context:**
```js
resize() {
  const p = this.el.parentElement
  if (!p) return
  const dpr = window.devicePixelRatio || 1
  const cssW = p.clientWidth
  const cssH = p.clientHeight
  this.canvas.width = Math.round(cssW * dpr)
  this.canvas.height = Math.round(cssH * dpr)
  this.canvas.style.width = cssW + "px"
  this.canvas.style.height = cssH + "px"
  this.ctx.scale(dpr, dpr)
  this._dpr = dpr
  // Store CSS dimensions for coordinate math
  this._cssW = cssW
  this._cssH = cssH
},

// Update draw() to use this._cssW / this._cssH instead of canvas.width / canvas.height
// for all world-to-screen calculations (camera, toS, etc.)
// canvas.width / canvas.height are now physical pixels — only use for ctx.fillRect background clear
```

Note: after every resize, the context transform is reset to identity — the `ctx.scale(dpr, dpr)` must be reapplied. Track this with a `this._dprApplied` flag or call it at the top of `draw()` if the context was reset.

---

### 4.2 Touch Event Handling Efficiency

**Finding: LOW severity.** Touch events are implemented correctly with `passive: false` only on `touchmove` (preventing scroll, which is correct). There are three issues:

1. **`sendSteer()` called on every `touchmove` without throttling.** On mobile at 60 touch events/second, this pushes 60 LiveView events/second to the server. The server likely only processes ~20 Hz.

2. **Touch coordinate reading allocates no objects** (good — uses `.clientX/Y` directly).

3. **Two-finger boost detection uses `e.touches.length >= 2`** on `touchstart` but `< 2` on `touchend` — this is correct.

**Fix — Throttle `sendSteer` to match server tick rate:**
```js
// In mounted():
this._lastSteerSent = 0
this._steerThrottle = 50  // ms — match server tick interval

sendSteer() {
  const now = performance.now()
  if (now - this._lastSteerSent < this._steerThrottle) return
  this._lastSteerSent = now
  const me = this.getMe()
  if (!me?.alive || !me.segments.length) return
  const [hx, hy] = me.segments[0]
  const sx = (hx - this.cam.x) + this._cssW / 2
  const sy = (hy - this.cam.y) + this._cssH / 2
  const angle = Math.atan2(this.mouse.y - sy, this.mouse.x - sx)
  this.pushEvent("steer", { angle })
},
```

---

### 4.3 Reducing Draw Calls for Mobile GPU

Mobile GPUs have significantly lower throughput for state changes (fillStyle, globalAlpha, shadowBlur). The batching fixes in section 1.4 are the primary wins. Additional mobile-specific optimizations:

```js
// Detect mobile at init:
this.isMobile = /Android|iPhone|iPad/i.test(navigator.userAgent) || window.innerWidth < 768

// In draw(): skip shadow effects entirely on mobile
const useShadow = !this.isMobile

// Skip particle rendering on mobile when count is high:
const maxParticles = this.isMobile ? 20 : 100
if (this.particles.length > maxParticles) {
  this.particles.length = maxParticles  // truncate oldest
}

// Reduce grid density on mobile:
const gs = this.isMobile ? 80 : 40

// Skip name labels for non-self snakes on mobile (text is expensive):
if (!this.isMobile || isMe) {
  ctx.fillText(name + ..., hsx, hsy - r * 2.5)
}
```

---

### 4.4 Virtual Joystick for Mobile

**Recommendation:** The current touch control (aim at touch position) requires two-handed use and is unintuitive for mobile-first users. A virtual joystick provides better ergonomics.

**Implementation on a separate HUD canvas layer:**
```js
// State:
this.joystick = {
  active: false,
  baseX: 0, baseY: 0,    // where finger first touched
  curX: 0, curY: 0,       // current finger position
  maxR: 50,               // joystick radius in CSS px
  touchId: null,
}

// Touch handlers:
this.canvas.addEventListener("touchstart", (e) => {
  // Only activate joystick in left half of screen
  const t = e.changedTouches[0]
  if (t.clientX < this._cssW / 2) {
    this.joystick = { ...this.joystick, active: true, baseX: t.clientX, baseY: t.clientY, curX: t.clientX, curY: t.clientY, touchId: t.identifier }
    e.preventDefault()
    return
  }
  // Right half = existing boost logic
}, { passive: false })

this.canvas.addEventListener("touchmove", (e) => {
  if (!this.joystick.active) return
  for (const t of e.changedTouches) {
    if (t.identifier !== this.joystick.touchId) continue
    this.joystick.curX = t.clientX
    this.joystick.curY = t.clientY
    // Compute angle from joystick delta and steer
    const dx = this.joystick.curX - this.joystick.baseX
    const dy = this.joystick.curY - this.joystick.baseY
    if (Math.sqrt(dx*dx + dy*dy) > 5) {
      // Override mouse direction with joystick angle
      const me = this.getMe()
      if (me?.alive && me.segments.length) {
        const angle = Math.atan2(dy, dx)
        this.pushEvent("steer", { angle })
      }
    }
  }
}, { passive: false })

// Draw joystick in draw() (or on separate canvas):
drawJoystick() {
  if (!this.joystick.active || !this.isMobile) return
  const { baseX, baseY, curX, curY, maxR } = this.joystick
  const dx = curX - baseX, dy = curY - baseY
  const dist = Math.min(Math.sqrt(dx*dx + dy*dy), maxR)
  const angle = Math.atan2(dy, dx)
  const stickX = baseX + Math.cos(angle) * dist
  const stickY = baseY + Math.sin(angle) * dist
  const ctx = this.ctx
  // Base ring
  ctx.strokeStyle = "rgba(255,255,255,0.2)"
  ctx.lineWidth = 2
  ctx.beginPath(); ctx.arc(baseX, baseY, maxR, 0, Math.PI * 2); ctx.stroke()
  // Stick knob
  ctx.fillStyle = "rgba(255,255,255,0.4)"
  ctx.beginPath(); ctx.arc(stickX, stickY, 22, 0, Math.PI * 2); ctx.fill()
}
```

---

## 5. Audio System

### 5.1 Web Audio API Usage Review

The overall structure is sound: `AudioContext` is lazy-initialized on first user interaction, and the `suspended` state is handled by calling `resume()`. However, there are several correctness and performance issues.

---

### 5.2 Oscillator Proliferation

**Finding: HIGH severity.** Every call to `_osc()` creates a new `OscillatorNode` + `GainNode`, connects them, starts and stops them. These nodes are **never explicitly disconnected** after they finish.

A rapid eat sequence (e.g., magnet powerup pulling food at 10 items/second) creates 10+ oscillator pairs per second. While the browser's GC eventually collects stopped nodes, the audio graph can accumulate hundreds of nodes between collections, causing memory pressure and occasional audio dropouts.

**Fix — Disconnect nodes after they stop:**
```js
_osc(freq, type, duration, vol, t) {
  const osc = this.ctx.createOscillator()
  const gain = this.ctx.createGain()
  osc.connect(gain).connect(this.ctx.destination)
  osc.type = type
  osc.frequency.setValueAtTime(freq, t)
  gain.gain.setValueAtTime(vol, t)
  gain.gain.exponentialRampToValueAtTime(0.001, t + duration)
  osc.start(t)
  osc.stop(t + duration)
  osc.onended = () => { osc.disconnect(); gain.disconnect() }  // ADD THIS
},
```

Same fix must be applied in `_eat()`, `_blade()`, and `_die()` where nodes are created inline without using `_osc()`.

---

### 5.3 Pre-Generated AudioBuffer for Common Sounds

**Finding: HIGH severity.** The `_die()` function generates white noise using a manual sample-filling loop every time it is called:

```js
// Current: allocates buffer + fills all samples on every death event
const len = Math.floor(this.ctx.sampleRate * dur)  // e.g. 22050 samples for 0.5s
const buf = this.ctx.createBuffer(1, len, this.ctx.sampleRate)
const data = buf.getChannelData(0)
for (let i = 0; i < len; i++) {
  data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, 2)
}
```

This allocates ~88KB of Float32Array and runs 22,050 iterations of Math.random() on the main thread, synchronously, inside a game state handler. If multiple players die simultaneously, this stalls the frame.

Similarly `_blade()` generates noise inline.

**Fix — Pre-bake AudioBuffers at init time and reuse them:**
```js
// In init() — called once after AudioContext is created:
init() {
  if (this.ctx) return
  try {
    this.ctx = new (window.AudioContext || window.webkitAudioContext)()
    this._prebakeBuffers()
  } catch (_e) {
    this.enabled = false
  }
},

_prebakeBuffers() {
  const sr = this.ctx.sampleRate
  // Bake self-death noise (0.5s)
  this._noiseSelf = this._buildNoise(sr, 0.5, (i, len) => (Math.random()*2-1) * Math.pow(1 - i/len, 2))
  // Bake other-death noise (0.2s)
  this._noiseOther = this._buildNoise(sr, 0.2, (i, len) => (Math.random()*2-1) * Math.pow(1 - i/len, 2))
  // Bake blade noise (0.1s)
  this._noiseBlade = this._buildNoise(sr, 0.1, (i, len) => (Math.random()*2-1) * (1 - i/len))
},

_buildNoise(sr, dur, sampleFn) {
  const len = Math.floor(sr * dur)
  const buf = this.ctx.createBuffer(1, len, sr)
  const data = buf.getChannelData(0)
  for (let i = 0; i < len; i++) data[i] = sampleFn(i, len)
  return buf  // immutable — safe to reuse as many times as needed
},

// In _die(): use pre-baked buffer
_die(t, v, isSelf) {
  const dur = isSelf ? 0.5 : 0.2
  const vol = isSelf ? v * 0.8 : v * 0.3
  const buf = isSelf ? this._noiseSelf : this._noiseOther
  if (!buf) return
  const src = this.ctx.createBufferSource()
  src.buffer = buf  // reuse, no allocation
  const gain = this.ctx.createGain()
  gain.gain.setValueAtTime(vol, t)
  gain.gain.exponentialRampToValueAtTime(0.001, t + dur)
  src.connect(gain).connect(this.ctx.destination)
  src.start(t)
  src.onended = () => { src.disconnect(); gain.disconnect() }
  if (isSelf) {
    this._osc(200, "sawtooth", 0.3, v * 0.2, t)
    this._osc(100, "sine", 0.4, v * 0.15, t + 0.1)
  }
},
```

---

### 5.4 AudioContext State Management on Mobile

**Finding: MEDIUM severity.** Mobile browsers (iOS Safari, Android Chrome) suspend the `AudioContext` not only at page load but also after any period of inactivity (tab switch, screen lock, incoming call). The current `resume()` call in `play()` handles the initial suspension but may not handle re-suspension after background:

```js
// Current:
if (this.ctx.state === "suspended") this.ctx.resume()
```

This is correct as a reactive fix. The additional issue is that `resume()` returns a Promise, and the audio is scheduled using `this.ctx.currentTime` synchronously — but if the AudioContext is suspended, `currentTime` stops advancing. Scheduling `osc.start(t)` where `t = ctx.currentTime` before the context resumes can result in the sound playing at `t=0` (immediately) or being missed.

**Fix — Await resume before scheduling, with fallback:**
```js
async play(sound, extra) {
  this.init()
  if (!this.ctx || !this.enabled) return
  if (this.ctx.state === "suspended") {
    try { await this.ctx.resume() } catch (_e) { return }
  }
  if (this.ctx.state !== "running") return  // still not running (e.g. browser blocked)
  const t = this.ctx.currentTime
  const v = this.volume
  switch (sound) {
    // ... same switch ...
  }
},
```

---

### 5.5 Volume Control and Mute Support

**Finding:** There is no master gain node and no user-accessible mute/volume control. Adding a single master gain node costs nothing and enables future volume slider support without refactoring all sound methods:

```js
init() {
  if (this.ctx) return
  try {
    this.ctx = new (window.AudioContext || window.webkitAudioContext)()
    this.masterGain = this.ctx.createGain()
    this.masterGain.gain.setValueAtTime(this.volume, this.ctx.currentTime)
    this.masterGain.connect(this.ctx.destination)
    this._prebakeBuffers()
  } catch (_e) {
    this.enabled = false
  }
},

// Update _osc() to connect to masterGain instead of destination:
osc.connect(gain).connect(this.masterGain)

// Volume/mute API:
setVolume(v) {
  this.volume = Math.max(0, Math.min(1, v))
  if (this.masterGain) this.masterGain.gain.setValueAtTime(this.volume, this.ctx.currentTime)
},

mute() { this.setVolume(0) },
unmute() { this.setVolume(0.3) },
```

---

## 6. CSS / app.css Review

### 6.1 `backdrop-filter: blur()` Usage

**Finding:** `backdrop-filter: blur()` is used on the topbar, room badge, hud buttons, overlay cards, game panels, and respawn card. On mobile, `backdrop-filter` triggers GPU compositing layers and is one of the most expensive CSS effects. On some Android devices it is disabled by the browser entirely.

**Recommendation:** Gate it on capability and performance:
```css
@supports (backdrop-filter: blur(1px)) {
  .game-topbar { backdrop-filter: blur(12px); }
  .game-overlay { backdrop-filter: blur(4px); }
  /* etc. */
}

@media (prefers-reduced-motion: reduce) {
  .game-topbar { backdrop-filter: none; }
}
```

For the game-specific elements (`.room-badge`, `.hud-btn`), consider replacing `backdrop-filter` with a solid semi-transparent background: `background: rgba(10,10,15,0.92)` — visually near-identical on a dark game canvas, no compositing cost.

### 6.2 `transition: all 0.15s ease` Anti-Pattern

**Finding:** Line 1911:
```css
a, button { transition: all 0.15s ease; }
```

`transition: all` triggers transitions on **every** animatable property, including `width`, `height`, `max-height`, `padding`, and layout properties. This can cause unexpected janky transitions when layout changes occur (e.g., when the leaderboard updates player count). It also makes it impossible for the browser to optimize which properties to composite.

**Fix:** Replace with explicit properties:
```css
a, button { transition: color 0.15s ease, background-color 0.15s ease, border-color 0.15s ease, opacity 0.15s ease, transform 0.1s ease; }
```

### 6.3 `will-change` for Animated Elements

The hero badge dot and showcase food items are CSS-animated. Adding `will-change: transform, opacity` to animated elements promotes them to their own compositor layer, preventing them from triggering main-thread paint invalidation:

```css
.hero-badge-dot { will-change: transform, opacity; }
.showcase-food { will-change: transform, opacity; }
.showcase-snake { will-change: transform; }
```

Do **not** apply `will-change` to elements that are not actually animating (like `.step-card`) as this wastes GPU memory.

### 6.4 Font Loading

**Finding:** The font stack in `body` includes `'Noto Sans SC'` (a large CJK font) but there is no `@font-face` rule or `<link rel="preload">` in the CSS. If this font is served by the platform, it should be preloaded. If it is expected to fall back to the system stack (which it will on non-Chinese systems), the declaration is harmless but misleading.

---

## 7. Priority Summary

| Priority | Issue | File | Estimated impact |
|---|---|---|---|
| P0 | DPR / Retina canvas resolution fix | snake_canvas.js | All mobile/retina users see blurry game |
| P0 | shadowBlur on food + every snake head | snake_canvas.js | 5-15ms/frame on mid-range mobile |
| P0 | Pre-bake noise AudioBuffers | game_audio.js | Eliminates main-thread stall on death |
| P1 | Grid: single batched stroke | snake_canvas.js | ~120 draw calls → 1 per frame |
| P1 | Food: batched by color | snake_canvas.js | ~50 draw calls → 2 per frame |
| P1 | toS() scratch object (no array allocation) | snake_canvas.js | Reduces GC pressure at 60fps |
| P1 | Object.entries → for..in | snake_canvas.js | Small but zero-cost fix |
| P1 | Oscillator disconnect on end | game_audio.js | Prevents audio graph node leak |
| P2 | Client-side head prediction | snake_canvas.js | Eliminates 50ms stutter feel |
| P2 | steer event throttling (touch) | snake_canvas.js | Reduces unnecessary server events |
| P2 | particles: swap-delete pool | snake_canvas.js | Eliminates per-frame array alloc |
| P2 | AudioContext async resume | game_audio.js | Fixes audio timing on mobile |
| P2 | Master gain node | game_audio.js | Enables future volume control |
| P3 | Quadratic bezier snake body | snake_canvas.js | Smoother curves at bends |
| P3 | Canvas-drawn powerup icons | snake_canvas.js | Cross-platform consistency |
| P3 | OffscreenCanvas bg layer | snake_canvas.js | Eliminates grid redraw every frame |
| P3 | Virtual joystick (mobile) | snake_canvas.js | Better mobile UX |
| P3 | `transition: all` → explicit | app.css | Prevents unexpected layout transitions |
| P3 | `backdrop-filter` guard | app.css | Mobile GPU saving |
