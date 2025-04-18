import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["warning", "commentForm"]

  next() {
    this.warningTarget.remove()
    this.commentFormTarget.classList.remove("hidden")
    const firstInput = this.commentFormTarget.querySelector("textarea")
    if (firstInput) firstInput.focus()
  }
} 