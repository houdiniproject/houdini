// License: LGPL-3.0-or-later

appl.def('ajax_details', {
	update: function(id, form_obj, node) {
		appl.def('loading', true)
		delete form_obj.dollars
		appl.ajax.update('recurring_donation_details', id, form_obj).then(function(resp) {
			appl.def('loading', false)
			appl.ajax.index('recurring_donations')
			appl.notify('Successfully updated!')
			appl.close_modal()
			appl.ajax_details.fetch(appl.recurring_donation_details.id)
		})
	}
})

