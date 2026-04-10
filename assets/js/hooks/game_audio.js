export class GameAudio {
  constructor() {
    this.ctx = null
    this.enabled = true
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
    switch (sound) {
      case "eat": this._eat(t, extra); break
      case "die": this._die(t, extra); break
      case "beep": this._beep(t); break
      case "start": this._start(t); break
      case "gameover": this._gameover(t); break
    }
  }

  _osc(freq, type, duration, volume, t) {
    const osc = this.ctx.createOscillator()
    const gain = this.ctx.createGain()
    osc.connect(gain).connect(this.ctx.destination)
    osc.type = type
    osc.frequency.setValueAtTime(freq, t)
    gain.gain.setValueAtTime(volume, t)
    gain.gain.exponentialRampToValueAtTime(0.001, t + duration)
    osc.start(t)
    osc.stop(t + duration)
  }

  _eat(t, golden) {
    const osc = this.ctx.createOscillator()
    const gain = this.ctx.createGain()
    osc.connect(gain).connect(this.ctx.destination)
    osc.type = "sine"
    osc.frequency.setValueAtTime(golden ? 660 : 440, t)
    osc.frequency.exponentialRampToValueAtTime(golden ? 1320 : 880, t + 0.08)
    gain.gain.setValueAtTime(0.12, t)
    gain.gain.exponentialRampToValueAtTime(0.001, t + 0.12)
    osc.start(t)
    osc.stop(t + 0.12)
  }

  _die(t, isSelf) {
    const dur = isSelf ? 0.4 : 0.2
    const vol = isSelf ? 0.25 : 0.08
    const len = Math.floor(this.ctx.sampleRate * dur)
    const buf = this.ctx.createBuffer(1, len, this.ctx.sampleRate)
    const data = buf.getChannelData(0)
    for (let i = 0; i < len; i++) {
      data[i] = (Math.random() * 2 - 1) * (1 - i / len)
    }
    const src = this.ctx.createBufferSource()
    src.buffer = buf
    const gain = this.ctx.createGain()
    gain.gain.setValueAtTime(vol, t)
    gain.gain.exponentialRampToValueAtTime(0.001, t + dur)
    src.connect(gain).connect(this.ctx.destination)
    src.start(t)
  }

  _beep(t) {
    this._osc(440, "sine", 0.15, 0.15, t)
  }

  _start(t) {
    ;[440, 554, 660, 880].forEach((f, i) => {
      this._osc(f, "sine", 0.12, 0.1, t + i * 0.07)
    })
  }

  _gameover(t) {
    ;[440, 330, 220].forEach((f, i) => {
      this._osc(f, "sine", 0.25, 0.12, t + i * 0.12)
    })
  }
}
