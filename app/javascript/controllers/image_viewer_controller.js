import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image"]

  connect() {
    this.closeOnEscape = (e) => {
      if (e.key === 'Escape') this.close()
    }
  }

  open(event) {
    const imageUrl = event.currentTarget.src
    this.imageTarget.src = imageUrl
    this.modalTarget.classList.remove('hidden')
    document.addEventListener('keydown', this.closeOnEscape)
    document.body.style.overflow = 'hidden'
  }

  close() {
    this.modalTarget.classList.add('hidden')
    document.removeEventListener('keydown', this.closeOnEscape)
    document.body.style.overflow = 'auto'
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }
} 