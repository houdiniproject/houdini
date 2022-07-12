// License: LGPL-3.0-or-later
if(app.autocomplete) {
  require('../components/address-autocomplete')
}
require('../cards/create')
var request = require('../common/super-agent-promise')
var create_card = require('../cards/create')
var format_err = require('../common/format_response_error').default
var path = '/nonprofits/' + app.nonprofit_id + '/events/' + app.event_id + '/tickets'

appl.def('ticket_wiz', {

	// Placeholder for a callback that is evaluated after the tickets are redeemed
	on_complete: function() {},

	// Set all the wizard's default data
	set_defaults: function() {
    appl.def('ticket_wiz.post_data', {
			nonprofit_id: app.nonprofit_id,
      tickets: [],
      kind: "",
      supporter_id: "",
    })
	},


	// Set/process all the ticket data after submitting the "Tickets" step form
	set_tickets: function(form_obj) {
		hide_err()
		var tickets = []
    var total_amount = 0
    var total_quantity = 0
		for(var key in form_obj.tickets) {
			var ticket = form_obj.tickets[key]
      ticket.quantity = Number(ticket.quantity)
      ticket.amount = Number(ticket.amount)
      total_quantity += ticket.quantity
      total_amount += ticket.quantity * ticket.amount
			if(ticket.quantity > 0) tickets.push({ticket_level_id: ticket.ticket_level_id, quantity: ticket.quantity})
		}
		appl.def('ticket_wiz.post_data.tickets', tickets)

		// Calculate total quantity and total charge amount
		appl.def('ticket_wiz', {
			total_amount: total_amount,
			total_quantity: total_quantity
		})

    if(total_amount === 0) {
      appl.def('ticket_wiz.post_data.kind', 'free')
    } else {
      appl.def('ticket_wiz.post_data.kind', 'charge')
    }

		if(total_quantity > 0) {
			appl.wizard.advance('ticket_wiz')
		} else {
			appl.notify('Please choose at least one ticket.')
		}
	},


	check_if_any_ticket_levels: function(i, name, node) {
		var ticket_level_remainder = appl.ticket_levels.data[i].remaining
		var value = appl.prev_elem(node).value
		if(value >= ticket_level_remainder) {
			appl.notify("There are only " + ticket_level_remainder + " tickets remaining for '"
				+  name + "'.")
			appl.prev_elem(node).value = ticket_level_remainder
		}
	},


	save_supporter: function(form_obj) {
		appl.ticket_wiz.save_supporter_promise = request
      .post('/nonprofits/' + app.nonprofit_id + '/supporters')
			.send({supporter: form_obj}).perform()
			.then(function(res) {
        appl.ticket_wiz.supporter = res.body
        appl.ticket_wiz.post_data.supporter_id = res.body.id
        return res.body
      })
			.catch(show_err)
		appl.wizard.advance('ticket_wiz')
	},

  set_kind: function(node) {
    // Tickets creations have a kind of free, offsite, or charge
    // OffsitePayments have a kind of check or cash
    // We need to save each separately
    var op_kind = appl.prev_elem(node).value
    var ticket_kind = appl.prev_elem(node).getAttribute('data-ticket-kind')
    appl.def('ticket_wiz.post_data.kind', ticket_kind)
    appl.def('ticket_wiz.post_data.offsite_payment.kind', op_kind)
  },

  send_payment: function(form_obj) {
    appl.def('loading', true)
    return appl.ticket_wiz.save_supporter_promise
      .then(function(supporter) {
        return create_card({type: 'Supporter', id: supporter.id, email: supporter.email}, form_obj)
      })
      .catch(show_err)
      .then(function(card) {
        appl.ticket_wiz.post_data.token = card.token
      })
      .then(appl.ticket_wiz.create_tickets)
  },

  create_tickets: function() {
    appl.def('loading', true)
    return request.post(path)
      .send(appl.ticket_wiz.post_data).perform()
			.then(complete_wizard)
			.then(appl.ticket_wiz.on_complete)
      .catch(show_err)
  },

}) // end appl.def('ticket_wiz'...


// To be called when either a free or purchased ticket was successfully
// redeemed; will show a success/thank-you modal
function complete_wizard(resp) {
  appl.def('created_ticket_id', resp.body.tickets[0].id)
  appl.def('loading', false)
	appl.open_modal('confirmTicketsModal')
	appl.ticket_wiz.set_defaults()
	appl.wizard.reset("ticket_wiz")
	hide_err()
}


// Display an error on the ticket wizard
// Works on the amount step, supporter step, and free ticket confirmation step.
// The card form step is a special case, it needs some extra state to be set
function show_err(resp) {
  appl.def('loading', false)
	appl.def('error', format_err(resp))
  appl.def('card_form', {error: true, status: format_err(resp), loading: false, progress_width: '0%'})
}

// Hide any errors in the wizard
function hide_err() {
  appl.def('loading', false)
	appl.def('error', '')
  appl.def('card_form', {status: '', error: false, loading: false})
}

appl.ticket_wiz.set_defaults()
