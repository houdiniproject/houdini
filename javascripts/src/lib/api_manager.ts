// License: LGPL-3.0-or-later
import * as _ from 'lodash'

import * as JQuery from 'jquery'

interface ApiWithSettings {
  defaultExtraJQueryAjaxSettings?: JQuery.AjaxSettings
}

export type Interceptor = (this: any, jqXHR: JQuery.jqXHR, settings: JQuery.AjaxSettings<any>) => false | void

/**
 * A service locator for creating getting a prepared instance of the API
 */
export class ApiManager {
  apis: any[] = []


  /**
   *
   * @param {{new(): ApiWithSettings}[]} apis a list of APIs. Normally this will be initialized
   * by the Root component with the APIS const from the generated API folder
   * @param {Interceptor[]} beforeSendInterceptors the interceptors that run before your XHR request is made.
   */
  constructor(apis: { new(): ApiWithSettings }[], ...beforeSendInterceptors: Interceptor[]) {
    _.forEach(apis, (i) => {
      let newed = new i()
      if (beforeSendInterceptors && beforeSendInterceptors.length > 0) {
        let a: JQuery.AjaxSettings<any> = {
          beforeSend: <any>((jqXHR:JQuery.jqXHR, settings:JQuery.AjaxSettings<any>) : false|void => {
            _.forEach(beforeSendInterceptors, (i:Interceptor) => i(jqXHR, settings))
            return
          })
        }
        newed.defaultExtraJQueryAjaxSettings = a
      }

      this.apis.push(newed)
    })
  }

  /**
   * Retrieves the Api instance for class you request
   *
   * @example
   * //returns the nonprofit API
   * api.get(NonprofitApi)
   * @param {{new(): T}} c class of the Api you'd like to use
   * @throws ApiMissingException when you pass in a class which isn't in the list of managed APIs
   * @returns {T} instance of the Api
   */
  get<T>(c: { new(): T }): T {
    let result = _.find(this.apis, (i) => {
      return i instanceof c
    })
    if (result) {
      return result as T
    }

    throw new ApiMissingException(`No API of type ${c.toString()}`)

  }

}

/**
 * An error for when the class you requested from ApiManager is missing
 */
export class ApiMissingException implements Error {
  constructor(message: string) {
    this.message = message
  }

  message: string;
  name: string;
  stack: string;

}