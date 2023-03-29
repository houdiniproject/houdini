// License: LGPL-3.0-or-later
const snabbdom = require('snabbdom')
const h = require('snabbdom/h')
const flyd = require('flyd')
const render = require('ff-core/render')
const notification = require('ff-core/notification')

const format = require('../../../common/format')
const cardForm = require('../../../components/card-form.es6')

function init() {
  var state = {
    card: pageLoadData.card
  , plan: pageLoadData.plan
  , subscription: pageLoadData.subscription
  }

  state.cardForm = cardForm.init({
    name: app.profile.name
  , zip_code: app.nonprofit.zip_code
  , payload: { card: {holder_type: 'Nonprofit', holder_id: app.nonprofit_id, stripe_customer_id: pageLoadData.card.stripe_customer_id}}
  , path: `/nonprofits/${app.nonprofit_id}/card`
  })

  // Notify on card update success
  var message$ = flyd.map(()=>'Successfully updated! Now redirecting...', state.cardForm.saved$)
  state.notification = notification.init({message$})

  // For now, just redirect to settings page after updating card
  flyd.map(resp => { window.location.href = '/settings' }, state.cardForm.saved$)

  return state
}


const view = state =>
  h('div.u-centered.u-maxWidth--600.u-margin--auto.u-marginTop--50.u-padding--15.js-view-confirm', [
    h('h4', `Payment Method for ${app.nonprofit.name}`)
  , state.card.name ? h('p', `Current card: ${state.card.name}`) : ''
  , h('p', [
       ''
    ])
  , h('p.u-strong', `Tier: ${state.plan.name} ($${format.centsToDollars(state.plan.amount)} ${state.plan.interval})`)
  , h('hr')
  , h('h5', 'Update Your  Card:')
  , h('div', [ cardForm.view(state.cardForm) ])

  , h('br'), h('br'), h('br'), h('br') // lol

  , notification.view(state.notification)
  ])


// -- Render
var container = document.querySelector('#js-main')
const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
render({state: init(), view, container, patch})

