import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "nextButton", "prevButton", "submitButton"]
  static values = { currentStep: Number }

  connect() {
    this.currentStepValue = 1
    this.updateStepVisibility()
  }

  next() {
    if (this.currentStepValue === 1) {
      const title = this.element.querySelector('#project_title')
      const description = this.element.querySelector('#project_description')
      const category = this.element.querySelector('#project_category')

      if (!title.value.trim()) {
        this.showError(title, 'Title is required')
        return
      }

      if (!description.value.trim()) {
        this.showError(description, 'Description is required')
        return
      }

      if (!category.value) {
        this.showError(category, 'Please select a category')
        return
      }
      this.clearErrors()
    }

    if (this.currentStepValue < this.stepTargets.length) {
      this.currentStepValue++
      this.updateStepVisibility()
    }
  }

  previous() {
    if (this.currentStepValue > 1) {
      this.currentStepValue--
      this.updateStepVisibility()
    }
  }

  updateStepVisibility() {
    this.stepTargets.forEach((step, index) => {
      step.classList.toggle("hidden", index + 1 !== this.currentStepValue)
    })

    this.nextButtonTarget.classList.toggle("hidden", this.currentStepValue === this.stepTargets.length)
    this.prevButtonTarget.classList.toggle("hidden", this.currentStepValue === 1)
    this.submitButtonTarget.classList.toggle("hidden", this.currentStepValue !== this.stepTargets.length)
  }

  showError(input, message) {
    this.clearErrors()

    const errorDiv = document.createElement('div')
    errorDiv.className = 'mt-1 text-sm text-vintage-red'
    errorDiv.textContent = message

    input.classList.add('border-vintage-red')
    
    input.parentNode.insertBefore(errorDiv, input.nextSibling)
    input.focus()
  }

  clearErrors() {
    this.element.querySelectorAll('.text-vintage-red').forEach(el => el.remove())
    
    this.element.querySelectorAll('input, textarea, select').forEach(input => {
      input.classList.remove('border-vintage-red')
    })
  }
} 