// License: LGPL-3.0-or-later
var create_payout = require('../create')
var format_err = require('../../../common/format_response_error')
appl.create_bank_account = require('../../../bank_accounts/create.es6')
require('../../../bank_accounts/resend_confirmation_email')

appl.def('create_payout', function(form_obj) {
	create_payout(form_obj, new_payout_ui)
})


var new_payout_ui = {
	start: function() {
		appl.is_loading()
	},
	success: function(resp) {
		appl.notify("Payout creation successful! Reloading page...")
		appl.reload()
	},
	fail: function(resp) {
		appl.not_loading()
		appl.def('error', format_err(resp))
	}
}
