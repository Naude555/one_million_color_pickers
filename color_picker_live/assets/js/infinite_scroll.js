const InfiniteScroll = {
  mounted() {
    this.loading = false

    this.onPageLoaded = ({ direction }) => {
      this.loading = false

      const minOffset = 140
      if (direction === "down") {
        this.el.scrollTop = minOffset
      } else if (direction === "up") {
        this.el.scrollTop = Math.max(this.el.scrollHeight - this.el.clientHeight - minOffset, minOffset)
      } else {
        this.el.scrollTop = Math.max((this.el.scrollHeight - this.el.clientHeight) / 2, 0)
      }
    }

    this.handleEvent("page-loaded", this.onPageLoaded)

    const debounce = (fn, wait) => {
      let timer
      return (...args) => {
        clearTimeout(timer)
        timer = setTimeout(() => fn(...args), wait)
      }
    }

    this.scrollHandler = debounce(() => {
      if (this.loading) return

      const distanceFromBottom = this.el.scrollHeight - this.el.scrollTop - this.el.clientHeight
      const nearTop = this.el.scrollTop < 120
      const nearBottom = distanceFromBottom < 120

      if (nearBottom) {
        this.loading = true
        this.pushEvent("load-more-down", {})
      } else if (nearTop) {
        this.loading = true
        this.pushEvent("load-more-up", {})
      }
    }, 120)

    this.el.addEventListener("scroll", this.scrollHandler)
  },

  destroyed() {
    this.el.removeEventListener("scroll", this.scrollHandler)
  }
}

export default InfiniteScroll
