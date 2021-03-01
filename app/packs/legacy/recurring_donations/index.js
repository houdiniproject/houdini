// License: LGPL-3.0-or-later
var request = require('../common/client')

appl.def('update_card', function(form_obj) {
	appl.is_loading()

	request.put('/recurring_donations/' + form_obj.recurring_donation_id)
		.send({stripe_card: form_obj})
		.end(function(err, resp){
			appl.def('loading', false)
			if(!resp.ok) return appl.notify('Unable to update card. Please contact us at support@commitchange.com.')
			appl.notify('Card Updated!')
		})
})

