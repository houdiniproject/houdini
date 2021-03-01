// License: LGPL-3.0-or-later
var request = require('../../../common/super-agent-promise')
var format_err = require('../../../common/format_response_error')
var create_offline_donation = require('../../../donations/create_offline')

appl.def('supporter_details', {
	resource_name: 'supporters',

	// Assign the selected supporter to the one clicked on
	// Fetch the full data for that supporter with ajax after setting
	// Show the side panel
	show: function(supporter) {
		appl.open_side_panel()
		appl.def('supporter_details', supporter)
		appl.def('supporters.selected', [supporter])
		appl.def('timeline_action', null)
		appl.ajax_supporter.fetch(supporter.id)
		var path = 'supporters/' + supporter.id + '/'
		appl.def('supporter_details.tags.path_prefix', path)
		appl.def('supporter_details.activities.path_prefix', path)
		appl.def('supporter_details.supporter_notes.path_prefix', path)
		appl.def('supporter_details.custom_fields.path_prefix', path)
    request.get('/nonprofits/' + app.nonprofit_id + '/supporters/' + supporter.id + '/tag_joins').perform()
    .then(function(r) { appl.def('supporter_details.tags', r.body) })
		appl.ajax.index('supporter_details.custom_fields')
	},

	toggle_panel: function(supporter, node) {
		appl.close_modal()
		var tr = node.parentNode.parentNode

		if(tr.hasAttribute('data-selected')) {
			appl.close_side_panel()
			tr.removeAttribute('data-selected','')
		} else {
			appl.supporter_details.show(supporter)
			$('.mainPanel').find('tr').removeAttr('data-selected')
			tr.setAttribute('data-selected','')
			// add supporter_id to url param
			var path =  window.location.pathname + "?sid=" + supporter.id
			window.history.pushState({},'supporter id', path)
		}
	}
})


appl.def('ajax_supporter', {
	update: function(id, form_obj, node) {
		appl.def('loading', true)
		appl.ajax.update('supporter_details', id, form_obj).then(function(resp) {
			appl.def('loading', false)
			appl.supporters.index()
			if(resp.body.deleted) {
				appl.find_and_remove('supporters.data', {id: resp.body.id})
				appl.close_side_panel()
				appl.notify('Supporter successfully deleted')
			} else {
				appl.find_and_set('supporters.data', {id: resp.id}, resp)
				appl.close_modal()
				appl.notify('Supporter updated!')
			}
		})
	},

	fetch: function(id) {
		appl.def('loading', true)
		appl.ajax.fetch('supporter_details', id).then(function(resp) {
			appl.def('supporter_details.data.name_email_or_id',
				resp.body.data.name || resp.body.data.fc_full_name || resp.body.data.email || 'Supporter #' + resp.body.data.id)
			appl.def('supporter_details.data.websites',
					resp.body.data.fc_websites ? resp.body.data.fc_websites.split(',') : false
				)
			appl.def('loading', false)
		})
		fetch_full_contact(id)
	}
})

function fetch_full_contact(id){
	appl.def('supporter_details.data.full_contact', {photo: false, current_job: false, interests: false, jobs: false, social: false})
	request.get('/nonprofits/' + app.nonprofit_id + '/supporters/' + id + '/full_contact').perform()
		.then(function(resp){
			var data = resp.body.full_contact
			if (!data) {
					appl.def('supporter_details.data.full_contact', false)
					return
			}
			appl.def('supporter_details.data.full_contact', {
					  photo : data.photo && data.photo[0] ? data.photo[0].url : false
					, current_job : data.orgs ? data.orgs.map(function(d){if (d.current) return d })[0] : false
					, interests : data.topics
					, jobs: data.orgs
					, social: data.profiles
			})
		})
}


appl.ajax_supporter.create = function(form_obj, node) {
	appl.def('supporter_details', {loading: true, error: ''})
	return request.post('/nonprofits/' + app.nonprofit_id + '/supporters').send({supporter: form_obj}).perform()
		.then(function() {
			appl.def('supporter_details', {loading: false})
			appl.close_modal()
			appl.notify("Supporter successfully created!")
			appl.supporters.index()
			appl.prev_elem(node).reset()
		})
		.catch(function(resp) {
			appl.def('supporter_details', {error: format_err(resp), loading: false})
		})
}


appl.def('supporter_details.tags', {
	resource_name: 'tag_joins'
})

appl.def('supporter_details.custom_fields', {
	resource_name: 'custom_field_joins'
})


appl.def('supporter_details.activities', {
	resource_name: 'activities'
})

appl.def('supporter_details.supporter_notes', {
	resource_name: 'supporter_notes'
})


// Override the default 'close_side_panel' function provided by
// panels_layout.js so we can set some extra data
var old_close_fn = appl.close_side_panel
appl.def('close_side_panel', function(){
	appl.def('supporters.selected', appl.get_checked_supporters())
	old_close_fn.apply(appl)
})



appl.def('delete_selected_supporters', function(id){
	appl.supporters.selected.forEach(function(supp) {
		appl.ajax_supporter.update(supp.id, {deleted: true})
	})
	appl.close_side_panel()
})

appl.def('supporter_details.address_with_commas', utils.address_with_commas)


appl.def('create_offline_donation', function(form_obj, el) {
	create_offline_donation(form_obj, createDonationUI)
		.then(function(resp) {
			appl.ajax.index('supporter_details.activities')
			appl.prev_elem(el).reset()
		})
})

var createDonationUI = {
	start: function(){
		appl.is_loading()
		appl.def('new_offline_donation', {loading: true, error: ''})
	},
	success: function(){
		appl.not_loading()
		appl.def('new_offline_donation', {loading: false})
		appl.notify("Offline donation created successfully")
		appl.close_modal()
	},
	fail: function(resp){
		appl.def('new_offline_donation', {loading: false, error: format_err(resp)})
    appl.def('loading', false).def('error', format_err(resp))
	}
}

// Initialize the date picker inside the offline donation modal
var Pikaday = require('pikaday')
new Pikaday({
	field: document.querySelector('#js-offsiteDonationDate'),
	format: 'M/D/YYYY'
})
