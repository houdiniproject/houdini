// License: LGPL-3.0-or-later
class PageProgressBar {
  template: HTMLTemplateElement

  constructor() {
    this.template = document.createElement('template')
    this.template.innerHTML = `<div class='progressBar--app' id="pageProgressBar"><div class='progressBar-fill--striped'></div></div>`
  }

  beginPageLoad(): void {
    let element = this.getElem()
    if (!element) {
      let firstChild = document.body.firstChild
      let clone = document.importNode(this.template.content, true)
      if (firstChild) {

        document.body.insertBefore(clone, firstChild)
      }
      else {
        document.body.appendChild(clone)
      }
    }

    return
  }

  finishPageLoad() {
    let element = this.getElem()
    if (element) {
      element.remove()
    }
  }

  private getElem(): Element {
    return document.getElementById("pageProgressBar")
  }
}

const pp: PageProgressBar = new PageProgressBar();

(window as any).pageProgress = pp

let ua = window.navigator.userAgent
if (ua.indexOf('MSIE ') <= 0 && ua.indexOf('Trident/') <= 0) {
  pp.beginPageLoad()
}







