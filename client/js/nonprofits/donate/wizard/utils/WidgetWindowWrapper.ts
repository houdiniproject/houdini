
// License: LGPL-3.0-or-later

import WindowWrapper from "./WindowWrapper";

/**
 * An extension of WindowWrapper that's customized to the needs of working with the Wizard
 */
export default class WidgetWindowWrapper extends WindowWrapper {
  /**
 * Are we in an iframe?
 * 
 * @returns true if inside a widget, false otherwise
 */
  insideAnIframe = ():boolean => {
    return this.self() !== this.top();
  }

  notifyParentOfRedirect = (redirect:string) => {
    this.safelyPostMessageToParent(`commitchange:redirect:${redirect}`, "*")
  }

  notifyParentOfClose = () => {
    this.safelyPostMessageToParent("commitchange:close", "*")
  }

  safelyPostMessageToParent = (message:string, target:string) => {
    if (this.parent()) {
      this.postMessageToParent(message, target);
    }
  }


}
