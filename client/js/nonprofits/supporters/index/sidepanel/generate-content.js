// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const marked = require('marked')

const format = require('../../../../common/format')

// generate titles and bodies from activity json data

const pathPrefix = `/nonprofits/${app.nonprofit_id}`

module.exports = exports = {}

const viewPaymentLink = data =>
  h('p', [ h('a', {props: {href: `${pathPrefix}/payments?pid=${data.attachment_id}`}}, 'View payment details.') ])

exports.RecurringDonation = (data, state) => {
  return {
    title: `Paid $${format.centsToDollars(data.json_data.gross_amount)} towards a recurring donation`
  , body: [
      viewDedication(data)
    , h('p', `Started on ${format.date.toSimple(data.json_data.start_date)}. `)
    , viewPaymentLink(data)
    ]
  , icon: 'fa-heart'
  }
}

const viewDedication = data => 
  data.json_data.dedication && data.json_data.dedication.name
  ? h("p", [
      `Dedicated in ${data.json_data.dedication.type || 'honor'} of `
    , h('a', {props: {href: `/nonprofits/${ENV.nonprofitID}/supporters?sid=${data.json_data.dedication.supporter_id}`}}, data.json_data.dedication.name)
    ])
  : ''

exports.Donation = (data, state) => {
  const desig = data.json_data.designation ? h('p', `Designation: ${data.json_data.designation}. `) : ''
  return {
    title: `Donated $${format.centsToDollars(data.json_data.gross_amount)}`
  , body: [
      desig
    , viewDedication(data)
    , viewPaymentLink(data)
    ]
  , icon: 'fa-heart'
  }
}

exports.Ticket = (data, state) => {
  var paren = data.json_data.gross_amount ? `(totalling $${format.centsToDollars(data.json_data.gross_amount)})` : '(for free)'
  return {
    title: `Redeemed ${data.json_data.quantity} tickets ${paren} for the event: ${data.json_data.event_name}`
  , body: ''
  , icon: 'fa-ticket'
  }
}

exports.Refund = (data, state) => {
  return {
    title: `Refunded $${format.centsToDollars(-data.json_data.gross_amount)}`
  , body: [
      h('div.activity-section', `Reason: ${format.snake_to_words(data.json_data.reason||'none')}. `)
    , viewPaymentLink(data)
    ]
  , icon: 'fa-reply'
  }
}

exports.DisputeCreated = (data, state) => {
  return {
    title: `This supporter disputed their payment for $${format.centsToDollars(data.json_data.gross_amount)} on ${format.date.toSimple(data.json_data.original_date)}`,
    body: [
      h('div.activity-section', `Reason: Disputed as ${format.snake_to_words(data.json_data.reason||'none')}. `),
      h('div.activity-section', [ h('small', 'Please contact the donor and, if the dispute was made in error, ask them to reverse the dispute with their bank/financial institution.')]),
      h('p', [ h('a', {props: {href: `${pathPrefix}/payments?pid=${data.json_data.original_id}`}}, 'View disputed payment.') ]),
    ]
    , icon: 'fa-ban'
  };
}

exports.DisputeFundsWithdrawn = (data, state) => {
  return {
    title: `$${format.centsToDollars(data.json_data.net_amount * -1)} has been withdrawn from your account to cover a dispute issued on ${format.date.toSimple(data.json_data.started_at)}`,
    body: [
      h('div.activity-section', `Reason: Disputed as ${format.snake_to_words(data.json_data.reason||'none')}. `),
      h('div.activity-section', [ h('small', 'If the dispute is won in your favor, the funds will be returned to your account.')]),
      viewPaymentLink(data),
    ],
    icon: 'fa-ban'
  };
}

exports.DisputeFundsReinstated = (data, state) => {
  return {
    title: `$${format.centsToDollars(data.json_data.net_amount)} has been reinstated to your account in regards to the dispute issued on on ${format.date.toSimple(data.json_data.started_at)}`,
    body: [
      viewPaymentLink(data),
    ],
    icon: 'fa-ban'
  };
}

exports.DisputeLost = (data, state) => {
  return {
    title: `The dispute issued on ${format.date.toSimple(data.json_data.started_at)} has been closed and was decided in their favor.`,
    body: [
      h('p', [ h('a', {props: {href: `${pathPrefix}/payments?pid=${data.json_data.original_id}`}}, 'View disputed payment.') ]),
    ],
    icon: 'fa-ban'
  };
}

exports.DisputeWon = (data, state) => {
  return {
    title: `The dispute issued on ${format.date.toSimple(data.json_data.started_at)} has been closed and decided in your favor and the disputed`,
    body: [
      h('div.activity-section', 'The disputed funds have been returned to your account.'),
      h('p', [ h('a', {props: {href: `${pathPrefix}/payments?pid=${data.json_data.original_id}`}}, 'View disputed payment.') ]),
    ],
    icon: 'fa-ban'
  };
}

// we need this for legacy reasons
exports.Dispute = (data, state) => {
  return {
    title: `This supporter disputed (made a charge-back) on their payment for $${format.centsToDollars(data.json_data.gross_amount)} on ${format.date.toSimple(data.json_data.original_date)}`
  , body: [
      h('div.activity-section', data.json_data.reason ? 
        `Reason: Disputed as ${format.snake_to_words(data.json_data.reason||'none')}.` : "None")
    , h('br')
    , viewPaymentLink(data)
    ]
  , icon: 'fa-ban'
  }
}

exports.SupporterNote = (data, state) => {
  const action = data.created_at === data.updated_at ? 'added' : 'edited'
  const canEdit = data.user_id === app.user_id
  return {
    title: `Note ${action}${data.json_data.user_email ? ' by ' + data.json_data.user_email : ''}`
  , body: [
      h('div.activity-section', {props: {innerHTML: marked(data.json_data.content ? data.json_data.content : '')}})
    , canEdit 
      ? h('span', [
          h('a.u-marginRight--10', {on: {click: [state.editNote$, data]}}, 'Edit ')
        , h('span.u-color--red.u-pointer', {on: {click: [state.deleteNote$, data]}}, 'Delete')
        ])
      : ''
    ]
  , icon: 'fa-pencil'
  }
}

exports.SupporterEmail = (data, state) => {
  var jd = data.json_data
  var canView = false
  var body = [h('div.activity-section', `Subject: ${jd.subject}`), h('br')]
  var thread =  h('a', {props: {href: '#'}, on: {click: [state.threadId$, jd.gmail_thread_id]}}, 'View thread')
  
  return {
    title: `Email thread started by ${jd.from}`
  , icon: 'fa-envelope'
  , body: body
 // , body: canView ? R.concat(body, thread) : R.concat(body, signIn)
  }
}

exports.OffsitePayment = (data, state) => {
  const desig = data.json_data.designation ? `Designation: ${data.json_data.designation}. ` : ''
  return {
    title: `Donated $${format.centsToDollars(data.json_data.gross_amount)} (offsite)`
  , body: [
      h('div.activity-section', desig)
    , viewPaymentLink(data)
    ]
  , icon: 'fa-money'
  }
}


