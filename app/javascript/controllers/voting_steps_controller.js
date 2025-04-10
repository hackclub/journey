import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step1", "step2"]

  connect() {
    this.step1Target.classList.remove("hidden")
    this.step2Target.classList.add("hidden")
  }

  nextStep() {
    this.step1Target.classList.add("hidden")
    this.step2Target.classList.remove("hidden")
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  prevStep() {
    this.step2Target.classList.add("hidden")
    this.step1Target.classList.remove("hidden")
    window.scrollTo({ top: 0, behavior: "smooth" })
  }
} 