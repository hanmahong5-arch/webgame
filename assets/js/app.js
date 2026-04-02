import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// JS Hooks
import ScrollReveal from "./hooks/scroll_reveal"
import CountUp from "./hooks/count_up"
import MouseGlow from "./hooks/mouse_glow"
import ParticleField from "./hooks/particle_field"
import Marquee from "./hooks/marquee"

const Hooks = {
  ScrollReveal,
  CountUp,
  MouseGlow,
  ParticleField,
  Marquee,

  // TopBar scroll detection
  TopBarScroll: {
    mounted() {
      this.onScroll = () => {
        if (window.scrollY > 20) {
          this.el.style.backgroundColor = "rgba(13, 11, 9, 0.95)"
          this.el.style.borderBottomColor = "var(--color-surface-border)"
        } else {
          this.el.style.backgroundColor = "rgba(13, 11, 9, 0.85)"
          this.el.style.borderBottomColor = "transparent"
        }
      }
      window.addEventListener("scroll", this.onScroll, { passive: true })
    },
    destroyed() {
      window.removeEventListener("scroll", this.onScroll)
    }
  },

  // Dropdown menu hover behavior
  DropdownMenu: {
    mounted() {
      const trigger = this.el.querySelector("[data-dropdown-trigger]")
      const panel = this.el.querySelector("[data-dropdown-panel]")
      let closeTimer = null

      const open = () => {
        if (closeTimer) { clearTimeout(closeTimer); closeTimer = null }
        panel.classList.remove("hidden")
      }

      const scheduleClose = () => {
        closeTimer = setTimeout(() => panel.classList.add("hidden"), 160)
      }

      this.el.addEventListener("mouseenter", open)
      this.el.addEventListener("mouseleave", scheduleClose)
      panel.addEventListener("mouseenter", open)
      panel.addEventListener("mouseleave", scheduleClose)

      // Keyboard support
      trigger.addEventListener("click", () => {
        panel.classList.toggle("hidden")
      })

      document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") panel.classList.add("hidden")
      })
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks
})

// Show progress bar on live navigation
topbar.config({ barColors: { 0: "#D4A827" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

liveSocket.connect()

window.liveSocket = liveSocket
