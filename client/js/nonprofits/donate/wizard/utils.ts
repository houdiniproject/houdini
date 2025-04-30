// License: LGPL-3.0-or-later

import WindowWrapper from "./WindowWrapper";


/**
 * This is a subset of all the params a widget would get. We're just mention the ones here we care about
 */
interface WizardFinishParams {
  /**
   * What location you'd like to redirect to on success
   */
  redirect?: string | null;
  
  /**
   * if this is an embedded widget, i.e. not one that is a pop-up on a page,
   * this would be set to true. Otherwise, false
   */
  embeddedWidget:boolean;
}

function prepareParams(inputParams:Record<string, any>): WizardFinishParams {
   return {
    redirect: inputParams['redirect'],
    embeddedWidget: inputParams['mode'] === 'embedded',
   }
}


export function handleWizardFinished(params: Record<string, any>, window:Window) {

  const windowWrapper = new WindowWrapper(window)
  const innerParams  = prepareParams(params);
  postRedirect(innerParams, windowWrapper);
  postClose(innerParams, windowWrapper);
}


/**
 * Are we in an iframe?
 * 
 * @returns true if inside a widget, false otherwise
 */
function insideAnIframe(window:WindowWrapper): boolean {
  return window.self() !== window.top();
}


/**
 * If we have a redirect, do one of two things:
 * * if we're inside a widget, sent a message to the parent (if the parent exists) requesting that a redirect be triggered on the host page
 * * if we're not, just redirect to the new location
 * @param params
 */
function postRedirect({redirect}:WizardFinishParams, window:WindowWrapper) {
  if (redirect) {
    if (insideAnIframe(window)) {
      window.safelyPostMessageToParent(`commitchange:redirect:${redirect}`, '*')
    }
    else {
      window.setLocation(redirect);
    }
  }
}

function postClose({embeddedWidget}:WizardFinishParams, window:WindowWrapper) {
  if (!embeddedWidget) {
    window.safelyPostMessageToParent('commitchange:close', '*');
  }
}