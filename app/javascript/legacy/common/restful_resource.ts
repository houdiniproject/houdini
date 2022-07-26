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

var request = require('../common/client').default
const {to_singular} = require('../../legacy_react/src/lib/deprecated_format');

var restful_resource = {}
module.exports = restful_resource


appl.def('ajax', {
	index: function(prop, node) {
		var resource = appl.vs(prop) || {}
		var name = resource.resource_name || prop
		var path = resource.path_prefix || ''
		before_request(prop)
		return new Promise(function(resolve, reject) {
			request.get(path + name).query(resource.query)
				.end(function(err, resp) {
					var tmp = resource.data
					after_request(prop, err, resp)
					if(resp.ok) {
						if(resource.query && resource.query.page > 1 && resource.concat_data) {
							appl.def(prop + '.data', tmp.concat(resp.body.data))
						}
						resolve(resp)
					} else {
						reject(resp)
					}
				})
		})
	},

	fetch: function(prop, id, node) {
		var resource = appl.vs(prop) || {}
		var name = resource.resource_name || prop
		var path = resource.path_prefix || ''
		before_request(prop)
		return new Promise(function(resolve, reject) {
			request.get(path + name + '/' + id).query(resource.query)
				.end(function(err, resp) {
					after_request(prop, err, resp)
					if(resp.ok) resolve(resp)
					else reject(resp)
				})
		})
	},

	create: function(prop, form_obj, node) {
		var resource = appl.vs(prop) || {}
		var name = resource.resource_name || prop
		var path = resource.path_prefix || ''
		before_request(prop)
		return new Promise(function(resolve, reject) {
			request.post(path + name).send(nested_obj(name, form_obj))
				.end(function(err, resp) {
					after_request(prop, err, resp)
					if(resp.ok) resolve(resp)
					else reject(resp)
				})
		})
	},

	update: function(prop, id, form_obj, node) {
		var resource = appl.vs(prop) || {}
		var name = resource.resource_name || prop
		var path = resource.path_prefix || ''
		before_request(prop)
		return new Promise(function(resolve, reject) {
			request.put(path + name + '/' + id).send(nested_obj(name, form_obj))
			.end(function(err, resp) {
				after_request(prop, err, resp)
				if(resp.ok) resolve(resp)
				else reject(resp)
			})
		})
	},

	del: function(prop, id, node) {
		var resource = appl.vs(prop) || {}
		var path = (resource.path_prefix || '') + (resource.resource_name || prop)
		before_request(prop)
		return new Promise(function(resolve, reject) {
			request.del(path + '/' + id)
				.end(function(err, resp) {
					after_request(prop, err, resp)
					if(resp.ok) resolve(resp)
					else reject(resp)
				})
		})
	}
})


// Given a viewscript property, set some state before every request.
// Eg. appl.ajax.index('donations') will cause appl.donations.loading to be
// true before the request finishes
function before_request(prop) {
	appl.def(prop + '.loading', true)
	appl.def(prop + '.error', '')
}


// Set some data after each request.
function after_request(prop, err, resp) {
	appl.def(prop + '.loading', false)
	if(resp.ok) {
		appl.def(prop, resp.body)
	} else {
		appl.def(prop + '.error', resp.body)
	}
}


// Simply return an object nested under 'name'
// Will singularize the given name if plural
// eg: given 'donations' and {amount: 111}, return {donation: {amount: 111}}
function nested_obj(name, child_obj) {
	var parent_obj = {}
	parent_obj[to_singular(name)] = child_obj
	return parent_obj
}

