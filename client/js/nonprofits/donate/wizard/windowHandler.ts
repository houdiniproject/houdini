

class WindowWrapper {
  
  constructor(readonly window:Window) {

  }

  self = ():Window|null => {
    return this.window.self;
  }

  top = ():Window|null => {
    return this.window.top;
  }

  setLocation = (newLocation:string) => {
    this.window.document.location = newLocation;
  }

  postMessageToParent = (message:string, target:string) => {
    this.window.parent?.postMessage(message, target);
  }
}