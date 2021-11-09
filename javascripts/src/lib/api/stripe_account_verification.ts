// License: LGPL-3.0-or-later
import * as $ from 'jquery';
import {Configuration} from "../../../api/configuration";
import setPrototypeOf = require('setprototypeof')

export class StripeAccountVerification {
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

  public getStripeAccount(nonprofitId: number, extraJQueryAjaxSettings?: JQueryAjaxSettings): Promise<StripeAccount> {
    let localVarPath = `${this.basePath}nonprofits/${nonprofitId}/stripe_account`;

    let queryParameters: any = {};
    let headerParams: any = {};
    // verify required parameter 'nonprofit' is not null or undefine


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
      type: 'GET',
      headers: headerParams,
      processData: false
    };
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
        
        if (xhr.status == 404) {
          dfd.reject(new RecordNotFoundError())
        }
        else{        
          dfd.reject(xhr.responseJSON)
        }

      }
    );
    return dfd.promise();
  }

  public postBeginVerificationLink(nonprofitId: number, extraJQueryAjaxSettings?: JQueryAjaxSettings): Promise<StripeAccountLink> {
    let localVarPath = `${this.basePath}nonprofits/${nonprofitId}/stripe_account/begin_verification`;

    let queryParameters: any = {};
    let headerParams: any = {};
    


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



public postAccountLink(nonprofitId: number, returnLocation?:string, extraJQueryAjaxSettings?: JQueryAjaxSettings): Promise<StripeAccountLink> {
    let localVarPath = `${this.basePath}nonprofits/${nonprofitId}/stripe_account/account_link`;

    let queryParameters: any = {};
    let headerParams: any = {};
    
    if (returnLocation) {
      queryParameters['return_location'] = returnLocation
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


export interface StripeAccount {
  currently_due:string[]
  past_due:string[]
  pending_verification:string[]
  eventually_due:string[]
  stripe_account_id:string
  charges_enabled:boolean
  payouts_enabled:boolean
  disabled_reason:string
  verification_status:'pending'|'unverified'|'verified'|'temporarily_verified'
  deadline: number | null;
}

export interface StripeAccountLink {
    "object": "account_link",
    "created": number,
    "expires_at": number,
    "url": string
}

export class RecordNotFoundError extends Error {
  constructor(){
    super()
    setPrototypeOf(this, RecordNotFoundError.prototype);
  }
}