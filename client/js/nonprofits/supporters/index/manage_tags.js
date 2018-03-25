// License: LGPL-3.0-or-later
var request = require('../../../common/client')
var action_recipient = require('./action_recipient')
var tags = require('./tags_and_fields_shared_methods')
var type = 'tag'

tags.index_masters(type)

appl.def('tags.masters.show_modal', function(){
	appl.open_modal('manageTagMasterModal')
})


appl.def('tags.masters.add', function(form_obj, node){
	tags.add({type: type, form_obj: form_obj, node: node})
})


appl.def('tags.masters.delete', function(name, id, node) {
	var cb = appl.supporters.index
	tags.delete({ name: name, id: id, type: type, node: node, cb: cb})
})


appl.def('tags.bulk.show_modal', function(node){
	appl.tags.masters.data.map(function(s) {s.edit_action = null; return s})

	appl
		.def('tags.masters.data', appl.tags.masters.data)
		.def('tags.bulk.action_recipient', action_recipient())
		.open_modal('bulkTagEditModal')
})


// sets any selected tag's edit_action attribute to add, remove or null
appl.def('tags.bulk.add_or_remove', function(i, action, node){
	var this_tag = appl.tags.masters.data[i]
	if (this_tag.edit_action === action)
		this_tag.edit_action = null
	else 
		this_tag.edit_action = action

	appl.def('tags.masters.data', appl.tags.masters.data)
})


// creates an array of tag objects like tags = [{tag_master_id: 123, selected: true}, ...] 
// which is passed as an attribute in post_data.
// post_data gets passed as an argument to the post_tag_edits function 
// which handles the ajax stuff
appl.def('tags.bulk.prepare_to_post', function() {
	var tags = []
	var post_data = {}

	appl.tags.masters.data.forEach(function(s) {
		if(s.edit_action === 'add')
			tags.push({tag_master_id: s.id, selected: true})
		else if(s.edit_action === 'remove')
			tags.push({tag_master_id: s.id, selected: false})
	})

	post_data.tags = tags

	if(appl.supporters.selecting_all) {
		post_data.selecting_all = true
		post_data.query = appl.supporters.query
	}
	else {
		post_data.supporter_ids = appl.supporters.selected.map(function(s){return s.id})
	}

	post_tag_edits(post_data, function() {
		appl
		.notify('Successfully updated tags for ' + (appl.supporters.selecting_all ? 'All Supporters' : appl.tags.bulk.action_recipient))
		.def('supporters.selected', [])
	})
})


appl.def('tags.single.show_modal', function(node){
	// creates a tag list that adds an is_checked key
	// if the current supporter has that tag
	var tag_list = []

	appl.tags.masters.data.forEach(function(master_tag) {
		var new_tag = {
			id: master_tag.id,
			name: master_tag.name
		}
		appl.supporter_details.tags.data.forEach(function(supporter_tag) {
			if(supporter_tag.name === master_tag.name)
				new_tag.is_checked = true
		})
		tag_list.push(new_tag)
	})

	appl.def('supporter_details.tag_list', tag_list)
	appl.open_modal('tagEditModal')
})


appl.def('tags.single.prepare_to_post', function(form_obj) {
	var tags = []
	for(var i = 1, len = form_obj.id.length; i < len; ++i) {
		tags.push({
			tag_master_id: form_obj.id[i],
			selected: form_obj.selected[i]
		})
	}
	var post_data = {
		tags: tags,
		supporter_ids: [appl.supporter_details.data.id]
	}

	post_tag_edits(post_data, function() {
		appl
		.notify('Successfully updated tags for ' + appl.supporter_details.data.name_email_or_id)
		.def('supporters.selected', [])
		.ajax.index('supporter_details.tags')
	})
})


function post_tag_edits(post_data, callback){
	appl.def('loading', true)
	request
		.post('tag_joins/modify', post_data)
		.end(function(err, resp) {
			if(!resp.ok) return appl.notify(utils.print_error(resp))
			appl
				.close_modal()
				.def('loading', false)
				.supporters.index()
      if(appl.supporter_details.data) appl.ajax_supporter.fetch(appl.supporter_details.data.id)
			callback()
		})
}
