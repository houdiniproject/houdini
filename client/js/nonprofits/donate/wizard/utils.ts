// License: LGPL-3.0-or-later


/**
 * This is a subset of all the params a widget would get. We're just mention the ones here we care about
 */
interface WizardFinishParams extends Record<string, any> {
  redirect?: string | null;
  mode?: string
}


export function handleWizardReport({ redirect, mode }: WizardFinishParams, parent: Window | null, window: Window) {
  if (!parent) {
    return
  }
  if (redirect) {
    parent.postMessage(`commitchange:redirect:${redirect}`, '*')
  }
  else if (mode !== 'embedded') {
    parent.postMessage('commitchange:close', '*');
  } else {
    if (window.parent) {
      window.parent.postMessage('commitchange:close', '*');
    }
  }
}

