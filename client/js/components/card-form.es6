// License: LGPL-3.0-or-later
// npm
const h = require('snabbdom/h')
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

const grecaptchaPromised = require('../../../javascripts/src/lib/grecaptcha_during_payment').default

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
  state = {
    payload$: flyd.stream(state.payload || {})
    , path$: flyd.stream(state.path || '/cards')
    , ...state
  }

  state.cardAreaId = uniqueId('ff_card_area_id-')

  state.form = validatedForm.init({ constraints, validators, messages })
  state.element = create_card_element.createElement({hidePostalCode: true})


  state.card$ = flyd.merge(state.card$ || flyd.stream({}), state.form.validData$)

  state.elementMounted = false
  // streams of stripe tokenization responses
  const stripeResp$ = flyd.flatMap((i) => {

    if (state.form.validData$().address_zip) {
      state.element.update({ value: { postalCode: state.form.validData$().address_zip } })
    }
    return createCardStream(state.element, state.form.validData$().name)
  }, state.form.validData$)
  state.stripeRespOk$ = flyd.filter(r => !r.error, stripeResp$)
  const stripeError$ = flyd.map(r => r.error.message, flyd.filter(r => r.error, stripeResp$))

  const recaptchaKey$ = flyd.flatMap((resp) => {
    return flyd.stream(grecaptchaPromised(resp).catch(i => i))
  }, state.stripeRespOk$)

  const recaptchaKeyOk$ = flyd.filter(r => !r.message, recaptchaKey$)

  // Save the card as a card table on our own db
  // streams of responses
  state.resp$ = flyd.flatMap((resp) => {

    //handle cases where the recaptcha is in error
    return saveCard(state.payload$(), state.path$(), resp.stripe_resp, resp.recaptcha_token)
  }, recaptchaKeyOk$)

  const recaptchaError$ = flyd.map(m => m.message, flyd.filter(resp => {
    return resp.message
  }, recaptchaKey$))

  const ccError$ = flyd.map(r => r.error, flyd.filter(resp => resp.error, state.resp$))
  state.saved$ = flyd.filter(resp => !resp.error, state.resp$)
  state.error$ = flyd.merge(stripeError$, flyd.merge(ccError$, recaptchaError$))

  state.loading$ = scanMerge([
    [state.form.validSubmit$, () => true]
    , [state.error$, () => false]
    , [state.saved$, () => false]
  ], false)

  return state
}


// -- Stream-related functions


// Save the card to our own servers, and return a response stream
const saveCard = (send, path, resp, recaptcha_token) => {
  send = {
    ...send,
    'g-recaptcha-response': recaptcha_token
  }
  send.card = {
    ...send.card
    , cardholders_name: resp.name
    , name: `${resp.token.card.brand} *${resp.token.card.last4}`
    , stripe_card_token: resp.token.id
    , stripe_card_id: resp.token.card.id
  }

  return flyd.map(r => r.body, request({ path, send, method: 'post' }).load)
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

  var field = validatedForm.field(state.form)
  return validatedForm.form(state.form, h('form.cardForm', [
    h('div', [
      h('section.group.name-zip', [
      nameInput(field, state.card$().name)
      , zipInput(field, state.card$().address_zip)
    ])
      , h(`div#${state.cardAreaId}`, {
        hook: {
          insert: () => mount(state),
          remove: () => unmount(state)
        }
      })
      
      , profileInput(field, app.profile_id)
      , !state.hide_cover_fees_option$() ? feeCoverageField(state) : ''
    ])
    , h('div.u-centered.u-marginTop--20', [
      state.hideButton ? '' : button({
        error$: state.hideErrors ? flyd.stream() : state.error$
        , loading$: state.loading$
        , buttonText: I18n.t('nonprofits.donate.payment.card.submit')
        , loadingText: ` ${I18n.t('nonprofits.donate.payment.card.loading')}`
      })
      , state.hideButton ? '' : h('div.u-fontSize--12.u-marginBottom--0.u-marginTop--10.u-color--grey.u-security-notification', [h('i.fa.fa-lock.u-security-icon'),
      h('div',
        [h('span', 'Transactions secured with 256-bit SSL and protected by reCAPTCHA Enterprise. The Google '),
          h('a', {props: { href: 'https://policies.google.com/privacy', target:"_new", style:"color: grey!important; text-decoration:underline;" }}, 'Privacy Policy'),
          h('span',' and '),
          h('a', {props: { href: 'https://policies.google.com/terms', target:"_new", style:"color: grey!important; text-decoration:underline;"  }}, 'Terms of Service'),
          h('span', ' apply.')]
      )
      ])
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
  h('fieldset.name', [field(h('input', { props: { name: 'name', value: name || '', placeholder: I18n.t('nonprofits.donate.payment.card.name') } }))])


const zipInput = (field, zip) =>
  h('fieldset.zip', [
    field(h('input'
    , { props: {
        type: 'text'
      , name: 'address_zip'
      , value: zip || ''
      , placeholder: I18n.t('nonprofits.donate.payment.card.postal_code')
      }}
    ))
  ])

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

