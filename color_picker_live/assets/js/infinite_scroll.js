const InfiniteScroll = {
  mounted() {
    this.loading = false
    this.ticking = false
    this.lastScrollTop = this.el.scrollTop
    this.suppressTriggersUntil = 0
    this.edgeLock = { up: false, down: false }
    this.pendingScrollTop = this.el.scrollTop
    this.pendingDistanceFromBottom = 0

    this.triggerLoad = direction => {
      if (this.loading) return

      const distanceFromBottom = this.el.scrollHeight - this.el.clientHeight - this.el.scrollTop
      this.pendingScrollTop = this.el.scrollTop
      this.pendingDistanceFromBottom = Math.max(distanceFromBottom, 0)

      this.loading = true
      this.pushEvent(direction === "down" ? "load-more-down" : "load-more-up", {})
    }

    this.updateEdgeLocks = ({ nearTop, nearBottom }) => {
      if (!nearTop) this.edgeLock.up = false
      if (!nearBottom) this.edgeLock.down = false
    }

    this.maybeTriggerLoad = () => {
      if (this.loading) return
      if (Date.now() < this.suppressTriggersUntil) return

      const scrollTop = this.el.scrollTop
      const scrollDirection = scrollTop >= this.lastScrollTop ? "down" : "up"
      this.lastScrollTop = scrollTop

      const distanceFromBottom = this.el.scrollHeight - this.el.clientHeight - scrollTop
      const nearTop = scrollTop <= 220
      const nearBottom = distanceFromBottom <= 220

      this.updateEdgeLocks({ nearTop, nearBottom })

      if (nearBottom && scrollDirection === "down" && !this.edgeLock.down) {
        this.edgeLock.down = true
        this.triggerLoad("down")
      } else if (nearTop && scrollDirection === "up" && !this.edgeLock.up) {
        this.edgeLock.up = true
        this.triggerLoad("up")
      }
    }

    this.onPageLoaded = ({ direction }) => {
      this.loading = false

      const maxScrollTop = Math.max(this.el.scrollHeight - this.el.clientHeight, 0)

      if (direction === "down") {
        this.el.scrollTop = Math.max(maxScrollTop - this.pendingDistanceFromBottom, 0)
      } else if (direction === "up") {
        this.el.scrollTop = Math.min(this.pendingScrollTop, maxScrollTop)
      } else {
        this.el.scrollTop = Math.min(this.pendingScrollTop, maxScrollTop)
      }

      this.lastScrollTop = this.el.scrollTop
      this.suppressTriggersUntil = Date.now() + 70
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
