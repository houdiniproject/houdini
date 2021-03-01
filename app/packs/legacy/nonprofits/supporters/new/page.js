// License: LGPL-3.0-or-later
var restful_resource = require('../../../common/restful_resource')

appl.def('supporter', {
	path_prefix: '/nonprofits/' + app.nonprofit_id + '/',
	resource_name: 'supporters',
	after_create_failure: function(resp) {
		appl.def('error', resp).def('loading', false)
	},
	before_create: function(obj) {
		obj.tags_attributes = [{
			parent_id: app.nonprofit_id,
			parent_type: 'Nonprofit',
			name: 'volunteer'
		}]
		appl.def('error', '').def('loading', true)
	},
	after_create: function(resp, node){
		appl.def('loading', false)
		appl.notify("Volunteer created!")
		appl.redirect('/nonprofits/' + app.nonprofit_id)
	}
})

