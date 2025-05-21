import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timerSession", "hackatime", "sessionsSection", "hackatimeSection", "hackatimeInput", "timerSessionInput"]

  connect() {
    if (this.timerSessionTarget.checked) {
      this.showTimerSessions()
    } else if (this.hackatimeTarget.checked) {
      this.showHackatime()
    }
  }

  showTimerSessions() {
    this.sessionsSectionTarget.classList.remove('hidden')
    this.hackatimeSectionTarget.classList.add('hidden')
    this.hackatimeInputTarget.disabled = true
    
    this.timerSessionInputTargets.forEach(input => {
      input.disabled = false
    })
  }

  showHackatime() {
    this.sessionsSectionTarget.classList.add('hidden')
    this.hackatimeSectionTarget.classList.remove('hidden')
    this.hackatimeInputTarget.disabled = false
    
    this.timerSessionInputTargets.forEach(input => {
      input.disabled = true
    })
  }
} 