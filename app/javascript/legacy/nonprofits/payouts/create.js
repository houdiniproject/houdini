// License: LGPL-3.0-or-later
var request = require('../../common/super-agent-promise')

module.exports = create_payout

function create_payout(form_obj, ui) {
	ui.start()
	return request.post('/nonprofits/' + app.nonprofit_id + '/payouts').send({payout: form_obj}).perform()
		.then(function(resp) {
			ui.success(resp)
			return resp
		})
	.catch(function(resp) {
		ui.fail(resp)
		return resp
	})
}

