// License: LGPL-3.0-or-later
var request = require('../../../common/super-agent-promise')
var readable_interval = require('../../recurring_donations/readable_interval')
var format = require('../../../common/format')

appl.def('ajax_payment_details', {
	fetch: function(id) {
		appl.def('loading', true)
    appl.def('payment_details.data', null) // since appl.def is a merge, we want to instead overwrite all data
		appl.ajax.fetch('payment_details', id)
			.then(function(resp) {
				appl.def('loading', false)
				appl.def('payment_details', appl.payment_details)
				appl.def('payment_details.data.offsite_payment', appl.payment_details.data.offsite_payment)
				appl.open_side_panel()
				return appl.payment_details.data.charge && appl.payment_details.data.charge.id
			})
			.then(fetch_refunds)
			.catch(function(err) {
				console.error(err)
				appl.not_loading()
			})
	}
})


appl.def('payment_details', {
	resource_name: 'payments'
})

// Utilities and view helper functions for payment details

appl.def('payment_recurring_don', function(payment) {
	return payment && payment.donation && payment.donation.recurring_donation
})

appl.def('get_recurring_interval', function(payment) {
	var rd = appl.payment_recurring_don(payment)
	if(!rd) return ''
	return readable_interval(rd.interval, rd.time_unit)
})

appl.def('get_recurring_created', function(payment) {
	var rd = appl.payment_recurring_don(payment)
	if(!rd) return ''
	return appl.readable_date(rd.created_at)
})

appl.def('payment_has_campaign', function(payment) {
	return get_payment_campaign(payment)
})

appl.def('payment_campaign_name', function(payment) {
	var c = get_payment_campaign(payment)
	return c && c.name
})

appl.def('payment_campaign_url', function(payment) {
	var c = get_payment_campaign(payment)
	return c && c.url
})

appl.def('payment_has_event', function(payment) {
	return payment && payment.event
})

appl.def('payment_event_name', function(payment) {
	return payment && payment.event && payment.event.name
})

appl.def('payment_event_url', function(payment) {
	return payment && payment.event && payment.event.url
})

// Given a payment, get either the designation, campaign name, or event name
appl.def('get_payment_purchase_object', function(payment) {
	if(payment.tickets.length && payment.tickets[0].event) {
		return "Event: " + payment.tickets[0].event.name
	} else if(payment.donation) {
		if(payment.donation.campaign) {
			return "Campaign: " + payment.donation.campaign.name
		} else {
			if(payment.donation.designation) {
				return "Designation: " + payment.donation.designation
			} else if(payment.donation.dedication) {
				return "In honor: " + payment.donation.dedication
			}
		}
	}
})

appl.def('update_donation', function(donation) {
	if(!donation) return
  appl.def('loading', true)
  donation.gross_amount = format.dollarsToCents(donation.gross_amount)
  donation.fee_total = format.dollarsToCents(donation.fee_total)
  var formattedDate = appl.readable_date_time_to_iso(donation.date) 
  if(formattedDate && formattedDate != "Invalid date") {
    donation.date = formattedDate 
  } else {
    appl.notify('Please enter a valid date')
    appl.def('loading', false)
    return
  }
	request.put('/nonprofits/' + app.nonprofit_id + '/donations/' + donation.id)
		.send({donation: donation})
		.end(function(err, resp) {
			appl.ajax_payment_details.fetch(appl.payment_details.data.id)
      appl.def('loading', false)
      appl.close_modal()
      appl.notify('Donation successfully updated!')
		})
})

appl.def('start_loading', function(){
  appl.def('loading', true)
})

appl.def('update_donation__success', function() {
  appl.ajax_payment_details.fetch(appl.payment_details.data.id)
  appl.def('loading', false)
  appl.notify('Donation successfully updated!')
})

appl.def('delete_offline_donation', function() {
	var payment = appl.payment_details.data
	request
		.del('/nonprofits/' + app.nonprofit_id + '/payments/' + payment.id)
		.perform()
		.then(function(resp) {
			appl.notify("That offsite payment has been successfully deleted.")
			appl.close_side_panel()
			appl.payments.index()
		})
})

function fetch_refunds(charge_id) {
	if(!charge_id) return
	request.get('/nonprofits/' + app.nonprofit_id + "/charges/" + charge_id + "/refunds")
		.perform()
		.then(function(resp) {
			appl.def('payment_details.refunds', resp.body)
	})
}

function get_payment_campaign(payment) {
	return payment && payment.donation && payment.donation.campaign
}

appl.def('resend_receipt', function(type) {
  var payment = appl.payment_details.data
  appl.def('loading', true)
  var url = `/nonprofits/${app.nonprofit_id}/payments/${payment.id}/resend_${type}_receipt`
  var message = type === 'donor' 
    ? `Donation receipt emailed to ${app.user.email}`
    : `Donation receipt emailed to you`
  request.post(url)
    .perform()
    .then(function(resp) {
      appl.def('loading', false)
      appl.notify(message)
    })
})

// Format the JSON for a serialized dedication, which can have supporter_id, note, and type (honor/memory)
appl.def('format_dedication', function(dedic, node) {
  var td = appl.prev_elem(node)
  if(!td) return
  var inner = ''
  if (dedic) {
    var json
    try { json = JSON.parse(dedic) } catch(e) {}
    if(json) {
      inner = `
        Donation made in ${dedic.type || 'honor'} of 
        <a href='/nonprofits/${app.nonprofit_id}/supporters?sid=${json.supporter_id}'>${json.name}</a>.
        ${json.note ? `<br>Note: <em>${json.note}</em>.` : ''}
      `
    } else {
      // Print plaintext dedication
      inner = dedic
    }
  }
  td.innerHTML = inner
})
