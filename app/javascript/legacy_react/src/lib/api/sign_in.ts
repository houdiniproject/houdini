// License: LGPL-3.0-or-later
import * as $ from 'jquery';
import {Configuration} from "../../../api/configuration";
import Routes from '../../../../routes';

export interface WebUserSignInOut {
  postSignIn(loginInfo: WebLoginModel): Promise<any>;
}



function postSignIn(loginInfo: WebLoginModel): Promise<any> {
  let headerParams: any = {};
  // verify required parameter 'nonprofit' is not null or undefined
  if (loginInfo === null || loginInfo === undefined) {
    throw new Error('Required parameter nonprofit was null or undefined when calling postNonprofit.');
  }


  const localVarPath = Routes.user_session_url({format: "json"});
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


  let dfd = $.Deferred();
  $.ajax(requestOptions).then(
    (data: any, textStatus: string, jqXHR: JQueryXHR) =>
      dfd.resolve(jqXHR, data),
    (xhr: JQueryXHR, textStatus: string, errorThrown: string) => {


        dfd.reject(xhr.responseJSON)

    }
  );
  return dfd.promise() as any;
}


export interface WebLoginModel {
  email:string
  password:string
}

export default {postSignIn};

