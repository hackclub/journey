import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loadingIndicator", "content", "title"]

  async connect() {
    await new Promise(resolve => setTimeout(resolve, 500))
    this.loadingIndicatorTarget.classList.add("hidden")
    this.contentTarget.classList.remove("hidden")
    this.titleTarget.classList.remove("hidden")
  }
}
