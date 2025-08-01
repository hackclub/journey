import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "description", "category", "banner", "readme", "demo", "repo",
                    "titleError", "descriptionError", "categoryError", "bannerError", "readmeError", "demoError", "repoError",
                    "hackatimeProjects", "hackatimeSelect", "selectedProjects"]

  connect() {
    this.element.setAttribute('novalidate', true)
    
    if (this.hasHackatimeSelectTarget) {
      this.hackatimeSelectTarget.addEventListener('change', this.handleHackatimeSelection.bind(this))
    }
  }

  validateForm(event) {
    this.clearErrors()
    
    let isValid = true

    if (!this.titleTarget.value.trim()) {
      this.showError(this.titleErrorTarget, "Title is required")
      isValid = false
    }

    if (!this.descriptionTarget.value.trim()) {
      this.showError(this.descriptionErrorTarget, "Description is required")
      isValid = false
    }

    if (!this.categoryTarget.value) {
      this.showError(this.categoryErrorTarget, "Please select a category")
      isValid = false
    }

    const urlFields = [
      { field: this.bannerTarget, error: this.bannerErrorTarget, name: "Banner" },
      { field: this.readmeTarget, error: this.readmeErrorTarget, name: "Readme link" },
      { field: this.demoTarget, error: this.demoErrorTarget, name: "Demo link" },
      { field: this.repoTarget, error: this.repoErrorTarget, name: "Repository link" }
    ]

    urlFields.forEach(({ field, error, name }) => {
      const value = field.value.trim()
      if (value && !this.isValidUrl(value)) {
        this.showError(error, `${name} must be a valid URL`)
        isValid = false
      }
    })

    if (!isValid) {
      event.preventDefault()
      const firstError = this.element.querySelector('.text-vintage-red')
      if (firstError) {
        firstError.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
    }
  }

  isValidUrl(string) {
    try {
      new URL(string)
      return true
    } catch (_) {
      return false
    }
  }

  showError(errorElement, message) {
    errorElement.textContent = message
    errorElement.classList.remove('hidden')
    const inputId = errorElement.id.replace('Error', '')
    const input = document.getElementById(inputId)
    if (input) {
      input.classList.add('border-vintage-red')
    }
  }

  clearErrors() {
    const errorTargets = [
      this.titleErrorTarget, 
      this.descriptionErrorTarget, 
      this.categoryErrorTarget,
      this.bannerErrorTarget,
      this.readmeErrorTarget,
      this.demoErrorTarget,
      this.repoErrorTarget
    ]

    errorTargets.forEach(target => {
      target.textContent = ''
      target.classList.add('hidden')
    })

    this.element.querySelectorAll('input, textarea, select').forEach(el => {
      el.classList.remove('border-vintage-red')
    })
  }

  addHackatimeProject(event) {
    event.preventDefault()
    
    if (this.hasHackatimeSelectTarget) {
      this.hackatimeSelectTarget.selectedIndex = 0
      this.hackatimeSelectTarget.classList.remove('hidden')
    }
  }
  
  handleHackatimeSelection(event) {
    const select = event.target
    const selectedValue = select.value
    const selectedOption = select.options[select.selectedIndex]
    
    if (!selectedValue || selectedValue === "") return
        
    this.addProjectToSelected(selectedValue, selectedOption.text)
    selectedOption.disabled = true
    select.selectedIndex = 0
  }
  
  addProjectToSelected(key, text) {
    if (!this.hasSelectedProjectsTarget) return
    
    const projectElement = document.createElement('div')
    projectElement.className = 'flex items-center p-2'
    projectElement.dataset.projectKey = key
    
    const formattedTime = text.match(/\(\d+h \d+m\)/) ? text.match(/\(\d+h \d+m\)/)[0] : ''
    const projectName = text.replace(/\s*\(\d+h \d+m\)/, '')
    
    projectElement.innerHTML = `
      <input type="hidden" name="project[hackatime_project_keys][]" value="${key}">
      <div class="flex-grow">
        <p class="font-medium">${projectName}</p>
        <p class="text-xs text-gray-600">Time tracked: ${formattedTime.replace(/[()]/g, '')}</p>
      </div>
      <button type="button" class="ml-2 text-vintage-red hover:text-red-700" data-action="click->project-form#removeSelectedProject">
        <svg class="h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <path d="M5 5h2v2H5V5zm4 4H7V7h2v2zm2 2H9V9h2v2zm2 0h-2v2H9v2H7v2H5v2h2v-2h2v-2h2v-2h2v2h2v2h2v2h2v-2h-2v-2h-2v-2h-2v-2zm2-2v2h-2V9h2zm2-2v2h-2V7h2zm0 0V5h2v2h-2z" fill="currentColor"/>
        </svg>
      </button>
    `
    
    this.selectedProjectsTarget.appendChild(projectElement)
  }
  
  removeSelectedProject(event) {
    event.preventDefault()
    let target = event.target
    
    while (target && !target.closest('[data-project-key]') && target !== document.body) {
      target = target.parentElement
    }
    
    const projectElement = target ? target.closest('[data-project-key]') : null
    if (!projectElement) return
    
    const projectKey = projectElement.dataset.projectKey
    if (this.hasHackatimeSelectTarget) {
      const select = this.hackatimeSelectTarget
      for (let i = 0; i < select.options.length; i++) {
        if (select.options[i].value === projectKey) {
          select.options[i].disabled = false
          break
        }
      }
    }
    
    projectElement.remove()
    
    // Thanks Cursor for this one. If thou shall remove this code, thou shalt not be able to empty the hackatime_project_keys array.
    if (this.hasSelectedProjectsTarget && this.selectedProjectsTarget.children.length === 0) {
      const emptyInput = document.createElement('input')
      emptyInput.type = 'hidden'
      emptyInput.name = 'project[hackatime_project_keys][]'
      emptyInput.value = ''
      this.selectedProjectsTarget.appendChild(emptyInput)
    }
  }
} 