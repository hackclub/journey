import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "form"]
  static values = {
    loadingText: { type: Array, default: ["This might be an intentional delay because Kartikey loves the loading indicator so much...", "Processing...", "All Hail Lillia!"] },
    isDelete: { type: Boolean, default: false },
    isConfirming: { type: Boolean, default: false }
  }

  connect() {
    this.submitting = false
    this.originalButtonText = null
    this.isDelete = this.element.dataset.delete === 'true'
  }

  disconnect() {
    if (this.submitting) {
      this.resetButton()
    }
  }

  preventDoubleSubmission(event) {
    if (this.submitting) {
      event.preventDefault()
      return
    }

    if (this.isDelete && !this.isConfirming) {
      event.preventDefault()
      this.confirmDelete()
      return
    }

    this.submitting = true
    this.disableSubmitButton()
  }

  confirmDelete() {
    const button = this.submitButtonTarget
    this.originalButtonText = button.innerHTML
    button.innerHTML = 'Sure?'
    this.isConfirming = true
  }

  disableSubmitButton() {
    try {
      const button = this.submitButtonTarget
      
      button.innerHTML = `
        <div class="inline-flex items-center">
          <img src="/assets/images/lollipop.svg" class="animate-spin h-6 w-6 mr-2" style="transform-origin: center center;">
          <span>${this.loadingTextValue[Math.floor(Math.random() * this.loadingTextValue.length)]}</span>
        </div>
      `
      button.disabled = true
      button.classList.add('opacity-75', 'cursor-not-allowed')

      // Look, Lillia made such a pretty loading indicator, I just had to use it and intentional delays. Sorry, not sorry.
      setTimeout(() => {
        if (this.element.tagName === 'FORM') {
          this.element.submit()
        } else if (this.element.tagName === 'BUTTON' && this.element.form) {
          this.element.form.submit()
        }
      }, 75)
    } catch (error) {
      console.error('Error disabling submit button:', error)
      this.resetButton()
    }
  }

  resetButton() {
    try {
      const button = this.submitButtonTarget
      if (this.originalButtonText) {
        button.innerHTML = this.originalButtonText
      }
      button.disabled = false
      button.classList.remove('opacity-75', 'cursor-not-allowed', 'bg-vintage-red')
      this.submitting = false
      this.isConfirming = false
    } catch (error) {
      console.error('Error resetting button:', error)
    }
  }
} 