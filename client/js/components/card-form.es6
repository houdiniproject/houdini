// License: LGPL-3.0-or-later
// npm
const h = require('snabbdom/h')
const R = require('ramda')
const validatedForm = require('ff-core/validated-form')
const button = require('ff-core/button')
const flyd = require('flyd')
flyd.flatMap = require('flyd/module/flatmap')
flyd.filter = require('flyd/module/filter')
flyd.mergeAll = require('flyd/module/mergeall')
const scanMerge = require('flyd/module/scanmerge')
const uniqueId = require('lodash/uniqueId')
// local
const request = require('../common/request')
const createCardStream = require('../cards/create-frp.es6')

const create_card_element = require('../../../javascripts/src/lib/create_card_element.ts')

// A component for filling out card data, validating it, saving the card to
// stripe, and then saving a tokenized copy to our servers.

// Form validation constraints, validator functions, and error messages:
// A component for filling out card data, validating it, saving the card to
// stripe, and then saving a tokenized copy to our servers.

// Form validation constraints, validator functions, and error messages:
var constraints = {
  name: { required: true }
}
var validators = {}
var messages = {
  required: I18n.t('nonprofits.donate.payment.card.errors.field.presence')
}

//  You can pass in the .hideButton boolean if you want to control whether the submit button is shown/hidden
//  Pass in a .card object, which can have default objects for the card form (name, number, cvc, exp_month, etc)
//  Pass in .path to set the endpoint for saving the card
//  Pass in .payload for default data to send to the server for every card save request (such as a request token)
const init = (state) => {
  state = state || {}
  // set defaults
  state = R.merge({
    payload$: flyd.stream(state.payload || {})
    , path$: flyd.stream(state.path || '/cards')
  }, state)

  state.cardAreaId = uniqueId('ff_card_area_id-')

  state.form = validatedForm.init({ constraints, validators, messages })
  state.element = create_card_element.createElement()

  var formAddressZip$ = flyd.stream()
  state.element.on('change', (payload) => {
    formAddressZip$(payload.value['postalCode'])
  })
  state.card$ = flyd.merge(state.card$ || flyd.stream({}), state.form.validData$)

  state.formAddressMerged$ = flyd.merge(flyd.map(r => r.address_zip, state.card$), formAddressZip$)

  state.elementMounted = false
  // streams of stripe tokenization responses
  const stripeResp$ = flyd.flatMap((i) => {
    return createCardStream(state.element, state.form.validData$().name)
  }, state.form.validData$)
  state.stripeRespOk$ = flyd.filter(r => !r.error, stripeResp$)
  const stripeError$ = flyd.map(r => r.error.message, flyd.filter(r => r.error, stripeResp$))

  // Save the card as a card table on our own db
  // streams of responses
  state.resp$ = flyd.flatMap(
    resp => saveCard(state.payload$(), state.path$(), resp) // cheating on the streams here..
    , state.stripeRespOk$)

  const ccError$ = flyd.map(R.prop('error'), flyd.filter(resp => resp.error, state.resp$))
  state.saved$ = flyd.filter(resp => !resp.error, state.resp$)
  state.error$ = flyd.merge(stripeError$, ccError$)

  state.loading$ = scanMerge([
    [state.form.validSubmit$, R.always(true)]
    , [state.error$, R.always(false)]
    , [state.saved$, R.always(false)]
  ], false)

  return state
}


// -- Stream-related functions

// Save the card to our own servers, and return a response stream
const saveCard = (send, path, resp) => {
  send.card = R.merge(send.card, {
    cardholders_name: resp.name
    , name: `${resp.token.card.brand} *${resp.token.card.last4}`
    , stripe_card_token: resp.token.id
    , stripe_card_id: resp.token.card.id
  })
  return flyd.map(R.prop('body'), request({ path, send, method: 'post' }).load)
}

const mount = state => {
  if (!state.elementMounted) {
    state.element.mount(`#${state.cardAreaId}`)
    state.elementMounted = true
  }
}

const unmount = state => {
  if (state.elementMounted) {
    state.element.unmount(`#${state.cardAreaId}`)
    state.elementMounted = false
  }
}


// -- Virtual DOM

const view = state => {
  if (state.formAddressMerged$()) {
    state.element.update({ value: { postalCode: state.formAddressMerged$() } })
  }

  var field = validatedForm.field(state.form)
  return validatedForm.form(state.form, h('form.cardForm', [
    h('div', [
      nameInput(field, state.card$().name)
      , h(`div#${state.cardAreaId}`, {
        hook: {
          insert: () => mount(state),
          remove: () => unmount(state)
        }
      })
      , profileInput(field, app.profile_id)
      , feeCoverageField(state)
    ])
    , h('div.u-centered.u-marginTop--20', [
      state.hideButton ? '' : button({
        error$: state.hideErrors ? flyd.stream() : state.error$
        , loading$: state.loading$
        , buttonText: I18n.t('nonprofits.donate.payment.card.submit')
        , loadingText: ` ${I18n.t('nonprofits.donate.payment.card.loading')}`
      })
      , h('p.u-fontSize--12.u-marginBottom--0.u-marginTop--10.u-color--grey', [h('i.fa.fa-lock'), ` ${I18n.t('nonprofits.donate.payment.card.secure_info')}`])
    ])
  ]))
}

function feeCoverageField(state) {
  return h('section.donate-feeCoverageCheckbox.u-marginBottom--10.u-marginTop--20', [
      h('input.u-margin--0.donationWizard-amount-input', {
        props: { type: 'checkbox', checked: state.coverFees$(), id: 'checkbox-feeCoverage' }
        , on: {
          change: ev => {
            state.coverFees$(!state.coverFees$())
          }
        }
      })
      , h('label.checkbox-feeCoverage-label', { props: { htmlFor: 'checkbox-feeCoverage', type: 'checkbox' } },
        [
          h('div',
            {},
            [
              h('small', [I18n.t('nonprofits.donate.amount.feeCoverage.header') + "! Cover ",
              h('strong', state.potentialFees$()),
                " in processing fees"])
            ]
          )
        ])

    
  ])
}

const nameInput = (field, name) =>
  h('fieldset', [field(h('input', { props: { name: 'name', value: name || '', placeholder: I18n.t('nonprofits.donate.payment.card.name') } }))])


const profileInput = (field, profile_id) =>
  field(h('input'
    , {
      props: {
        type: 'hidden'
        , name: 'profile_id'
        , value: profile_id || ''
      }
    }
  ))

module.exports = { view, init, mount }

