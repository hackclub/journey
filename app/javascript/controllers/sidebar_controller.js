import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "content", "collapseIcon", "icon", "avatar", "logoutContainer", "topContainer", "mainContent"]
  
  connect() {
    this.expanded = true
    
    // Store sidebar state in localStorage to persist across page loads (exists cause I don't want state to reset when user clicks on another button)
    if (localStorage.getItem('sidebarCollapsed') === 'true') {
      this.collapse()
      this.expanded = false
      if (this.hasCollapseIconTarget) {
        this.collapseIconTarget.classList.add("rotate-180")
      }
    }
  }
  
  disconnect() {
  }
  
  toggle(event) {
    if (event) {
      event.stopPropagation()
    }
    
    if (this.expanded) {
      this.collapse()
    } else {
      this.expand()
    }
    this.expanded = !this.expanded
    
    localStorage.setItem('sidebarCollapsed', !this.expanded)
    
    // Rotate. I'm not asking darlene to design another icon :D
    if (this.hasCollapseIconTarget) {
      this.collapseIconTarget.classList.toggle("rotate-180")
    }
  }
  
  collapse() {
    this.sidebarTarget.classList.add("collapsed")
    this.contentTargets.forEach(element => {
      element.classList.add("hidden")
    })
    
    // Hide icons and avatar
    this.iconTargets.forEach(element => {
      element.classList.add("hidden")
    })
    
    if (this.hasAvatarTarget) {
      this.avatarTarget.classList.add("hidden")
    }
    
    // Centre the top container
    if (this.hasTopContainerTarget) {
      this.topContainerTarget.classList.add("justify-center")
      this.topContainerTarget.classList.remove("justify-between")
    }
    
    // Centre the logout container
    if (this.hasLogoutContainerTarget) {
      this.logoutContainerTarget.classList.add("justify-center")
      this.logoutContainerTarget.classList.remove("justify-between")
    }

    // Adjust main content margin when sidebar is collapsed
    if (this.hasMainContentTarget) {
      this.mainContentTarget.classList.remove("ml-64", "lg:ml-74", "2xl:ml-96")
      this.mainContentTarget.classList.add("ml-32")
    }
  }
  
  expand() {
    this.sidebarTarget.classList.remove("collapsed")
    this.contentTargets.forEach(element => {
      element.classList.remove("hidden")
    })
    
    this.iconTargets.forEach(element => {
      element.classList.remove("hidden")
    })
    
    if (this.hasAvatarTarget) {
      this.avatarTarget.classList.remove("hidden")
    }
    
    if (this.hasTopContainerTarget) {
      this.topContainerTarget.classList.remove("justify-center")
      this.topContainerTarget.classList.add("justify-between")
    }
    
    if (this.hasLogoutContainerTarget) {
      this.logoutContainerTarget.classList.remove("justify-center")
      this.logoutContainerTarget.classList.add("justify-between")
    }
    
    if (this.hasMainContentTarget) {
      this.mainContentTarget.classList.remove("ml-32")
      this.mainContentTarget.classList.add("ml-64", "lg:ml-74", "2xl:ml-96")
    }
  }
} 