// License: LGPL-3.0-or-later
require('../../common/restful_resource')
require('../new')
var create_card = require('../../cards/create')
const create_donation = require('../../donations/create').default
var request = require('../../common/super-agent-promise').default
var get_ticket_levels = require('../../ticket_levels/get_totals').default
var format_err = require('../../common/format_response_error').default
const confirmation = require('../../common/confirmation').default;
require('../../common/restful_resource')
require('../../components/tables/filtering/apply_filter')('tickets')
require('./delete-ticket')

function metricsFetch() {
  appl.def('loading_metrics', true)
  request.get('/nonprofits/' + app.nonprofit_id + '/events/' + app.event_id + '/metrics')
    .perform()
    .then(function(resp) {
      appl
      .def('loading_metrics', false)
      .def('metrics', resp.body)
    })
  appl.def('loading_ticket_levels', true)
	get_ticket_levels(app.nonprofit_id, app.event_id)
		.then(function(resp) {
      appl.def('loading_ticket_levels', false)
		})
}

function fetch(query) {
  query = query || {page: 1}
  query.page = query.page || 1
  appl.def('loading_tickets', true)
  return request.get('/nonprofits/' + app.nonprofit_id + '/events/' + app.event_id + '/tickets')
    .query(query)
    .perform()
    .then(function(resp) {
      appl.def('loading_tickets', false)
      if(query.page > 1) appl.concat('tickets.data', resp.body.data)
      else appl.def('tickets', resp.body)
    })
}


appl.ticket_wiz.on_complete = function(tickets) {
  fetch()
  metricsFetch()
}

appl.def('donations.path_prefix', '/')

appl.def('tickets.index', function() {
  appl.def('appl.tickets.query.page', appl.tickets.query.page || 1)
  return fetch(appl.tickets.query)
})

appl.def('ajax_donations', {
	create: function(form_obj, node) {
		appl.def('loading', true)
		appl.ajax.create('donations', form_obj, node)
		.then(appl.not_loading)
		.then(function(resp) {
      fetch()
			appl.close_modal()
			appl.notify("Charge successful")
			document.querySelector('.newDonationModal-form').reset()
		})
	}
})


appl.def('after_create_card', function(resp) {
  fetch()
	appl.notify("Card successfully saved!")
  location.reload()
})

appl.def('tickets', {
	path_prefix: '/nonprofits/' + app.nonprofit_id + '/events/' + app.event_id + '/',
	query: {page: 1},
	concat_data: true
})

appl.def('toggle_checkin', function(id, name, node) {
  var checked = appl.prev_elem(node).checked
  var message = name + (checked ? ' checked in.' : ' checked out.')
	appl.ajax.update('tickets', id, {checked_in: checked})
    .then(function(){
      appl.notify(message)
      metricsFetch()
    })
})

appl.def('update_ticket', function(id, name, update_text, form_obj) {
	appl.ajax.update('tickets', id, form_obj)
    .then(function(){
      appl.notify(name + "'s " + update_text + ' updated.')
    })
})

appl.def('show_new_donation', function(supporter_id, supporter_name, supporter_email, card_id, card_name) {
	appl.def('selected_supporter', {
    id: supporter_id,
    name: supporter_name,
    email: supporter_email
  })
	appl.def('selected_card', {
    id: card_id,
    name: card_name
  })
	appl.open_modal('newDonationModal')
})

appl.def('show_new_card', function(supporter_id, supporter_name, supporter_email, ticket_id, event_id) {
	appl.def('selected_supporter', {
    id: supporter_id,
    name: supporter_name,
    email: supporter_email
  })
	appl.def('selected_ticket', {
        id: ticket_id
  })
    appl.def('selected_event'), {
	    id: event_id
    }
	appl.open_modal('newCardModal')
})


// Create a new donation on behalf of a selected supporter and their card
appl.def('create_donation', function(el) {
	appl.def('error', '')
  appl.def('loading', true)
	create_donation(appl.new_donation)
		.then(function() {
      return fetch()
		})
		.then(appl.not_loading)
		.then(appl.close_modal)
		.then(function() {
			appl.prev_elem(el).reset()
			appl.notify('Donation successfully made! Receipts have been sent via email.')
      location.reload()
		})
		.catch(display_err('new_donation_form'))
})


// Create a new card on behalf of a selected supporter
appl.def('create_card', function(card_obj, el) {
	appl.def('new_card_form.error', '')
	appl.def('loading', true)
	create_card({type: 'Supporter', id: appl.selected_supporter.id, email: appl.selected_supporter.email}, card_obj, {event_id: app.event_id})
		.then(function(card) {
			appl.prev_elem(el).reset()
			appl.notify("Card successfully saved for " + appl.selected_supporter.name)
			return appl.ajax.update('tickets', appl.selected_ticket.id, {token: card.token})
		})
		.then(function() {
      return fetch()
    })
		.then(appl.not_loading)
		.then(appl.close_modal)
    .then(() => location.reload())
		.catch(display_err('new_card_form'))
})

function display_err(scope) {
	return function(resp) {
    appl.def('loading', false)
    appl.def('error', format_err(resp))
	}
}

appl.def('remove_card', function(ticket_id, elm) {
  var result = confirmation('Are you sure?')
  result.confirmed = function() {
    appl.is_loading()

    request.post('/nonprofits/' + app.nonprofit_id + '/events/' + app.event_id + '/tickets/' + ticket_id + '/delete_card_for_ticket')
      .send({event_id: app.event_id, ticket_id:ticket_id})
      .perform()
      .then(function(resp) {
        appl.not_loading()
        appl.notify('Successfully deleted card')
        appl.tickets.index()
      })
  }
})


fetch()
metricsFetch()
