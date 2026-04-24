import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Game hooks
import SnakeCanvas from "./hooks/snake_canvas"

const Hooks = {
  SnakeCanvas,

  // TopBar scroll detection
  TopBarScroll: {
    mounted() {
      this.onScroll = () => {
        if (window.scrollY > 20) {
          this.el.classList.add("scrolled")
        } else {
          this.el.classList.remove("scrolled")
        }
      }
      window.addEventListener("scroll", this.onScroll, { passive: true })
    },
    destroyed() {
      window.removeEventListener("scroll", this.onScroll)
    }
  },

  // Splash PLAY button: save nickname and jump to /play
  PlayLauncher: {
    mounted() {
      const input = this.el.querySelector("#sio-name")
      const btn   = this.el.querySelector("#sio-play")
      if (!input || !btn) return

      // Pre-fill with saved name
      const saved = localStorage.getItem("wg_player_name") || ""
      if (saved) input.value = saved

      const launch = () => {
        const name = (input.value || "").trim().slice(0, 16)
        if (name) localStorage.setItem("wg_player_name", name)
        window.location.href = "/play"
      }

      btn.addEventListener("click", launch)
      input.addEventListener("keydown", (e) => {
        if (e.key === "Enter") { e.preventDefault(); launch() }
      })

      this._launch = launch
      this._btn = btn
      this._input = input
    },
    destroyed() {
      if (this._btn && this._launch) this._btn.removeEventListener("click", this._launch)
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks
})

// Progress bar
topbar.config({ barColors: { 0: "#00F0FF" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

liveSocket.connect()

window.liveSocket = liveSocket
