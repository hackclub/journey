import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step1", "step2", "loadingIndicator"]

  async connect() {
    this.step1Target.classList.add("hidden")
    this.step2Target.classList.add("hidden")
    this.loadingIndicatorTarget.classList.remove("hidden")
    
    await new Promise(resolve => setTimeout(resolve, 500))
    
    this.loadingIndicatorTarget.classList.add("hidden")
    this.step1Target.classList.remove("hidden")
  }

  async nextStep() {
    this.step1Target.classList.add("hidden")
    this.loadingIndicatorTarget.classList.remove("hidden")
    
    await new Promise(resolve => setTimeout(resolve, 250))
    
    this.loadingIndicatorTarget.classList.add("hidden")
    this.step2Target.classList.remove("hidden")
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  prevStep() {
    this.step2Target.classList.add("hidden")
    this.step1Target.classList.remove("hidden")
    window.scrollTo({ top: 0, behavior: "smooth" })
  }
} 