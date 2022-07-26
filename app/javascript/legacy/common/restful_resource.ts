// License: LGPL-3.0-or-later
/* A simple module for dealing with ajax-based resources in viewscript
	*
	*
	* Define a 'resource object' in appl that has these properties
	*   resource_name: 'donations' (plural name that matches the model)
	*   path_prefix: '/' (optional, defaults to empty string, or relative path)
	*   query: object of parameters to use for indexing (eg search queries)
	*   after_action: function callback run after the request (where action is fetch, index, etc)
	*   after_action_failure: callback for failed requests (where action is fetch, index, etc)
	*
	* Call the ajax functions like this:
	* in js:
	*   appl.ajax.index(appl.resource_object)
	*   appl.ajax.create(appl.donations, {amount: 420})
	* in viewscript in the dom:
	*   ajax.index resource_object
	*   ajax.create donations form_object
	*/

/* eslint-disable @typescript-eslint/no-unused-vars */

// - we do this because I'm not sure we can safely rename the 'node' argument. I assume its fine but viewscript is very weird.

import request from '../common/client';
import { to_singular } from '../../legacy_react/src/lib/deprecated_format';
import type { Appl } from '../types/appl';
import { Response } from 'superagent';


declare const appl: Appl;

interface Resource {
	concat_data?: boolean;
	data: { concat(input: unknown): unknown };
	path_prefix?: string;
	query?: { page: number };
	resource_name?: string;
}

interface RestfulResourceObject {
	create(prop:string, form_obj:Record<string,unknown>, node:unknown):Promise<Response>;
	del(prop:string, id:string, node:unknown): Promise<Response>;
	fetch(prop: string, id: string, node:unknown): Promise<Response>;
	index(prop: string, node:unknown): Promise<Response>;
	update(prop:string, id:string, form_obj:Record<string,unknown>, node:unknown):Promise<Response>;
}


export interface ApplWithRestfulResource extends Appl {
	ajax: RestfulResourceObject;
}

appl.def('ajax', {
	index: function (prop: string, node:unknown): Promise<Response> {
		const resource = (appl.vs(prop) || {}) as Resource;
		const name = resource.resource_name || prop;
		const path = resource.path_prefix || '';
		before_request(prop);
		return new Promise(function (resolve, reject) {
			request.get(path + name).query(resource.query)
				.end(function (err, resp) {
					const tmp = resource.data;
					after_request(prop, err, resp);
					if (resp.ok) {
						if (resource.query && resource.query.page > 1 && resource.concat_data) {
							appl.def(prop + '.data', tmp.concat(resp.body.data));
						}
						resolve(resp);
					} else {
						reject(resp);
					}
				});
		});
	},

	fetch: function (prop: string, id: string, node:unknown): Promise<Response> {
		const resource = (appl.vs(prop) || {}) as Resource;
		const name = resource.resource_name || prop;
		const path = resource.path_prefix || '';
		before_request(prop);
		return new Promise(function (resolve, reject) {
			request.get(path + name + '/' + id).query(resource.query)
				.end(function (err, resp) {
					after_request(prop, err, resp);
					if (resp.ok) resolve(resp);
					else reject(resp);
				});
		});
	},

	create: function (prop:string, form_obj:Record<string,unknown>, node:unknown): Promise<Response> {
		const resource = (appl.vs(prop)|| {}) as Resource;
		const name = resource.resource_name || prop;
		const path = resource.path_prefix || '';
		before_request(prop);
		return new Promise(function (resolve, reject) {
			request.post(path + name).send(nested_obj(name, form_obj))
				.end(function (err, resp) {
					after_request(prop, err, resp);
					if (resp.ok) resolve(resp);
					else reject(resp);
				});
		});
	},

	update: function (prop:string, id:string, form_obj:Record<string,unknown>, node:unknown): Promise<Response> {
		const resource = (appl.vs(prop) || {}) as Resource;
		const name = resource.resource_name || prop;
		const path = resource.path_prefix || '';
		before_request(prop);
		return new Promise(function (resolve, reject) {
			request.put(path + name + '/' + id).send(nested_obj(name, form_obj))
				.end(function (err, resp) {
					after_request(prop, err, resp);
					if (resp.ok) resolve(resp);
					else reject(resp);
				});
		});
	},

	del: function (prop:string, id:string, node:unknown): Promise<Response> {
		const resource = (appl.vs(prop) || {}) as Resource;
		const path = (resource.path_prefix || '') + (resource.resource_name || prop);
		before_request(prop);
		return new Promise(function (resolve, reject) {
			request.del(path + '/' + id)
				.end(function (err, resp) {
					after_request(prop, err, resp);
					if (resp.ok) resolve(resp);
					else reject(resp);
				});
		});
	},
} as RestfulResourceObject);


// Given a viewscript property, set some state before every request.
// Eg. appl.ajax.index('donations') will cause appl.donations.loading to be
// true before the request finishes
function before_request(prop: string): void {
	appl.def(prop + '.loading', true);
	appl.def(prop + '.error', '');
}


// Set some data after each request.
function after_request(prop: string, _err: unknown, resp: Response): void {
	appl.def(prop + '.loading', false);
	if (resp.ok) {
		appl.def(prop, resp.body);
	} else {
		appl.def(prop + '.error', resp.body);
	}
}


// Simply return an object nested under 'name'
// Will singularize the given name if plural
// eg: given 'donations' and {amount: 111}, return {donation: {amount: 111}}
function nested_obj(name:string, child_obj:Record<string, unknown>): Record<string, unknown> {
	const parent_obj = {} as Record<string, unknown>;
	parent_obj[to_singular(name)] = child_obj;
	return parent_obj;
}

