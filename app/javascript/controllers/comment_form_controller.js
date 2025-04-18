import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["text", "textError"]

  connect() {
    this.element.setAttribute('novalidate', true)
  }

  validateForm(event) {
    this.clearErrors()
    
    let isValid = true

    if (!this.textTarget.value.trim()) {
      this.showError(this.textErrorTarget, "Comment text is required")
      isValid = false
    }

    if (!isValid) {
      event.preventDefault()
      const firstError = this.element.querySelector('.text-vintage-red')
      if (firstError) {
        firstError.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
    }
  }

  showError(errorElement, message) {
    errorElement.textContent = message
    errorElement.classList.remove('hidden')
    const inputId = errorElement.id.replace('Error', '')
    const input = document.getElementById(inputId)
    if (input) {
      input.classList.add('border-vintage-red')
    }
  }

  clearErrors() {
    this.textErrorTarget.textContent = ''
    this.textErrorTarget.classList.add('hidden')
    this.textTarget.classList.remove('border-vintage-red')
  }
} 