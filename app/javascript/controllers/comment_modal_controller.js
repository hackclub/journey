import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["commentForm", "warning", "text", "textError", "editor"]

  connect() {
    if (this.element.tagName === 'FORM') {
      this.element.setAttribute('novalidate', true)
    }
  }
  
  next(event) {
    if (this.hasWarningTarget && this.hasCommentFormTarget) {
      this.warningTarget.classList.add("hidden")
      this.commentFormTarget.classList.remove("hidden")
      
      if (this.hasTextTarget) {
        this.textTarget.focus()
      }
    } else {
      console.error("Missing warning or comment form target")
    }
  }
  
  async validateForm(event) {
    this.clearErrors()
    
    const editorController = this.application.getControllerForElementAndIdentifier(
      this.editorTarget, 
      "editor"
    )
    
    const hasContent = await editorController.validateContent()
    if (!hasContent) {
      this.showError(this.textErrorTarget, "Comment cannot be empty")
      event.preventDefault()
      const firstError = this.element.querySelector('.text-vintage-red')
      if (firstError) {
        firstError.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
      return false
    }
    
    return true
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
    if (this.hasTextErrorTarget) {
      this.textErrorTarget.textContent = ''
      this.textErrorTarget.classList.add('hidden')
    }
    
    if (this.hasTextTarget) {
      const textElement = this.textTarget instanceof HTMLElement 
        ? this.textTarget
        : document.getElementById(this.textTarget.id)
        
      if (textElement) {
        textElement.classList.remove('border-vintage-red')
      }
    }
  }
}