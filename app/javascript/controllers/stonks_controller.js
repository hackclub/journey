import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["stakeButton", "unstakeButton", "stakeCount", "projectsStaked", "leaderboard", "leaderboardButtonText"]

  connect() {
    this.refreshUI()
  }

  refreshUI() {
    const stakedCountElement = document.querySelector('[data-stonks-target="projectsStaked"]')
    if (stakedCountElement) {
      const currentCount = parseInt(stakedCountElement.textContent)
      const maxProjects = 5
      
      if (currentCount >= maxProjects) {
        this.disableStakeButtons()
      } else {
        this.enableStakeButtons()
      }
    }
  }

  stake(event) {
    event.preventDefault()
    const form = event.target.closest('form')
    form.submit()
  }

  unstake(event) {
    event.preventDefault()
    const form = event.target.closest('form')
    form.submit()
  }

  handleSuccess(action) {
    const modal = this.element.closest('[data-controller="modal"]')
    if (modal && modal.classList.contains('hidden') === false) {
      const modalController = this.application.getControllerForElementAndIdentifier(modal, 'modal')
      if (modalController) {
        modalController.close()
      }
    }
  }

  showError(message) {
    const errorElement = document.createElement('div')
    errorElement.className = 'bg-vintage-red/20 text-vintage-red p-3 rounded mb-4 text-center'
    errorElement.textContent = message
    
    const container = this.element.querySelector('.p-3.md\\:p-4.overflow-y-auto')
    if (container) {
      container.prepend(errorElement)
      setTimeout(() => {
        errorElement.remove()
      }, 3000)
    }
  }

  disableStakeButtons() {
    const stakeButtons = document.querySelectorAll('[data-stonks-target="stakeButton"]')
    stakeButtons.forEach(button => {
      button.disabled = true
      button.classList.add('opacity-50', 'cursor-not-allowed')
    })
  }

  enableStakeButtons() {
    const stakeButtons = document.querySelectorAll('[data-stonks-target="stakeButton"]')
    stakeButtons.forEach(button => {
      button.disabled = false
      button.classList.remove('opacity-50', 'cursor-not-allowed')
    })
  }

  toggleLeaderboard() {
    const leaderboard = this.leaderboardTarget
    const buttonText = this.leaderboardButtonTextTarget
    
    if (leaderboard.classList.contains('hidden')) {
      leaderboard.classList.remove('hidden')
      buttonText.textContent = 'Hide Stonkers'
    } else {
      leaderboard.classList.add('hidden')
      buttonText.textContent = 'Show Stonkers'
    }
  }
} 