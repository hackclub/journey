import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image"]

  connect() {
    this.closeOnEscape = this.closeOnEscape.bind(this)
  }

  disconnect() {
    this.close()
  }


  open(event) {
    try {
      const imageUrl = event.currentTarget.src
      if (!imageUrl) {
        console.error('No image source found')
        return
      }

      this.imageTarget.src = imageUrl
      this.modalTarget.classList.remove('hidden')
      document.addEventListener('keydown', this.closeOnEscape)
      document.body.style.overflow = 'hidden'
    } catch (error) {
      console.error('Error opening image viewer:', error)
    }
  }

  close() {
    try {
      this.modalTarget.classList.add('hidden')
      document.removeEventListener('keydown', this.closeOnEscape)
      document.body.style.overflow = 'auto'
      this.imageTarget.src = '' // Clear the image source
    } catch (error) {
      console.error('Error closing image viewer:', error)
    }
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
} 