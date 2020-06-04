// License: LGPL-3.0-or-later
/**
 * An Interceptor for ApiManager which adds the CSRF token to API calls
 * @param {JQuery.jqXHR} jqXHR
 * @param {JQuery.AjaxSettings<any>} settings
 * @returns {false | void}
 */
export function CSRFInterceptor(this:any, jqXHR:JQuery.jqXHR, settings: JQuery.AjaxSettings<any>): false|void {
    jqXHR.setRequestHeader('X-CSRF-Token', (window as any)._csrf)
}

