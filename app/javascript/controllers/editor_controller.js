import { Controller } from "@hotwired/stimulus"
import EditorJS from "@editorjs/editorjs"
import CodeTool from "@editorjs/code"
import Paragraph from "@editorjs/paragraph"

export default class extends Controller {
  static targets = ["editor", "input"]
  static values = { data: Object }

  connect() {
    this.initializeEditor()
  }

  disconnect() {
    if (this.editor) {
      this.editor.destroy()
    }
  }

  initializeEditor() {
    this.editor = new EditorJS({
      holder: this.editorTarget,
      tools: {
        paragraph: {
          class: Paragraph,
          inlineToolbar: true
        },
        code: CodeTool
      },
      data: this.dataValue,
      placeholder: "Write your comment here... (be nice)",
      onChange: () => {
        this.saveData()
      }
    })
  }

  async saveData() {
    try {
      const outputData = await this.editor.save()
      this.inputTarget.value = JSON.stringify(outputData)
    } catch (error) {
      console.error('Saving failed:', error)
    }
  }

  async validateContent() {
    try {
      const outputData = await this.editor.save()
      return outputData.blocks && outputData.blocks.length > 0
    } catch (error) {
      console.error('Validation failed:', error)
      return false
    }
  }
} 