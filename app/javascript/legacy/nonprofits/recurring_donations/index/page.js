// License: LGPL-3.0-or-later
require('./index.es6')
require('./create')
require('./update')
require('./delete')
require('../../../common/restful_resource')
require('../../../common/vendor/bootstrap-tour-standalone')
require('../../../common/panels_layout')
var format = require('../../../common/format').default
appl.def('is_usa', format.geography.isUS)
require('./tour')

appl.def('readable_interval', require('../readable_interval'))

appl.def('recurring_donations', {
	query: {page: 1},
	concat_data: true
})

appl.def('recurring_donations.index', function() {
		appl.def('loading', true)
		return appl.ajax.index('recurring_donations').then(function(resp) {
			appl.def('loading', false)
			if(appl.recurring_donations.query.page > 1) {
				var main_panel = document.querySelector('.mainPanel')
				main_panel.scrollTop = main_panel.scrollHeight
			}
			return resp
		})
})

appl.recurring_donations.index()



appl.def('recurring_donation_details', {
	resource_name: 'recurring_donations'
})


appl.def('ajax_details', {
	fetch: function(id, node) {
		appl.def('loading', true)
		appl.ajax.fetch('recurring_donation_details', id).then(function(resp) {
			appl.open_side_panel(node)
			appl.def('loading', false)
		})
	},
})

