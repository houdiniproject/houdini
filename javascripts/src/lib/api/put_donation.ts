// License: LGPL-3.0-or-later
import * as $ from 'jquery';
import {Configuration} from "../../../api/configuration";

export class PutDonation {
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

  public putDonation(donation: UpdateDonationModel, nonprofitId: number, extraJQueryAjaxSettings?: JQueryAjaxSettings): Promise<any> {
    let localVarPath = `${this.basePath}nonprofits/${nonprofitId}/donations/${donation.id}`;

    let queryParameters: any = {};
    let headerParams: any = {};
    // verify required parameter 'nonprofit' is not null or undefined
    if (donation === null || donation === undefined) {
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
      type: 'PUT',
      headers: headerParams,
      processData: false
    };

    requestOptions.data = JSON.stringify({donation:donation.donation});
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


interface UpdateDonationModelData {
  designation?:string
  dedication?:string
  comment?:string
  campaign_id:string
  event_id: string

  gross_amount?: number
  fee_total?: number
  check_number?:string
  date?:string
}

export interface UpdateDonationModel {
  id:number
  donation: UpdateDonationModelData
}