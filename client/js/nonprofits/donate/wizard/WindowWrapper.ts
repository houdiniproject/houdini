
// License: LGPL-3.0-or-later
/**
 * This is  very lightweight wrapper around a Window object. The reason for its existence is that it's not straightforward to mock 
 * the interactions in jest for testing handleWizardFinished. It's clunky and JSDom in Jest doesn't really provide access to what we need.
 * 
 * These methods are intentionally very simple so we can easily mock them out.
 */
export default class WindowWrapper {
  
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

  safelyPostMessageToParent = (message:string, target:string) => {
    this.window.parent?.postMessage(message, target);
  }
}