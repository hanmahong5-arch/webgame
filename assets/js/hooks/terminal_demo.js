/**
 * TerminalDemo — cycles through 3 AI models with typewriter streaming effect.
 * Pure CSS/JS animation, no backend calls required.
 * Demonstrates the core Lurus API value: one endpoint, all models.
 */

const MODELS = [
  {
    id: "deepseek-chat",
    label: "DeepSeek Chat",
    color: "#4A9EFF",
    response:
      "量子纠缠是两个粒子共享同一量子态的现象。测量一个粒子的状态，另一个粒子的状态会瞬间确定，与它们之间的距离无关。这是量子力学最反直觉、也最实用的特性之一。",
  },
  {
    id: "claude-3-5-sonnet-20241022",
    label: "Claude 3.5 Sonnet",
    color: "#B08EFF",
    response:
      '量子纠缠：两粒子形成不可分割的整体，对任意一个的测量会立即影响另一个的状态，无论相隔多远。爱因斯坦称之为「鬼魅般的超距作用」，如今已成为量子计算与量子密钥分发的核心资源。',
  },
  {
    id: "gemini-2.0-flash",
    label: "Gemini 2.0 Flash",
    color: "#7AFF89",
    response:
      "想象一对神奇骰子：无论相隔多远，一个骰子的点数确定后，另一个骰子的点数也瞬间确定，而且总是互补。量子纠缠的核心就是这种超越空间的瞬时关联，是未来量子互联网的基石。",
  },
]

const PROMPT = "用中文解释量子纠缠"
const TYPING_SPEED_MS = 22
const PAUSE_AFTER_MS = 2800
const FADE_MS = 350

export const TerminalDemo = {
  mounted() {
    this._idx = 0
    this._alive = true
    this._timer = null
    this._cycle()
  },

  destroyed() {
    this._alive = false
    clearTimeout(this._timer)
  },

  _q(sel) {
    return this.el.querySelector(sel)
  },

  _cycle() {
    if (!this._alive) return
    const model = MODELS[this._idx % MODELS.length]
    this._playScene(model, () => {
      if (!this._alive) return
      this._timer = setTimeout(() => {
        this._idx++
        this._fadeAndNext()
      }, PAUSE_AFTER_MS)
    })
  },

  _fadeAndNext() {
    if (!this._alive) return
    const responseEl = this._q("[data-response]")
    const cursorEl = this._q("[data-cursor]")

    if (responseEl) {
      responseEl.style.transition = `opacity ${FADE_MS}ms ease`
      responseEl.style.opacity = "0"
    }
    if (cursorEl) cursorEl.style.opacity = "0"

    this._timer = setTimeout(() => {
      if (!this._alive) return
      if (responseEl) {
        responseEl.textContent = ""
        responseEl.style.transition = ""
        responseEl.style.opacity = "1"
      }
      this._updateMeta()
      this._cycle()
    }, FADE_MS + 60)
  },

  _updateMeta() {
    const model = MODELS[this._idx % MODELS.length]
    const next = MODELS[(this._idx + 1) % MODELS.length]

    const labelEl = this._q("[data-model-label]")
    const nextEl = this._q("[data-next-model]")
    const dotEl = this._q("[data-model-dot]")
    const cmdEl = this._q("[data-command]")

    if (labelEl) {
      labelEl.textContent = model.label
      labelEl.style.color = model.color
    }
    if (nextEl) nextEl.textContent = next.label
    if (dotEl) dotEl.style.background = model.color
    if (cmdEl) {
      cmdEl.textContent =
        `$ curl api.lurus.cn/v1/chat \\\n  -H "Authorization: Bearer $KEY" \\\n  -d '{"model":"${model.id}"}'`
    }
  },

  _playScene(model, onDone) {
    const responseEl = this._q("[data-response]")
    const cursorEl = this._q("[data-cursor]")

    this._updateMeta()

    if (!responseEl) { onDone(); return }

    responseEl.textContent = ""
    if (cursorEl) cursorEl.style.opacity = "1"

    let i = 0
    const chars = model.response.split("")
    const tick = () => {
      if (!this._alive) return
      if (i < chars.length) {
        responseEl.textContent += chars[i++]
        this._timer = setTimeout(tick, TYPING_SPEED_MS)
      } else {
        if (cursorEl) {
          // Blink cursor when done
          cursorEl.style.animation = "cursor-blink 1s ease-in-out infinite"
        }
        onDone()
      }
    }
    // Brief pause before typing starts (feels more natural)
    this._timer = setTimeout(tick, 240)
  },
}
