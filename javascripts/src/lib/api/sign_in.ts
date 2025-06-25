// License: LGPL-3.0-or-later
import * as $ from 'jquery';
import {Configuration} from "../../../api/configuration";

export class WebUserSignInOut {
  protected basePath = '/';
  public defaultHeaders: Array<string> = [];
  public defaultExtraJQueryAjaxSettings?: JQueryAjaxSettings = null;
  public configuration: Configuration = new Configuration();

  constructor(basePath?: string, configuration?: Configuration, defaultExtraJQueryAjaxSettings?: JQueryAjaxSettings) {
    if (basePath) {
      this.basePath = basePath;
    }
    if (configuration) {
      this.configuration = configuration;
    }
    if (defaultExtraJQueryAjaxSettings) {
      this.defaultExtraJQueryAjaxSettings = defaultExtraJQueryAjaxSettings;
    }
  }

  public postLogin(loginInfo: WebLoginModel, extraJQueryAjaxSettings?: JQueryAjaxSettings): Promise<any> {
    let localVarPath = this.basePath + 'users/sign_in.json';

    let queryParameters: any = {};
    let headerParams: any = {};
    // verify required parameter 'nonprofit' is not null or undefined
    if (loginInfo === null || loginInfo === undefined) {
      throw new Error('Required parameter nonprofit was null or undefined when calling postNonprofit.');
    }


    localVarPath = localVarPath + "?" + $.param(queryParameters);
    // to determine the Content-Type header
    let consumes: string[] = [
      'application/json'
    ];

    // to determine the Accept header
    let produces: string[] = [
      'application/json'
    ];


    headerParams['Content-Type'] = 'application/json';

    let requestOptions: JQueryAjaxSettings = {
      url: localVarPath,
      type: 'POST',
      headers: headerParams,
      processData: false
    };

    requestOptions.data = JSON.stringify({user:loginInfo});
    if (headerParams['Content-Type']) {
      requestOptions.contentType = headerParams['Content-Type'];
    }

    if (extraJQueryAjaxSettings) {
      requestOptions = (<any>Object).assign(requestOptions, extraJQueryAjaxSettings);
    }

    if (this.defaultExtraJQueryAjaxSettings) {
      requestOptions = (<any>Object).assign(requestOptions, this.defaultExtraJQueryAjaxSettings);
    }

    let dfd = $.Deferred();
    $.ajax(requestOptions).then(
      (data: any, textStatus: string, jqXHR: JQueryXHR) =>
        dfd.resolve(jqXHR, data),
      (xhr: JQueryXHR, textStatus: string, errorThrown: string) => {


          dfd.reject(xhr.responseJSON)

      }
    );
    return dfd.promise();
  }
}

export interface WebLoginModel {
  email:string
  password:string
  otp_attempt?:string
}
