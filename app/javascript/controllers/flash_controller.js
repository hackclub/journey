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
      setTimeout(() => {
        this.hide()
      }, this.hideAfterValue)
    }
  }

  hide() {
    this.messageTarget.classList.add('translate-x-full')
    this.messageTarget.classList.remove('translate-x-0')
    
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
} 