import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", 
    "dropzone", 
    "initial", 
    "uploading", 
    "preview",
    "imagePreview",
    "videoPreview",
    "audioPreview",
    "previewImage",
    "previewVideo",
    "previewAudio"
  ]

  static values = {
    uploadUrl: String
  }

  connect() {
    this.fileInput = document.createElement('input')
    this.fileInput.type = 'file'
    this.fileInput.accept = 'image/*,video/*,audio/*'
    this.fileInput.multiple = false
    this.fileInput.addEventListener('change', this.handleFileSelect.bind(this))

    this.form = this.element.closest('form')
    if (this.form) {
      this.form.addEventListener('submit', this.handleFormSubmit.bind(this))
    }
  }

  highlight(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.add('border-forest', 'scale-[1.02]', 'bg-forest/5')
  }

  unhighlight(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.remove('border-forest', 'scale-[1.02]', 'bg-forest/5')
  }

  handleDrop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.unhighlight(event)
    
    const files = event.dataTransfer.files
    if (files.length > 0) {
      this.handleFile(files[0])
    }
  }

  handleClick() {
    this.fileInput.click()
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.handleFile(file)
    }
  }

  async handleFile(file) {
    if (!this.isValidFileType(file)) {
      alert('Please upload an image, video, audio, or GIF file')
      return
    }

    this.initialTarget.classList.add('hidden')
    this.uploadingTarget.classList.remove('hidden')

    this.currentFile = file

    this.showPreview(file)
  }

  isValidFileType(file) {
    const validTypes = ['image/', 'video/', 'audio/']
    return validTypes.some(type => file.type.startsWith(type))
  }

  showPreview(file) {
    this.uploadingTarget.classList.add('hidden')
    this.previewTarget.classList.remove('hidden')

    this.imagePreviewTarget.classList.add('hidden')
    this.videoPreviewTarget.classList.add('hidden')
    this.audioPreviewTarget.classList.add('hidden')

    const url = URL.createObjectURL(file)

    if (file.type.startsWith('image/')) {
      this.previewImageTarget.src = url
      this.imagePreviewTarget.classList.remove('hidden')
    } else if (file.type.startsWith('video/')) {
      this.previewVideoTarget.src = url
      this.videoPreviewTarget.classList.remove('hidden')
    } else if (file.type.startsWith('audio/')) {
      this.previewAudioTarget.src = url
      this.audioPreviewTarget.classList.remove('hidden')
    }
  }

  removeFile() {
    this.fileInput.value = ''
    this.inputTarget.value = ''
    this.currentFile = null

    if (this.previewImageTarget.src) URL.revokeObjectURL(this.previewImageTarget.src)
    if (this.previewVideoTarget.src) URL.revokeObjectURL(this.previewVideoTarget.src)
    if (this.previewAudioTarget.src) URL.revokeObjectURL(this.previewAudioTarget.src)

    this.previewTarget.classList.add('hidden')
    this.initialTarget.classList.remove('hidden')
  }

  async handleFormSubmit(event) {
    if (this.currentFile) {
      event.preventDefault()
      
      try {
        this.previewTarget.classList.add('hidden')
        this.uploadingTarget.classList.remove('hidden')

        const formData = new FormData()
        formData.append('file', this.currentFile)

        const response = await fetch('/attachments/upload', {
          method: 'POST',
          body: formData,
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          }
        })

        if (!response.ok) {
          throw new Error('Upload failed')
        }

        const data = await response.json()
        this.inputTarget.value = data.url
        
        this.form.submit()
      } catch (error) {
        console.error('Upload failed:', error)
        alert('Failed to upload file. Please try again.')
        this.uploadingTarget.classList.add('hidden')
        this.previewTarget.classList.remove('hidden')
      }
    }
  }
} 