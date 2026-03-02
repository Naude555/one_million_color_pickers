const InfiniteScroll = {
  mounted() {
    this.loading = false
    this.ticking = false
    this.lastDirection = null

    this.triggerLoad = direction => {
      if (this.loading) return
      this.loading = true
      this.lastDirection = direction
      this.pushEvent(direction === "down" ? "load-more-down" : "load-more-up", {})
    }

    this.maybeTriggerLoad = () => {
      if (this.loading) return

      const scrollRange = this.el.scrollHeight - this.el.clientHeight
      if (scrollRange <= 0) return

      const ratio = this.el.scrollTop / scrollRange

      if (ratio >= 0.72) {
        this.triggerLoad("down")
      } else if (ratio <= 0.28) {
        this.triggerLoad("up")
      }
    }

    this.onPageLoaded = ({ direction }) => {
      this.loading = false

      const minOffset = 320
      if (direction === "down") {
        this.el.scrollTop = minOffset
      } else if (direction === "up") {
        this.el.scrollTop = Math.max(this.el.scrollHeight - this.el.clientHeight - minOffset, minOffset)
      } else {
        this.el.scrollTop = Math.max((this.el.scrollHeight - this.el.clientHeight) / 2, 0)
      }

      // If the user scrolled aggressively, chain-load another page immediately.
      this.maybeTriggerLoad()
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
