// License: LGPL-3.0-or-later
if (app.autocomplete) {
  require('../components/address-autocomplete')
}
require('../cards/create')
var request = require('../common/super-agent-promise')
var create_card = require('../cards/create')
var format_err = require('../common/format_response_error')
var path = '/nonprofits/' + app.nonprofit_id + '/events/' + appl.event_id + '/tickets'
const R = require('ramda')

const CommitchangeFeeCoverageCalculator = require('../../../javascripts/src/lib/payments/commitchange_fee_coverage_calculator').CommitchangeFeeCoverageCalculator;



appl.def('discounts.apply', function (node) {
  var code = appl.prev_elem(node).value
  var codes = R.pluck('code', appl.discounts.data)
  if (!R.contains(code, codes)) {
    appl.def('ticket_wiz.discount_obj', false)
    appl.def('ticket_wiz.post_data.event_discount_id', undefined)
    const calced = recalculateTheTotal()
    appl.def('ticket_wiz', {
      total_amount: calced.total_amount,
      total_quantity: appl.ticket_wiz.total_quantity,
      total_fee: calced.fee
    })

    appl.def('ticket_wiz.post_data.amount', calced.total_amount)
    return
  }

  appl.def('ticket_wiz.discount_obj', R.find(R.propEq('code', code), appl.discounts.data))
  appl.def('ticket_wiz.post_data.event_discount_id', appl.ticket_wiz.discount_obj.id)

  const { total_amount, fee } = recalculateTheTotal()
  appl.def('ticket_wiz', {
    total_amount,
    total_quantity: appl.ticket_wiz.total_quantity,
    total_fee: fee
  })

  appl.def('ticket_wiz.post_data.amount', total_amount)
  if (appl.ticket_wiz.total_amount === 0) {
    appl.def('ticket_wiz.post_data.kind', 'free')
  }

  appl.notify('Discount successfully applied')
  // appl.def('ticket_wiz.post_data.event_discount_id', appl.ticket_wiz.discount_obj.id)
})

appl.def('fee_covered.apply', function (node) {
  var fee_covered = appl.prev_elem(node).checked
  appl.def('ticket_wiz.fee_covered', fee_covered)
  const { total_amount, fee } = recalculateTheTotal()
  appl.def('ticket_wiz', {
    total_amount,
    total_quantity: appl.ticket_wiz.total_quantity,
    total_fee: fee
  })

  appl.def('ticket_wiz.post_data.amount', total_amount)
})

function recalculateTheTotal() {

  var ticket_price = 0
  appl.ticket_wiz.post_data.tickets.forEach((i) => {
    ticket_price += i.quantity * i.amount
  })

  if (appl.ticket_wiz.discount_obj) {
    let discount_mult = Number(appl.ticket_wiz.discount_obj.percent) / 100
    ticket_price = ticket_price - Math.round(ticket_price * discount_mult)
  }

  if (!app.nonprofit.feeStructure) {
    throw new Error("billing Plan isn't found!")
  }

  let total_amount = ticket_price
  let fee = 0

  if (ticket_price > 0) {

    const calculator  = new CommitchangeFeeCoverageCalculator({
      ...app.nonprofit.feeStructure,
      feeCovering:appl.ticket_wiz.fee_covered && appl.ticket_wiz.post_data.kind != 'free' && appl.ticket_wiz.post_data.kind != 'offsite',
      currency: 'usd'
    })

    const calcResult = calculator.calcFromNet(ticket_price);
    total_amount = calcResult.actualTotalAsNumber;
    fee = calcResult.estimatedFees.feeAsNumber;
  }

  return { total_amount, fee }

}

appl.def('ticket_wiz', {

  // Placeholder for a callback that is evaluated after the tickets are redeemed
  on_complete: function () { },

  // Set all the wizard's default data
  set_defaults: function () {
    appl.def('ticket_wiz.post_data', {
      nonprofit_id: app.nonprofit_id,
      tickets: [],
      kind: "charge",
      supporter_id: "",
      event_discount_id: undefined,
      
    })

    appl.def('ticket_wiz.discount_obj', false)
    if (!appl.reload_on_completion && !appl.hide_cover_fees_option){
      appl.def('ticket_wiz.fee_covered', true)
    }

  },


  // Set/process all the ticket data after submitting the "Tickets" step form
  set_tickets: function (form_obj) {
    hide_err()
    var tickets = []
    var total_amount = 0
    var total_quantity = 0
    for (var key in form_obj.tickets) {
      var ticket = form_obj.tickets[key]
      ticket.quantity = Number(ticket.quantity)
      ticket.amount = Number(ticket.amount)
      total_quantity += ticket.quantity
      if (ticket.quantity > 0) tickets.push({ ticket_level_id: ticket.ticket_level_id, quantity: ticket.quantity, amount: ticket.amount })
    }
    appl.def('ticket_wiz.post_data.tickets', tickets)
    if (appl.ticket_wiz.fee_covered === undefined) {
      appl.def('ticket_wiz.fee_covered', true)
    }

    const calcTotal = recalculateTheTotal()
    appl.def('ticket_wiz', {
      total_amount: calcTotal.total_amount,
      total_quantity: total_quantity,
      total_fee: calcTotal.fee
    })
    appl.def('ticket_wiz.post_data.amount', calcTotal.total_amount)

    if (appl.ticket_wiz.total_amount === 0) {
      appl.def('ticket_wiz.post_data.kind', 'free')
    } else {
      appl.def('ticket_wiz.post_data.kind', 'charge')
    }

    if (total_quantity > 0) {
      appl.wizard.advance('ticket_wiz')
    } else {
      appl.notify('Please choose at least one ticket.')
    }
  },


  check_if_any_ticket_levels: function (i, name, node) {
    var ticket_level_remainder = appl.ticket_levels.data[i].remaining
    var value = appl.prev_elem(node).value
    if (value >= ticket_level_remainder) {
      appl.notify("There are only " + ticket_level_remainder + " tickets remaining for '"
        + name + "'.")
      appl.prev_elem(node).value = ticket_level_remainder
    }
  },


  save_supporter: function (form_obj) {
    appl.ticket_wiz.save_supporter_promise = request
      .post('/nonprofits/' + app.nonprofit_id + '/supporters')
      .send({ supporter: form_obj }).perform()
      .then(function (res) {
        appl.ticket_wiz.supporter = res.body
        appl.ticket_wiz.post_data.supporter_id = res.body.id
        return res.body
      })
      .catch(show_err)
    appl.wizard.advance('ticket_wiz')
  },

  set_kind: function (node) {
    // Tickets creations have a kind of free, offsite, or charge
    // OffsitePayments have a kind of check or cash
    // We need to save each separately
    var op_kind = appl.prev_elem(node).value
    var ticket_kind = appl.prev_elem(node).getAttribute('data-ticket-kind')
    appl.def('ticket_wiz.post_data.kind', ticket_kind)
    appl.def('ticket_wiz.post_data.offsite_payment.kind', op_kind)

    const calcTotal = recalculateTheTotal()
    appl.def('ticket_wiz', {
      total_amount: calcTotal.total_amount,
      total_quantity: appl.ticket_wiz.total_quantity,
      total_fee: calcTotal.fee
    })

    appl.def('ticket_wiz.post_data.amount', calcTotal.total_amount)
  },

  send_payment: function (item_name, form_obj) {
    appl.def('loading', true)
    let post_data = { ...appl.ticket_wiz.post_data}
    return appl.ticket_wiz.save_supporter_promise
      .then(function (supporter) {
        return create_card({ type: 'Supporter', id: supporter.id, email: supporter.email }, item_name, form_obj.cardholder_name, form_obj.cardholder_zip)
      })
      .catch(show_err)
      .then(function (card) {
        post_data.token = card.token
      })
      .then(function () {
        post_data.fee_covered = appl.ticket_wiz.fee_covered || false
      })
      .then(() => appl.ticket_wiz.create_tickets(post_data))
      .then(() => { appl.ticketPaymentCard.clear() })
  },

  create_tickets: function (post_data=null) {
    appl.def('loading', true)
    if (!post_data) {
      post_data = {...appl.ticket_wiz.post_data}
    }
    return request.post(path)
      .send(post_data).perform()
      .then(complete_wizard)
      .then(appl.ticket_wiz.on_complete)
      .catch(show_err)
  },

}) // end appl.def('ticket_wiz'...


// To be called when either a free or purchased ticket was successfully
// redeemed; will show a success/thank-you modal
function complete_wizard(resp) {
  if (appl.reload_on_completion){
    window.location.reload()
  }
  else {
    appl.def('created_ticket_id', resp.body.tickets[0].id)
    appl.def('loading', false)
    appl.open_modal('confirmTicketsModal')
    appl.ticket_wiz.set_defaults()
    appl.wizard.reset("ticket_wiz")
    hide_err()
  }
}


// Display an error on the ticket wizard
// Works on the amount step, supporter step, and free ticket confirmation step.
// The card form step is a special case, it needs some extra state to be set
function show_err(resp) {
  appl.def('loading', false)
  appl.def('error', format_err(resp))
  appl.def('card_form', { error: true, status: format_err(resp), loading: false, progress_width: '0%' })
}

// Hide any errors in the wizard
function hide_err() {
  appl.def('loading', false)
  appl.def('error', '')
  appl.def('card_form', { status: '', error: false, loading: false })
}

appl.ticket_wiz.set_defaults()
