// License: LGPL-3.0-or-later
import * as $ from 'jquery';
import {Configuration} from "../../../api/configuration";
import { ValidationErrorsException, ValidationErrors, TimeoutError, NotAuthorizedErrorException, NotAuthorizedError, NotFoundErrorException, NotFoundError } from '../../../api';

export class CreateSupporter {
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

  public createSupporter(supporter: CreateSupporterModel, nonprofitId: number, extraJQueryAjaxSettings?: JQueryAjaxSettings): Promise<any> {
    let localVarPath = `${this.basePath}nonprofits/${nonprofitId}/supporters`;

    let queryParameters: any = {};
    let headerParams: any = {};
    // verify required parameter 'nonprofit' is not null or undefined
    if (supporter === null || supporter === undefined) {
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

    requestOptions.data = JSON.stringify({supporter:supporter});
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
        if(textStatus === 'timeout'){
            dfd.reject(new TimeoutError())
        }

        else if (xhr.status == 400 && 400 >= 400)
        {
            dfd.reject(new ValidationErrorsException(<ValidationErrors>xhr.responseJSON))
        }

        else if (xhr.status == 401 && 401 >= 400)
        {
            dfd.reject(new NotAuthorizedErrorException(<NotAuthorizedError>xhr.responseJSON))
        }

        else if (xhr.status == 404 && 404 >= 400)
        {
            dfd.reject(new NotFoundErrorException(<NotFoundError>xhr.responseJSON))
        }

        else
        {

            dfd.reject(errorThrown)
        }

      }
    );
    return dfd.promise();
  }
}


export interface CreateSupporterModel {
    name?:string
    email?:string
    phone?:string
    organization?:string
}

