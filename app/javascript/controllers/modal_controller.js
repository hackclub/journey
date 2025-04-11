import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.escapeHandler = this.escapeHandler.bind(this)
    document.addEventListener("keydown", this.escapeHandler)
    
    this.clickOutsideHandler = this.clickOutsideHandler.bind(this)
    document.getElementById("create-project-modal").addEventListener("click", this.clickOutsideHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this.escapeHandler)
    const modal = document.getElementById("create-project-modal")
    if (modal) {
      modal.removeEventListener("click", this.clickOutsideHandler)
    }
  }

  open() {
    const modal = document.getElementById("create-project-modal")
    modal.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    
    setTimeout(() => {
      const firstInput = modal.querySelector("input, textarea")
      if (firstInput) firstInput.focus()
    }, 100)
  }

  close() {
    const modal = document.getElementById("create-project-modal")
    modal.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  escapeHandler(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  clickOutsideHandler(event) {
    const container = document.querySelector("[data-modal-target='container']")
    if (container && !container.contains(event.target) && event.target.id === "create-project-modal") {
      this.close()
    }
  }
} 