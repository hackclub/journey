import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "speechBubble", "audioTracks"]
  
  connect() {
    this.tracks = this.audioTracksTarget.querySelectorAll('audio.music-track')
    this.currentTrack = null
    this.isPlaying = false
    this.musicHasPlayed = false
  }
  
  toggleMusic() {
    if (this.hasSpeechBubbleTarget) {
      this.speechBubbleTarget.classList.add('hidden')
    }
    
    if (this.isPlaying) {
      this.pauseMusic()
    } else {
      this.playMusic()
    }
  }
  
  playMusic(trackIndex = null) {
    if (!this.musicHasPlayed) {
      this.dispatch("played", { bubbles: true })
      this.musicHasPlayed = true;
    }
    
    if (this.currentTrack) {
      this.currentTrack.pause()
      this.currentTrack.removeEventListener('ended', this.handleTrackEnded)
    }
    
    const index = trackIndex !== null ? trackIndex : Math.floor(Math.random() * this.tracks.length)
    this.currentTrack = this.tracks[index]
    
    this.currentTrack.loop = false
    
    this.handleTrackEnded = () => this.playNextTrack()
    this.currentTrack.addEventListener('ended', this.handleTrackEnded)
    
    this.currentTrack.play()
    this.isPlaying = true
    this.toggleTarget.classList.add('active')

    if (window.innerWidth < 640) {
      this.element.classList.add('mobile-music-playing')
    } else {
      this.element.classList.add('music-playing')
    }
    
    const trackName = this.currentTrack.dataset.trackName
    localStorage.setItem('journeyMusicEnabled', 'true')
    localStorage.setItem('journeyMusicTrack', trackName)
  }
  
  playNextTrack() {
    let currentIndex = Array.from(this.tracks).indexOf(this.currentTrack)
    let nextIndex = (currentIndex + 1) % this.tracks.length
    
    this.playMusic(nextIndex)
  }
  
  pauseMusic() {
    if (this.currentTrack) {
      this.currentTrack.pause()
    }
    this.isPlaying = false
    this.toggleTarget.classList.remove('active')
    if (window.innerWidth < 640) {
      this.element.classList.remove('mobile-music-playing')
    } else {
      this.element.classList.remove('music-playing')
    }
    localStorage.setItem('journeyMusicEnabled', 'false')
  }
  
  disconnect() {
    if (this.currentTrack) {
      this.currentTrack.removeEventListener('ended', this.handleTrackEnded)
      this.currentTrack.pause()
      this.currentTrack = null
    }
  }
} 