// License: LGPL-3.0-or-later

function prepareFormObject(form_obj) {
	form_obj['donation']['dollars'] = form_obj['donation']['dollars'].replace(',', '')
	return form_obj
}


appl.def('ajax_details', {
	update: function(id, form_obj, node) {
		appl.def('loading', true)
		delete form_obj.dollars
		form_obj = prepareFormObject(form_obj)
		appl.ajax.update('recurring_donation_details', id, form_obj).then(function(resp) {
			appl.def('loading', false)
			appl.ajax.index('recurring_donations')
			appl.notify('Successfully updated!')
			appl.close_modal()
			appl.ajax_details.fetch(appl.recurring_donation_details.id)
		}).catch((reason) => {
			appl.def('loading', false)
			if (reason.body[0]) {
				appl.notify(reason.body[0])
			}
		})
	}
})

