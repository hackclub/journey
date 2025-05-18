import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title", "initialState", "activeState", "form", 
    "updateText", "hours", "minutes", "seconds", 
    "pauseButton", "resumeButton", "closeButton",
    "notes"
  ]

  static values = {
    countdownTime: { type: Number, default: 3 }
  }

  connect() {
    this.timer = null
    this.timerSessionId = null
    this.startTime = null
    this.elapsedTime = 0
    this.accumulatedPaused = 0
    this.isPaused = false
    this.isCountingDown = false
    this.projectId = this.element.id.replace('timer-modal-', '')
    
    if (this.hasNotesTarget) {
      const savedNotes = localStorage.getItem(`timer_notes_${this.projectId}`)
      if (savedNotes) {
        this.notesTarget.value = savedNotes
      }
      
      this.notesTarget.addEventListener('input', this.handleNotesChange.bind(this))
    }
    
    const urlParams = new URLSearchParams(window.location.search)
    if (urlParams.get('open_timer') === 'true') {
      const newUrl = window.location.pathname + window.location.hash
      window.history.replaceState({}, '', newUrl)
      
      this.element.classList.remove('hidden')
      document.body.classList.add('overflow-hidden')
    }
    
    this.checkForActiveSession()
  }

  disconnect() {
    this.clearTimer()
    this.clearCountdown()
  }
  
  async checkForActiveSession() {
    try {
      const response = await fetch(`/projects/${this.projectId}/timer_sessions/active`)
      const data = await response.json()
      
      if (data.id) {
        this.timerSessionId = data.id
        this.accumulatedPaused = data.accumulated_paused || 0
        
        if (data.status === 'paused') {
          this.startTime = new Date(data.started_at)
          const pausedAt = new Date(data.last_paused_at)
          this.elapsedTime = Math.floor((pausedAt - this.startTime) / 1000) - this.accumulatedPaused
          this.isPaused = true
          
          this.initialStateTarget.classList.add("hidden")
          this.activeStateTarget.classList.remove("hidden")
          this.pauseButtonTarget.classList.add("hidden")
          this.resumeButtonTarget.classList.remove("hidden")
          this.titleTarget.textContent = "Timer Session (Paused)"
          
          this.updateTimerDisplay()
        } else {
          this.startTime = new Date(data.started_at)
          this.isPaused = false
          
          this.initialStateTarget.classList.add("hidden")
          this.activeStateTarget.classList.remove("hidden")
          this.titleTarget.textContent = "Timer Session"
          
          this.updateTimer()
        }
      }
    } catch (error) {
      console.error("Error checking for active timer session:", error)
    }
  }

  async startTimer() {
    try {
      const formData = new FormData();
      formData.append('authenticity_token', document.querySelector('meta[name="csrf-token"]').content);
      
      const response = await fetch(`/projects/${this.projectId}/timer_sessions`, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: formData
      });
      
      if (response.redirected) {
        window.location.href = response.url;
        return;
      }
      
      const data = await response.json();
      
      if (!response.ok) {
        window.location.href = `/projects/${this.projectId}`;
        return;
      }
      
      this.timerSessionId = data.id;
      this.initialStateTarget.classList.add("hidden");
      this.activeStateTarget.classList.remove("hidden");
      this.titleTarget.textContent = "Timer Session";
      this.startTime = new Date(data.started_at);
      this.isPaused = false;
      this.updateTimer();
    } catch (error) {
      console.error("Error creating timer session:", error);
      window.location.href = `/projects/${this.projectId}`;
    }
  }

  updateTimer() {
    if (this.isPaused) return

    const now = new Date()
    const diffInSeconds = Math.floor((now - this.startTime) / 1000)
    const adjustedDiff = diffInSeconds - this.accumulatedPaused
    
    this.updateTimerDisplayWithSeconds(adjustedDiff)

    this.timer = setTimeout(() => this.updateTimer(), 1000)
  }
  
  updateTimerDisplayWithSeconds(totalSeconds) {
    const hours = Math.floor(totalSeconds / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60

    this.hoursTarget.textContent = hours.toString().padStart(2, '0')
    this.minutesTarget.textContent = minutes.toString().padStart(2, '0')
    this.secondsTarget.textContent = seconds.toString().padStart(2, '0')
  }
  
  updateTimerDisplay() {
    const totalSeconds = this.elapsedTime
    this.updateTimerDisplayWithSeconds(totalSeconds)
  }

  async pauseTimer() {
    if (!this.timerSessionId) return
    
    try {      
      const response = await fetch(`/projects/${this.projectId}/timer_sessions/${this.timerSessionId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          action_type: 'pause'
        })
      })

      this.isPaused = true
      this.clearTimer()
      
      this.pauseButtonTarget.classList.add("hidden")
      this.resumeButtonTarget.classList.remove("hidden")
      this.titleTarget.textContent = "Timer Session (Paused)"
      
      if (!response.ok) {
        throw new Error('Failed to pause timer session')
      }
    } catch (error) {
      console.error("Error pausing timer session:", error)
    }
  }

  async resumeTimer() {
    if (!this.timerSessionId) return
    
    try {
      const response = await fetch(`/projects/${this.projectId}/timer_sessions/${this.timerSessionId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          action_type: 'resume'
        })
      })
      
      if (!response.ok) {
        throw new Error('Failed to resume timer session')
      }
      
      const data = await response.json()
      this.accumulatedPaused = data.accumulated_paused
      
      this.isPaused = false
      this.titleTarget.textContent = "Timer Session"
      this.pauseButtonTarget.classList.remove("hidden")
      this.resumeButtonTarget.classList.add("hidden")
      
      this.updateTimer()
    } catch (error) {
      console.error("Error resuming timer session:", error)
    }
  }

  async discardSession(event) {
    if (!this.timerSessionId) {
      this.resetTimerState()
      this.element.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
      return
    }
    
    try {
      const response = await fetch(`/projects/${this.projectId}/timer_sessions/${this.timerSessionId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      })
      
      if (!response.ok) {
        throw new Error('Failed to delete timer session')
      }
      
      this.resetTimerState()
      this.element.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    } catch (error) {
      console.error("Error deleting timer session:", error)
    }
  }

  async stopAndPost(event) {
    if (!this.timerSessionId) return
    
    if (this.isCountingDown) return
    
    const stopButton = event.currentTarget
    const originalText = stopButton.textContent.trim()
    
    if (originalText !== "Confirm Stop & Post") {
      event.preventDefault()
      
      this.isCountingDown = true
      let timeLeft = this.countdownTimeValue
      
      stopButton.textContent = `Wait (${timeLeft})`
      stopButton.disabled = true
      
      this.countdownTimer = setInterval(() => {
        timeLeft -= 1
        if (timeLeft <= 0) {
          this.clearCountdown()
          stopButton.textContent = "Confirm Stop & Post"
          stopButton.disabled = false
          this.isCountingDown = false
        } else {
          stopButton.textContent = `Wait (${timeLeft})`
        }
      }, 1000)
    } else if (originalText === "Confirm Stop & Post") {
      this.executeStopAndPost()
    }
  }
  
  async executeStopAndPost() {
    this.clearTimer()
    
    try {
      const stopResponse = await fetch(`/projects/${this.projectId}/timer_sessions/${this.timerSessionId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          action_type: 'stop'
        })
      })
      
      if (!stopResponse.ok) {
        const errorData = await stopResponse.json()
        
        if (errorData && errorData.error && errorData.error.includes("5 minutes")) {
          alert("Timer sessions must be at least 5 minutes long. Please continue timing or discard this session.")
          this.checkForActiveSession()
          return
        }
        
        throw new Error('Failed to stop timer session')
      }
      
      this.resetTimerState()
      
      window.location.href = `/projects/${this.projectId}`
      
    } catch (error) {
      console.error("Error stopping timer session:", error)
    }
  }

  clearTimer() {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }

  clearCountdown() {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer)
      this.countdownTimer = null
    }
  }

  handleNotesChange(event) {
    if (this.hasNotesTarget) {
      localStorage.setItem(`timer_notes_${this.projectId}`, event.target.value)
    }
  }

  resetTimerState() {
    this.clearTimer()
    this.clearCountdown()
    this.titleTarget.textContent = "Start Timer Session"
    this.initialStateTarget.classList.remove("hidden")
    this.activeStateTarget.classList.add("hidden")
    this.pauseButtonTarget.classList.remove("hidden")
    this.resumeButtonTarget.classList.add("hidden")
    
    this.hoursTarget.textContent = "00"
    this.minutesTarget.textContent = "00"
    this.secondsTarget.textContent = "00"
    
    // Clear saved notes when timer is reset
    if (this.hasNotesTarget) {
      localStorage.removeItem(`timer_notes_${this.projectId}`)
      this.notesTarget.value = ""
    }
    
    this.timer = null
    this.timerSessionId = null
    this.startTime = null
    this.elapsedTime = 0
    this.accumulatedPaused = 0
    this.isPaused = false
    this.isCountingDown = false
  }
} 