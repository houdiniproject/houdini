// License: LGPL-3.0-or-later
import {Configuration} from "../../../../api/configuration";


const defaultResponse:SuccessResponse = {status: 200, data:{}};

type ErrorResponse = {data:{error:string}|{error:string}[], status:number }
type SuccessResponse = {data:unknown,status:number}
type Response = ErrorResponse|SuccessResponse

/**
 *  This is a FIFO array
 */
const responses: Array<ErrorResponse|SuccessResponse> = [];

export function addResponse({status, data}:Response):void {
	responses.push({status, data});
}

export class WebUserSignInOut {

	// eslint-disable-next-line @typescript-eslint/no-empty-function
	constructor(_basePath?: string, _configuration?: Configuration, _defaultExtraJQueryAjaxSettings?: JQueryAjaxSettings) {
	}

	public postLogin(_loginInfo: WebLoginModel, _extraJQueryAjaxSettings?: JQueryAjaxSettings): Promise<unknown> {
		const nextResponse = responses.shift();
		if (nextResponse) {
			return new Promise((resolve, reject) => {
				if (nextResponse.status < 400) {
					resolve(nextResponse.data);
				}
				else {
					reject(new SignInError(nextResponse as ErrorResponse));
				}
			});
		}
		else {
			return new Promise((resolve) => resolve(defaultResponse));
		}
	}

}

export interface WebLoginModel {
	email:string;
	password:string;
}
let api: WebUserSignInOut = null;

export default function (): WebUserSignInOut{
	return api;
}

export class SignInError extends Error {
	public readonly data?: {error:string}|{error:string}[]
	public readonly status?: number
	constructor({status, data}: {data?:{error:string}|{error:string}[], status?:number}) {
		super(`status: ${status}, data: ${JSON.stringify(data)}`);
		this.status = status;
		this.data = data;
		Object.freeze(this);
	}
}

export function initialize(basePath?: string, configuration?: Configuration) : WebUserSignInOut {

	api = new WebUserSignInOut(basePath, configuration);
	return api;

}