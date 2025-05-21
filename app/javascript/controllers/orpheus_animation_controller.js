import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["leftImage", "rightImage"]

  connect() {
    this.leftImageTarget.classList.add("translate-y-full", "opacity-0")
    this.rightImageTarget.classList.add("translate-y-full", "opacity-0")
  }

  showImages() {
    this.leftImageTarget.classList.remove("translate-y-full", "opacity-0")
    this.rightImageTarget.classList.remove("translate-y-full", "opacity-0")
  }

  hideImages() {
    this.leftImageTarget.classList.add("translate-y-full", "opacity-0")
    this.rightImageTarget.classList.add("translate-y-full", "opacity-0")
  }
} 