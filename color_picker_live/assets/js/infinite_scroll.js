const InfiniteScroll = {
  mounted() {
    this.loading = false

    this.onPageLoaded = () => {
      this.loading = false
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
      const nearTop = this.el.scrollTop < 160
      const nearBottom = distanceFromBottom < 160

      if (nearBottom) {
        this.loading = true
        this.pushEvent("load-more-down", {})
      } else if (nearTop) {
        this.loading = true
        this.pushEvent("load-more-up", {})
      }
    }, 150)

    this.el.addEventListener("scroll", this.scrollHandler)
  },

  destroyed() {
    this.el.removeEventListener("scroll", this.scrollHandler)
  }
}

export default InfiniteScroll
