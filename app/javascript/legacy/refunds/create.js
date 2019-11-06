// License: LGPL-3.0-or-later
const R = require('ramda')
const format = require('../common/format')
var format_err = require('../common/format_response_error')
var request = require('../common/super-agent-promise')

appl.def('ajax_refunds', {
	create: function(charge_id, form_obj, node) {
    form_obj = formatter(form_obj)
		appl.def({
			loading: true,
			refunds: { error: '', loading: true }
		})
		post_refund(charge_id, form_obj)
			.then(function(resp) {
				not_loading()
				appl.close_modal()
				return resp
			})
			.then(function(resp) { return resp.body })
			.then(fetch_data_on_success)
			.then(display_success_message)
		.catch(show_err)
	}
})

const formatter = R.evolve({
  amount: format.dollarsToCents
})

// Re-fetch all the payment data on the page after a refund has been made
function fetch_data_on_success(refund) {
	appl.payments.index()
	appl.ajax_payment_details.fetch(appl.payment_details.data.id)
	return refund
}

// Display a nice message confirming the amounts of the refund they just made
function display_success_message(refund) {
	appl.notify(
		"Your refund was successful!"
	)
	return refund
}

// Reset the loading state in the ui
function not_loading(x) {
	appl.def({loading: false, refunds: {loading: false}})
	return x
}

// Display an error in the ui
function show_err(resp) {
	not_loading()
	console.warn('Error in promise chain: ', resp)
	appl.def('refunds', {
		error: format_err(resp),
		loading: false
	})
}

// Make the ajax request, returning a Promise
function post_refund(charge_id, obj) {
		return request
			.post('/nonprofits/' + app.nonprofit_id + '/charges/' + charge_id + '/refunds')
			.send({refund: obj})
			.perform()
}

