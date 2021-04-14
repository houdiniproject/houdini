// License: LGPL-3.0-or-later
// npm
const flyd = require('flyd')
const mergeAll = require('flyd/module/mergeall')
const flatMap = require('flyd/module/flatmap')
const lift = require('flyd/module/lift')
const snabbdom = require('snabbdom')
const h = require('snabbdom/h')
const R = require('ramda')
const render = require('ff-core/render')
const modal = require('ff-core/modal')
const notification = require('ff-core/notification')
const button = require('ff-core/button')
const request = require('../../common/request')
// local
const cardForm = require('./card-form.es6')
const readableInterval = require('../../nonprofits/recurring_donations/readable_interval')
const format = require('../../common/format')
const supporterAddressForm = require('../../components/supporter-address-form.es6')
const changeAmountWizard = require('./change-amount-wizard.es6')


function init() {
  var state = {
    submitPaydate$: flyd.stream()
  , confirmCancel$: flyd.stream()
  , changeAmount$: flyd.stream()
  , error$: flyd.stream()
  }
  
  const rdPath = `/recurring_donations/${app.pageLoadData.recurring_donation.id}`
  const rdUpdateAmountPath = `/recurring_donations/${app.pageLoadData.recurring_donation.id}/update_amount`
  const token = utils.get_param('t')
  state.donate_again_url = app.pageLoadData.miscellaneous_np_info.donate_again_url;

  // Paydate update and cancellation streams
  const updatePaydate$ = flatMap(updatePaydate(rdPath), state.submitPaydate$)
  const cancellation$  = flatMap(reqCancel(rdPath), state.confirmCancel$)

state.changeAmountWizard = changeAmountWizard.init( {nonprofit:app.pageLoadData.nonprofit,
        recurring_donation: app.pageLoadData.recurring_donation,
        supporter: app.pageLoadData.supporter,
        custom_amounts: app.pageLoadData.change_amount_suggestions,
        hide_cover_fees_option: !!app.hide_cover_fees_option});
  
        state.addressForm = supporterAddressForm.init({
          supporter: app.pageLoadData.supporter
        , path: rdPath
        , payload: { edit_token: token }
        })


  state.cardForm = cardForm.init({
    card: flyd.stream({
      name: app.pageLoadData.supporter.name
    , address_zip: app.pageLoadData.supporter.zip_code
    })
  , path: '/cards'
  , payload: {
      edit_token: token
    , path: rdPath
    , card: { holder_id: app.pageLoadData.supporter.id, holder_type: 'Supporter'}
    }
  })

  

  // Card update streams
  // update the card id on the recurring donation after the card has been saved on CC
  // (card-form.es6 component will post the card but will not update the card id on the recurring donation)
  state.updateCardID$ = flatMap(
    resp => request({
      method: 'put'
    , path: rdPath
    , send: {edit_token: token, token: resp.token, card_name: resp.name}
    }).load
  , state.cardForm.saved$
  )


  // Stream of notification messages
  const message$ = flyd.mergeAll([
    flyd.map(R.always('Paydate successfully updated'), updatePaydate$)
  , flyd.map(R.always('Address successfully updated'), state.addressForm.response$)
  , flyd.map(R.always('Card successfully updated'), state.updateCardID$)
  ])
  state.notification = notification.init({message$})

  // A bunch of streams that cause the modal to close:
  state.modalID$ = flyd.map(
    R.always(null)
  , mergeAll([
      updatePaydate$
    , state.updateCardID$
    , cancellation$
    , state.addressForm.response$
    ])
  )

  // Stream of vals that cause loading animation to show/hide
  state.loading$ = mergeAll([
    flyd.map(R.always(true), state.submitPaydate$)
  , flyd.map(R.always(true), state.confirmCancel$)
  , flyd.map(R.always(false), updatePaydate$)
  , flyd.map(R.always(false), cancellation$)
  ])

  // Simply replace old recurring donations with new ones based on ajax responses
  const setNew = (old, resp) => resp.body.recurring_donation
  state.recDon$ = flyd.scanMerge([
    [updatePaydate$, setNew]
  , [cancellation$, setNew]
  , [state.updateCardID$, setNew]
  , [state.updateCardAndAmount$, setNew]
  ], app.pageLoadData.recurring_donation)

  return state
}


// -- Stream creator functions

const updatePaydate = path => ev => {
  ev.preventDefault()
  const paydate = Number(ev.currentTarget.querySelector('input').value)
  return request({
    method: 'PUT'
  , path: path
  , send: {edit_token: utils.get_param('t'), paydate: paydate}
  }).load
}


const reqCancel = path => ev => {
  ev.preventDefault()
  return request({
    method: 'delete'
  , path: path
  , send: {edit_token: utils.get_param('t')}
  }).load
}


// -- Virtual DOM functions

function view(state) {
  var rd = state.recDon$()
  var supporter = state.addressForm.supporter$()
  var status = rd.active ? 'Active' : 'Deactivated'
  var interval = rd.active ? readableInterval(rd.interval, rd.time_unit) : 'Deactivated'

  return h('div.u-maxWidth--600.u-margin--auto.u-marginTop--50.u-padding--15.js-view-confirm', [
    h('h3.u-centered.u-marginBottom--20', ['Recurring Donation for ', String(supporter.name|| supporter.email)])
    // Show deactivated notification box if deactivated
  , rd.active ? '' : h('p.u-centered.pastelBox--orange.u-padding--10.u-marginBottom--20', 'This recurring donation has been deactivated')
    // Recurring Donation info table
  , h('table.table--striped.u-marginBottom--50', [
      h('tr', [
        h('td.u-strong', 'Created on')
      , h('td', format.date.toSimple(rd.created_at))
    ])
    , h('tr', [
        h('td.u-strong', 'Recurring amount')
      , h('td', '$' + format.centsToDollars(rd.amount))
    ])
    , h('tr', [
        h('td.u-strong', 'Organization')
      , h('td', [h('a', {props: {href: `/nonprofits/${rd.nonprofit_id}`, target: '_blank'}}, String(rd.nonprofit_name))])
    ])
    , h('tr', [
        h('td.u-strong', 'Card')
      , h('td', String(rd.card_name))
    ])
    , h('tr', [
        h('td.u-strong', 'Donor email')
      , h('td', String(app.pageLoadData.supporter.email))
    ])
    , h('tr', [
        h('td.u-strong', 'Recurring donation status')
      , h('td', String(status))
    ])
    , h('tr', [
        h('td.u-strong', 'Recurring interval')
      , h('td', String(interval))
    ])
    , rd.active
      ? ''
      : h('tr', [
        h('td.u-strong', 'Cancelled By')
      , h('td', String(rd.cancelled_by))
      ])
    , rd.active
      ? ''
      : h('tr', [
        h('td.u-strong', 'Cancelled At')
      , h('td', format.date.readableWithTime(rd.cancelled_at))
      ])
    , h('tr', [
        h('td.strong', 'Address')
      , h('td', [
          h('small', [
            [supporter.address, supporter.city].filter(R.identity).join(', ')
          , h('br')
          , [supporter.state_code, supporter.zip_code, supporter.country].filter(R.identity).join(', ')
        ])
      ])
    ])
    , rd.interval === 1 && rd.time_unit === 'month'
      ? h('tr', [
          h('td.u-strong', 'Fixed paydate')
        , h('td', String(rd.paydate ? rd.paydate : 'None'))
      ])
      : ''
    ])
  , actions(state)
  , rd.active ? '' : reactivate(rd.nonprofit_id)
  , cancelModal(state)
  , updateCardModal(state)
  , editPaydateModal(state)
  , updateAddressModal(state)
  , changeAmountModal(state)
  , notification.view(state.notification)
  ])
}


const reactivate = np_id =>
  h('p.u-centered', [ h('a.button', {props: {href: `/nonprofits/${np_id}/donate`}}, 'Reactivate') ])


function actions(state) {
  var rd = state.recDon$()
  if(!rd.active) return ''
  var modalID$ = state.modalID$
  return h('div.pastelBox--looseleaf.u-padding--15.u-marginBottom--50', [
    h('p.u-strong.u-centered', 'What would you like to do?')
  , h('ul.hasBullets.u-maxWidth--400.u-margin--auto', [
      h('li', [changeAmountBtn(modalID$)])
    , h('li', [updateCardBtn(modalID$)])

    , h('li', [updateAddressBtn(modalID$)])
    , rd.interval === 1 && rd.time_unit === 'month'
        ? h('li', [updatePaydateBtn(modalID$)])
        : ''
    , h('li', [giveOneTimeDonationBtn(state)])
    , h('li', [cancelBtn(modalID$)])
    ])
  ])
}


const changeAmountBtn = modalID$ =>
    h('strong', [
        h('a.test-changeAmount', {
            on: {click: [modalID$, 'changeAmountModal']}
        }, 'Change my donation amount')
    ])

const updateCardBtn = modalID$ => 
  h('strong', [
    h('a.test-updateCard', {
      on: {click: [modalID$, 'updateCardModal']}
    }, 'Update my card')
  ])


const cancelBtn = modalID$ =>
  h('strong', [
    h('a.test-cancelDonation', {
      on: {click: [modalID$, 'cancelRecDonModal']}
    }, 'Cancel my recurring donation')
  ])


const updatePaydateBtn = modalID$ =>
  h('strong', [
    h('a', {
      on: {click: [modalID$, 'editPaydateModal']}
    }, 'Change the day I\'m billed')
  ])


const updateAddressBtn = modalID$ =>
  h('strong', [
    h('a', {
      on: {click: [modalID$, 'updateAddressModal']}
    }, 'Update my address')
  ])


const giveOneTimeDonationBtn = (state) =>
    h('strong', [
        h('a', {
            props:{href: state.donate_again_url}
        }, 'Give a one-time donation')
    ])


const cancelModal = state =>
  modal({
    thisID: 'cancelRecDonModal'
  , id$: state.modalID$
  , body: h('div.u-marginTop--30.u-centered', [
      h('p.u-marginBottom--20.u-strong', [
        h('span', `If you need to pause your donation due to financial hardship, please contact ${String(state.recDon$().nonprofit_name)} by sending them an email at `),
        h('a', {props: {href: `mailto:${app.nonprofit.email}`}}, String(app.nonprofit.email)),
        h('span', ' with how long you would like the pause to occur.')
      ])
    , h('hr.diamonds.u-marginBottom--40')
    , h('p.u-strong', 'Cancelling your recurring donation will prevent any future charges for this donation.')
    , h('hr.diamonds')
    , h('div.u-marginTop--30', [confirmCancelBtn(state)])
    ])
  })


const updateCardModal = state =>
  modal({
    thisID: 'updateCardModal'
  , id$: state.modalID$
  , title: 'Update Card'
  , body: cardForm.view(state.cardForm)
  })

const changeAmountModal = state =>
    modal({
        thisID: 'changeAmountModal'
        , id$: state.modalID$
        , title: 'Change Amount'
        , body: changeAmountWizard.view(state.changeAmountWizard)
    })


const editPaydateModal = state =>
  modal({
    thisID: 'editPaydateModal'
  , id$: state.modalID$
  , title: 'Edit Paydate'
  , body: paydateForm(state)
  })


const updateAddressModal = state =>
  modal({
    thisID: 'updateAddressModal'
  , id$: state.modalID$
  , title: 'Edit your address'
  , body: supporterAddressForm.view(state.addressForm)
  })


const paydateForm = state =>
  h('form', { on: {submit: state.submitPaydate$} }, [
    h('p', 'Enter a day of the month (between 1 and 28) when you want to be charged for this donation.')
  , h('p', 'This will fix your donations to that date each month for all future payments.')
  , h('input.input--small', {
      props: {
        type: 'number'
      , max: 28
      , min: 1
      , name: 'paydate'
      , value: state.recDon$().paydate || 1
      }
    })
  , h('br')
  , button(R.pick(['loading$', 'error$'], state))
  ])


const confirmCancelBtn = state =>
  h('form', { on: { submit: state.confirmCancel$ } }, [
    button({
      buttonText: 'Cancel My Donation'
    , loading$: state.loading$
    , error$: state.error$
    , buttonClass: 'red'
    })
  ])


// -- Render to the page

var container = document.querySelector('#js-main')
const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
var state = init()
render({patch, view, state, container})

