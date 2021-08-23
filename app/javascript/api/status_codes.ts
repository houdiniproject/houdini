// From https://kapeli.com/cheat_sheets/HTTP_Status_Codes_Rails.docset/Contents/Resources/Documents/index


export enum StatusCode {

	/**
	 * 400 Bad request
	 *
	 * The request could not be fulfilled due to the incorrect syntax of the request.
	 */
	BadRequest = 400,
	/**
	 * 401 Unauthorized
	 *
	 * The requestor is not authorized to access the resource. This is similar to 402 but is used in cases where authentication is expected but has failed or has not been provided.
	 */
	Unauthorized = 401,

	/**
	 * 403 Forbidden
	 *
	 * The request was formatted correctly but the server is refusing to supply the requested resource. Unlike 402, authenticating will not make a difference in the server's response.
	 */
	Forbidden = 403,

	/**
	 * 404 Not found
	 *
	 * The resource could not be found. This is often used as a catch-all for all invalid URIs requested of the server.
	 */
	NotFound = 404,

	/**
	 * 500 Internal server error
	 *
	 * A generic status for an error in the server itself.
	 */
	InternalServerError = 500,


}