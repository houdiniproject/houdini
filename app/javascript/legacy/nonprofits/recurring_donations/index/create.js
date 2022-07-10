// License: LGPL-3.0-or-later
require('../../../components/wizard')
var format_err = require('../../../common/format_response_error')
var format = require('../../../common/format').default
var request = require('../../../common/super-agent-promise')
var create_donation = require('../../../donations/create')
var create_card = require('../../../cards/create')
var formToObj = require('../../../common/form-to-object')

var wiz = {}

	// Set the wizard's donation object to the form data
	// amount, interval, time_unit, designation
wiz.set_donation = function(node) {
  var data = formToObj(appl.prev_elem(node))
  var rd = data.recurring_donation
  if(rd.start_date) {
    rd.start_date = format.date.toStandard(rd.start_date)
  }
  if(rd.end_date) {
    rd.end_date = format.date.toStandard(rd.end_date)
  }
  if(data.dollars) {
    data.amount = format.dollarsToCents(data.dollars)
    delete data.dollars
  }
	appl.def('rd_wizard.donation', data)
	appl.wizard.advance('rd_wizard')
}

// Save the supporter info. Advance immediately but save the promise.
wiz.save_supporter = function(form_obj) {
	appl.wizard.advance('rd_wizard')
	appl.rd_wizard.save_supporter_promise = request.post('/nonprofits/' + ENV.nonprofitID + '/supporters')
		.send({supporter: form_obj}).perform()
		.then(set_supporter_data)
		.catch(show_err)
}

// Resume on the supporter post promise, create a card, then create the donation with nested recurring donation
wiz.send_payment = function(card_obj) {
	if(appl.rd_wizard.loading) return
	appl.def('rd_wizard', {loading: true, error: ''})
	return appl.rd_wizard.save_supporter_promise
		.then(function(supporter) {
			return create_card({type: 'Supporter', id: supporter.id}, card_obj)
		})
		.then(function(card) {
			appl.rd_wizard.donation.token = card.token
      return request.post('/nonprofits/' + ENV.nonprofitID + '/recurring_donations')
        .send({ recurring_donation: appl.rd_wizard.donation }).perform()
		})
		.then(complete_wizard)
		.catch(show_err)
}

// To be called on payment completion and a new recurring donation was successfully created
function complete_wizard() {
  appl.notify("Successfully created! Reloading page...")
  appl.def('loading', false)
  setTimeout(()=> window.location.reload(), 1000)
}

appl.def('rd_wizard', wiz)

// Set the supporter values from a response to the wizard's data
function set_supporter_data(resp) {
	appl.def('rd_wizard.donation', {
		supporter_id: resp.body.id
	})
	return resp.body
}

// Set a general error on the wizard from an ajax response, displayed on any step
function show_err(resp) {
	appl.def('rd_wizard.loading', false)
	appl.def('rd_wizard.error', format_err(resp))
	throw new Error(resp)
}

// Set all the default values for the data used in the recurring donation wizard
function set_defaults() {
	appl.def('rd_wizard.donation', null)
	appl.def('rd_wizard', {
		donation: {
			nonprofit_id: ENV.nonprofitID,
			recurring_donation: {
				interval: 1,
				time_unit: 'month'
			}
		}
	})
}

// Initialize wizard defaults
set_defaults()


// Initialize the pikaday date picker inputs in the various fields on the page
// jank
var Pikaday = require('pikaday')
var moment = require('moment')
var el = $('#newRecurringDonationModal')
el.find('input[name="recurring_donation.start_date"]').val(moment().format('MM-DD-YYYY'))
new Pikaday({
	field: el.find('input[name="recurring_donation.start_date"]')[0],
	format: 'M/D/YYYY',
	minDate: moment().toDate()
})

new Pikaday({
	field: el.find('input[name="recurring_donation.end_date"]')[0],
	format: 'M/D/YYYY',
	minDate: moment().toDate()
})

new Pikaday({
	field: document.querySelector('#edit_end_date'),
	format: 'M/D/YYYY',
	minDate: moment().toDate()
})

