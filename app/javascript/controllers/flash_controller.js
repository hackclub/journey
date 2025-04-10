import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]
  static values = {
    hideAfter: Number
  }

  connect() {
    this.messageTarget.classList.add('translate-x-0')
    this.messageTarget.classList.remove('translate-x-full')

    if (this.hasHideAfterValue) {
      this.timeout = setTimeout(() => {
        this.hide()
      }, this.hideAfterValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  close() {
    this.hide()
  }

  hide() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    
    this.messageTarget.classList.add('translate-x-full')
    this.messageTarget.classList.remove('translate-x-0')
    
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
} 