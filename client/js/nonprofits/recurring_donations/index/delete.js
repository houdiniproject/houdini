// License: LGPL-3.0-or-later

appl.def('ajax_details', {
	del: function(id, node) {
		appl.ajax.del('recurring_donation_details', id, node).then(function(resp) {
			appl.ajax.index('recurring_donations')
			appl.notify("Successfully deactivated")
			appl.close_side_panel()
		})
	}
})
