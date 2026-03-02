const InfiniteScroll = {
  mounted() {
    this.loading = false
    this.ticking = false

    this.triggerLoad = direction => {
      if (this.loading) return
      this.loading = true
      this.pushEvent(direction === "down" ? "load-more-down" : "load-more-up", {})
    }

    this.maybeTriggerLoad = () => {
      if (this.loading) return

      const scrollRange = this.el.scrollHeight - this.el.clientHeight
      if (scrollRange <= 0) return

      const ratio = this.el.scrollTop / scrollRange

      if (ratio >= 0.82) {
        this.triggerLoad("down")
      } else if (ratio <= 0.18) {
        this.triggerLoad("up")
      }
    }

    this.onPageLoaded = ({ direction }) => {
      this.loading = false

      const edgeBuffer = 260

      if (direction === "down") {
        this.el.scrollTop = edgeBuffer
      } else if (direction === "up") {
        this.el.scrollTop = Math.max(this.el.scrollHeight - this.el.clientHeight - edgeBuffer, edgeBuffer)
      } else {
        this.el.scrollTop = Math.max((this.el.scrollHeight - this.el.clientHeight) / 2, 0)
      }
    }

    this.handleEvent("page-loaded", this.onPageLoaded)

    this.scrollHandler = () => {
      if (this.ticking) return
      this.ticking = true

      requestAnimationFrame(() => {
        this.maybeTriggerLoad()
        this.ticking = false
      })
    }

    this.el.addEventListener("scroll", this.scrollHandler, { passive: true })
  },

  destroyed() {
    this.el.removeEventListener("scroll", this.scrollHandler)
  }
}

export default InfiniteScroll
