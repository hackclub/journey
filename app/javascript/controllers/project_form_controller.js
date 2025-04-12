import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "description", "category", "banner", "readme", "demo", "repo",
                    "titleError", "descriptionError", "categoryError", "bannerError", "readmeError", "demoError", "repoError"]

  connect() {
    this.element.setAttribute('novalidate', true)
  }

  validateForm(event) {
    this.clearErrors()
    
    let isValid = true

    if (!this.titleTarget.value.trim()) {
      this.showError(this.titleErrorTarget, "Title is required")
      isValid = false
    }

    if (!this.descriptionTarget.value.trim()) {
      this.showError(this.descriptionErrorTarget, "Description is required")
      isValid = false
    }

    if (!this.categoryTarget.value) {
      this.showError(this.categoryErrorTarget, "Please select a category")
      isValid = false
    }

    const urlFields = [
      { field: this.bannerTarget, error: this.bannerErrorTarget, name: "Banner" },
      { field: this.readmeTarget, error: this.readmeErrorTarget, name: "Documentation link" },
      { field: this.demoTarget, error: this.demoErrorTarget, name: "Demo link" },
      { field: this.repoTarget, error: this.repoErrorTarget, name: "Repository link" }
    ]

    urlFields.forEach(({ field, error, name }) => {
      const value = field.value.trim()
      if (value && !this.isValidUrl(value)) {
        this.showError(error, `${name} must be a valid URL`)
        isValid = false
      }
    })

    if (!isValid) {
      event.preventDefault()
      const firstError = this.element.querySelector('.text-vintage-red')
      if (firstError) {
        firstError.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
    }
  }

  isValidUrl(string) {
    try {
      new URL(string)
      return true
    } catch (_) {
      return false
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
    const errorTargets = [
      this.titleErrorTarget, 
      this.descriptionErrorTarget, 
      this.categoryErrorTarget,
      this.bannerErrorTarget,
      this.readmeErrorTarget,
      this.demoErrorTarget,
      this.repoErrorTarget
    ]

    errorTargets.forEach(target => {
      target.textContent = ''
      target.classList.add('hidden')
    })

    this.element.querySelectorAll('input, textarea, select').forEach(el => {
      el.classList.remove('border-vintage-red')
    })
  }
} 