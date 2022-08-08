// License: LGPL-3.0-or-later
// This is a little utility to convert a superagent response that has an error
// into a readable single string message
//
// This should work both with 422 unprocessable entities as well as 500 server errors

const err_msg = "We're sorry, but something went wrong. Please try again soon.";

export interface ErrorResponseType {
	body?: {
		error?: string;
		errors?: string[] | unknown;
	} | string;
	error?: string;

}


export default function show_err(resp: ErrorResponseType): string {
	console.error(resp);
	if (resp.body) {
		if (typeof resp.body === 'string') {
			return resp.body;
		}
		else {
			if (resp.body.error) {
				return resp.body.error;
			}
			else if(resp.body.errors instanceof Array) {
				return resp.body.errors[0];
			}
		}
	}
	else if (resp.error) {
		return resp.error;
	}
	else {
		return err_msg;
	}
}

