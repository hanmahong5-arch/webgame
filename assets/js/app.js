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
