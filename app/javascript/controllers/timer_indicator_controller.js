import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    activeProjectId: String
  }

  connect() {
    this.checkForActiveTimer()
    
    this.checkInterval = setInterval(() => this.checkForActiveTimer(), 5000)
    
    this.modalObserver = new MutationObserver(this.handleModalVisibility.bind(this))
  }

  disconnect() {
    if (this.checkInterval) {
      clearInterval(this.checkInterval)
    }
    if (this.modalObserver) {
      this.modalObserver.disconnect()
    }
  }

  async checkForActiveTimer() {
    try {
      const response = await fetch('/timer_sessions/active')
      const data = await response.json()
      
      if (data.id) {
        this.activeProjectIdValue = data.project_id
        const modal = document.getElementById(`timer-modal-${data.project_id}`)
        if (!modal || modal.classList.contains('hidden')) {
          this.element.classList.remove('hidden')
        }
        if (modal) {
          this.modalObserver.observe(modal, { attributes: true, attributeFilter: ['class'] })
        }
      } else {
        this.element.classList.add('hidden')
      }
    } catch (error) {
      console.error("Error checking for active timer:", error)
      this.element.classList.add('hidden')
    }
  }

  handleModalVisibility(mutations) {
    mutations.forEach(mutation => {
      if (mutation.attributeName === 'class') {
        const modal = mutation.target
        if (!modal.classList.contains('hidden')) {
          this.element.classList.add('hidden')
        } else if (this.hasActiveProjectIdValue) {
          this.element.classList.remove('hidden')
        }
      }
    })
  }

  openTimer() {
    if (this.hasActiveProjectIdValue) {
      const modal = document.getElementById(`timer-modal-${this.activeProjectIdValue}`)
      if (modal) {
        modal.classList.remove('hidden')
        document.body.classList.add('overflow-hidden')
      } else {
        window.location.href = `/projects/${this.activeProjectIdValue}?open_timer=true`
      }
    }
  }
} 