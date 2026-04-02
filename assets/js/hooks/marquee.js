// Auto-scrolling marquee for partner logos
const Marquee = {
  mounted() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    // Duplicate content for seamless loop
    const inner = this.el.querySelector("[data-marquee-inner]")
    if (inner && !inner.dataset.cloned) {
      inner.innerHTML += inner.innerHTML
      inner.dataset.cloned = "true"
    }
  }
}

export default Marquee
