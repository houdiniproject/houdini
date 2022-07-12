// License: LGPL-3.0-or-later
var request = require('../../../common/client').default
var endpoint_prefix = '/nonprofits/' + app.nonprofit_id + '/'
var tags_or_fields = {}


tags_or_fields.definition_endpoint = function(type){
	return endpoint_prefix + type + '_definitions'
}


tags_or_fields.index_definitions = function(type) {
	request.get(tags_or_fields.definition_endpoint(type))
		.end(function(err, resp) {
			appl.def(type + 's.definitions.data', appl.sort_arr_of_objs_by_key(resp.body.data, 'name'))
		})
}


tags_or_fields.add = function(obj){
	if(obj.form_obj.name === '') {
		appl.notify('Sorry, input cannot be blank')
		return
	}
	var loading_key ='manage_' + obj.type + 's.loading'
	var data_key = obj.type + '_definition'
	var endpoint =  endpoint_prefix + data_key + 's'
	var data = {}; data[data_key] = obj.form_obj
	var notify_text = (obj.type === 'tag' ? 'Tag' : 'Field') + ' "' + obj.form_obj.name  + '"'

	appl.def(loading_key, true) 

	request.post(endpoint, data)
		.end(function(err, resp) {
			tags_or_fields.index_definitions(obj.type)
			appl.prev_elem(obj.node).reset()
			appl.def(loading_key, false)
			if (resp.text === '["Duplicate tag"]')
				appl.notify(notify_text  + ' already exists.')
			else if (resp.status != 200)
				appl.notify('Sorry, could not process request')
			else
				appl.notify(notify_text  + ' successfully added.')
		})
}


tags_or_fields.delete = function(obj){
	var notify_type = (obj.type === 'tag' ? 'Tag ' : 'Field ')
	request.del(tags_or_fields.definition_endpoint(obj.type) + '/' + obj.id)
	.end(function(err, resp) {
		tags_or_fields.index_definitions(obj.type)
		appl.notify(notify_type + '"' + obj.name  + '" successfully deleted.')
		if(obj.cb) obj.cb()
	})
}


module.exports = tags_or_fields