import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    originalText: String
  }

  connect() {
    this.originalTextValue = this.element.textContent.trim()
  }

  confirm(event) {
    if (this.element.textContent.trim() === "Delete") {
      event.preventDefault()
      this.element.textContent = "Sure?"
    } else {
      return true
    }
  }
} 