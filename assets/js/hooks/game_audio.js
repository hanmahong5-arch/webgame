export class GameAudio {
  constructor() {
    this.ctx = null
    this.enabled = true
    this.volume = 0.3
  }

  init() {
    if (this.ctx) return
    try {
      this.ctx = new (window.AudioContext || window.webkitAudioContext)()
    } catch (_e) {
      this.enabled = false
    }
  }

  play(sound, extra) {
    this.init()
    if (!this.ctx || !this.enabled) return
    if (this.ctx.state === "suspended") this.ctx.resume()

    const t = this.ctx.currentTime
    const v = this.volume
    switch (sound) {
      case "eat": this._eat(t, v, extra); break
      case "die": this._die(t, v, extra); break
      case "beep": this._beep(t, v); break
      case "start": this._start(t, v); break
      case "gameover": this._gameover(t, v); break
      case "powerup": this._powerup(t, v); break
      case "blade": this._blade(t, v); break
      case "shield": this._shield(t, v); break
    }
  }

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
  }

  _eat(t, v, golden) {
    const osc = this.ctx.createOscillator()
    const gain = this.ctx.createGain()
    osc.connect(gain).connect(this.ctx.destination)
    osc.type = "sine"
    const base = golden ? 660 : 440
    osc.frequency.setValueAtTime(base, t)
    osc.frequency.exponentialRampToValueAtTime(base * 2, t + 0.06)
    gain.gain.setValueAtTime(v * 0.4, t)
    gain.gain.exponentialRampToValueAtTime(0.001, t + 0.1)
    osc.start(t)
    osc.stop(t + 0.1)
    if (golden) {
      this._osc(880, "sine", 0.08, v * 0.2, t + 0.04)
      this._osc(1320, "sine", 0.06, v * 0.15, t + 0.07)
    }
  }

  _die(t, v, isSelf) {
    const dur = isSelf ? 0.5 : 0.2
    const vol = isSelf ? v * 0.8 : v * 0.3
    const len = Math.floor(this.ctx.sampleRate * dur)
    const buf = this.ctx.createBuffer(1, len, this.ctx.sampleRate)
    const data = buf.getChannelData(0)
    for (let i = 0; i < len; i++) {
      data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, 2)
    }
    const src = this.ctx.createBufferSource()
    src.buffer = buf
    const gain = this.ctx.createGain()
    gain.gain.setValueAtTime(vol, t)
    gain.gain.exponentialRampToValueAtTime(0.001, t + dur)
    src.connect(gain).connect(this.ctx.destination)
    src.start(t)
    if (isSelf) {
      this._osc(200, "sawtooth", 0.3, v * 0.2, t)
      this._osc(100, "sine", 0.4, v * 0.15, t + 0.1)
    }
  }

  _beep(t, v) { this._osc(440, "sine", 0.12, v * 0.5, t) }

  _start(t, v) {
    ;[440, 554, 660, 880].forEach((f, i) => {
      this._osc(f, "sine", 0.1, v * 0.3, t + i * 0.06)
    })
  }

  _gameover(t, v) {
    ;[440, 330, 220].forEach((f, i) => {
      this._osc(f, "sine", 0.25, v * 0.4, t + i * 0.12)
    })
  }

  _powerup(t, v) {
    ;[523, 659, 784, 1047].forEach((f, i) => {
      this._osc(f, "sine", 0.08, v * 0.25, t + i * 0.04)
    })
  }

  _blade(t, v) {
    this._osc(1200, "sawtooth", 0.08, v * 0.3, t)
    this._osc(800, "sawtooth", 0.1, v * 0.2, t + 0.05)
    const len = Math.floor(this.ctx.sampleRate * 0.1)
    const buf = this.ctx.createBuffer(1, len, this.ctx.sampleRate)
    const data = buf.getChannelData(0)
    for (let i = 0; i < len; i++) data[i] = (Math.random() * 2 - 1) * (1 - i / len)
    const src = this.ctx.createBufferSource()
    src.buffer = buf
    const gain = this.ctx.createGain()
    gain.gain.setValueAtTime(v * 0.3, t)
    gain.gain.exponentialRampToValueAtTime(0.001, t + 0.1)
    src.connect(gain).connect(this.ctx.destination)
    src.start(t)
  }

  _shield(t, v) {
    this._osc(330, "sine", 0.2, v * 0.3, t)
    this._osc(440, "sine", 0.15, v * 0.2, t + 0.1)
  }
}
