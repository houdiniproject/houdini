// License: LGPL-3.0-or-later
var request = require('../../../common/client')
var action_recipient = require('./action_recipient')
var fields = require('./tags_and_fields_shared_methods')
var type = 'custom_field'

fields.index_masters(type)

appl.def('custom_fields.masters.show_modal', function(){
	appl.open_modal('manageFieldMasterModal')
})


appl.def('custom_fields.masters.add', function(form_obj, node){
	fields.add({ type: type, form_obj: form_obj, node: node })
})


appl.def('custom_fields.masters.delete', function(name, id, node) {
	fields.delete({ name: name, id: id, type: type, node: node })
	appl.ajax.index('supporter_details.custom_fields')
})


appl.def('custom_fields.bulk.show_modal', function(node) {
	appl
		.def('custom_fields.bulk.action_recipient', action_recipient())
		.open_modal('editBulkCustomFieldsModal')
})


appl.def('custom_fields.bulk.toggle_remove', function(this_field, node) {
	if (this_field.remove) this_field.remove = false;
	else this_field.remove = true; 
	appl.def('custom_fields.masters.data', appl.custom_fields.masters.data)
})


appl.def('custom_fields.bulk.prepare_to_post', function(form_obj, node) {
	var fields = []

	for(var i = 1, len = form_obj.id.length; i < len; ++i) {
		if(form_obj.remove[i] === 'true')
			fields.push({custom_field_master_id: form_obj.id[i], value: ''})
		else if(form_obj.val[i] === '') 
			{}
		else
			fields.push({custom_field_master_id: form_obj.id[i], value: form_obj.val[i]})
	}

	if(appl.supporters.selecting_all)
		var post_data = {
			custom_fields: fields,
			selecting_all: true,
			query: appl.supporters.query
		}
	else
		var post_data = {
			custom_fields: fields,
			supporter_ids: appl.supporters.selected.map(function(s){return s.id})
		}

	post_custom_field_edits(post_data, function() {
		appl
		.notify('Successfully updated fields for ' + appl.custom_fields.bulk.action_recipient)
		.uncheck_all_supporters()
	})
	appl.def('custom_fields.masters.data', appl.custom_fields.masters.data.map(function(s) {s.remove = false; return s}))
	appl.prev_elem(node).reset()
})



appl.def('custom_fields.single.show_modal', function(name, id, node) {
	var custom_field_list = []

	appl.custom_fields.masters.data.forEach(function(custom_field_master) {
		var new_custom_field = {
			id: custom_field_master.id,
			name: custom_field_master.name
		}
		appl.supporter_details.custom_fields.data.forEach(function(custom_field_join) {
			if(custom_field_join.name === custom_field_master.name && custom_field_join.value) 
				new_custom_field.value = custom_field_join.value
		})
		custom_field_list.push(new_custom_field)
	})

	appl
		.def('supporter_details.custom_field_list', custom_field_list)
		.open_modal('editCustomFieldsModal')
})



appl.def('custom_fields.single.prepare_to_post', function(form_obj) {
	var fields = []
	for(var i = 1, len = form_obj.id.length; i < len; ++i) {
		fields.push({custom_field_master_id: form_obj.id[i],value: form_obj.val[i]})
	}
	var post_data = {
		custom_fields: fields,
		supporter_ids: [appl.supporter_details.data.id]
	}

	post_custom_field_edits(post_data, function() {
		appl
		.notify('Successfully updated fields for ' + appl.supporter_details.data.name_email_or_id)
		.ajax.index('supporter_details.custom_fields')
	})
})

function post_custom_field_edits(post_data, callback){
	appl.def('loading', true)
	request
		.post('custom_field_joins/modify', post_data)
		.end(function(err, resp) {
			appl
				.close_modal()
				.def('loading', false)
			callback()
		})
}

