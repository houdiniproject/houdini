// License: LGPL-3.0-or-later
// This defines a create_donation function that will create a Donation and
// Charge in our database and on Stripe given a Supporter that has a valid Card
//
// Use this with the cards/fields.html.erb partial
//
// Call it like: create_donation(card_obj, donation_obj)
// where card object is the full card data (name, number, expiry, etc) from the cards/fields partial
// and donation_obj is all the donation data (amount, type, etc)
//
// This function will create a Donation if donation.recurring is falsy
// It will create a RecurringDonation if donation.recurring is true

var create_card = require('../cards/create')
var format_err = require('../common/format_response_error')
var format = require('../common/format')
var request = require('../common/super-agent-promise')

module.exports = create_donation


function create_donation(donation) {
  if(donation.recurring_donation) {
    var path = '/nonprofits/' + app.nonprofit_id + '/recurring_donations'
  } else {
    var path = '/nonprofits/' + app.nonprofit_id + '/donations'
  }
  if(donation.dollars) {
    donation.amount = format.dollarsToCents(donation.dollars)
    delete donation.dollars
  }
	return request.post(path).set('Content-Type', 'application/json').send( donation).perform()
		// Reset the card form ui
		.then(function(resp) {
			appl.def('card_form', {status: '', error: false})
			return resp.body
		})
		// Display any errors
		.catch(function(resp) {
			appl.def('card_form', {
				loading: false,
				error: true,
				status: format_err(resp),
				progress_width: '0%'
			})
			throw new Error(resp)
		})
}

