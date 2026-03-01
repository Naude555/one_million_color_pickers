const InfiniteScroll = {
    mounted() {
       this.el.scrollTop = 5;
       // Optional: Log to confirm it works
        console.log("Initial scroll position set to 5.");
      // Debounce utility function
      const debounce = (func, delay) => {
        let timeout;
        return (...args) => {
          clearTimeout(timeout);
          timeout = setTimeout(() => func(...args), delay);
        };
      };
  
      // Define the scroll handler
      this.scrollHandler = debounce(() => {
        const scrollPercentage = (this.el.scrollTop / (this.el.scrollHeight - this.el.clientHeight)) * 100;
        console.log(this.el.scrollTop);
        console.log(scrollPercentage);
        if (scrollPercentage > 60) {
          this.pushEvent('load-more-down', {});
        } else if (scrollPercentage < 10 && this.el.scrollTop != 5) {
          this.pushEvent('load-more-up', {});
        }
      }, 200); // 200ms debounce delay
  
      // Add the debounced scroll handler to the scroll event
      this.el.addEventListener('scroll', this.scrollHandler);
  
      console.log("Initial scroll position mounted");
    },

    updated() {
        if (this.el.scrollTop === 0) {
          this.el.scrollTop = 6;
        }

      },
    
      destroyed() {
        // Remove the scroll handler
        this.el.removeEventListener('scroll', this.scrollHandler);
      }
    };
    
    export default InfiniteScroll;

  