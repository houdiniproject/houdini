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
// local
const request = require('../common/request')
const formatErr = require('../common/format_response_error')
const createCardStream = require('../cards/create-frp.es6')
const serializeForm = require('form-serialize')
const luhnCheck = require('../common/credit-card-validator.js')

// A component for filling out card data, validating it, saving the card to
// stripe, and then saving a tokenized copy to our servers.

// Form validation constraints, validator functions, and error messages:
var constraints = {
  address_zip: {required: true}
, name: {required: true}
, number: {required: true, cardNumber: true}
, exp_month: {required: true, format: /\d\d?/}
, exp_year: {required: true, format: /\d\d?/}
, cvc: {required: true, format: /\d\d\d\d?/}
}
var validators = { cardNumber: luhnCheck }
var messages = {
  number: {
    required: I18n.t('nonprofits.donate.payment.card.errors.number.presence')
  , cardNumber:  I18n.t('nonprofits.donate.payment.card.errors.number.format')
  }
  , required: I18n.t('nonprofits.donate.payment.card.errors.field.presence')
  , email: I18n.t('nonprofits.donate.payment.card.errors.email.format')
  , format: I18n.t('nonprofits.donate.payment.card.errors.field.format')
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

  state.form = validatedForm.init({constraints, validators, messages})
  state.card$ = flyd.merge(flyd.stream(state.card || {}), state.form.validData$)

  // streams of stripe tokenization responses
  const stripeResp$ = flyd.flatMap(createCardStream, state.form.validData$)
  state.stripeRespOk$  = flyd.filter(r => !r.error, stripeResp$)
  const stripeError$ = flyd.map(r => r.error.message, flyd.filter(r =>  r.error, stripeResp$))
 
  // Save the card as a card table on our own db
  // streams of responses
  state.resp$ = flyd.flatMap(
    resp => saveCard(state.payload$(), state.path$(), resp) // cheating on the streams here..
  , state.stripeRespOk$ )

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
   , name: `${resp.card.brand} *${resp.card.last4}`
   , stripe_card_token: resp.id
   , stripe_card_id: resp.card.id
  })
  return flyd.map(R.prop('body'), request({ path, send, method: 'post' }).load)
}


// -- Virtual DOM

const view = state => {
  var field = validatedForm.field(state.form)
  return validatedForm.form(state.form, h('form.cardForm', [
    h('div.u-background--grey.group.u-padding--8', [
      nameInput(field, state.card$().name)
    , numberInput(field)
    , cvcInput(field)
    , expMonthInput(field)
    , expYearInput(field)
    , zipInput(field, state.card$().address_zip)
    ])
  , h('div.u-centered.u-marginTop--20', [
      state.hideButton ? '' : button({
        error$: state.hideErrors ? flyd.stream() : state.error$
      , loading$: state.loading$
      , buttonText: I18n.t('nonprofits.donate.payment.card.submit')
      , loadingText: ` ${I18n.t('nonprofits.donate.payment.card.loading')}`
      })
     , h('p.u-fontSize--12.u-marginBottom--0.u-marginTop--10.u-color--grey', [ h('i.fa.fa-lock'), ` ${I18n.t('nonprofits.donate.payment.card.secure_info')}`])
    ])
  ]) )
}


const nameInput = (field, name) => 
  h('fieldset', [ field(h('input', { props: { name: 'name' , value: name || '', placeholder: I18n.t('nonprofits.donate.payment.card.name') } })) ])


const numberInput = field =>
  h('fieldset.col-8', [ field(h('input', {props: { type: 'text' , name: 'number' , placeholder: I18n.t('nonprofits.donate.payment.card.number') } })) ])


const cvcInput = field =>
  h('fieldset.col-right-4.u-relative', [
    field(h('input', { props: { name: 'cvc' , placeholder: I18n.t('nonprofits.donate.payment.card.cvc') } } ))
  , h('img.security-code-image', {
      src: `${app.asset_path}/graphics/cc-security-code.png`
    })
  ])


const expMonthInput = field => {
  var options = R.prepend(
    h('option.default', {props: {value: undefined, selected: true}}, I18n.t('nonprofits.donate.payment.card.month'))
  , R.range(1, 13).map(n => h('option', String(n)))
  )
  return h('fieldset.col-3.u-margin--0', [
    field(h('select.select'
  , { props: {name: 'exp_month'} }
  , options))
  ])
}


const expYearInput = field => {
  var yearRange = R.range(new Date().getFullYear(), new Date().getFullYear() + 15)
  var options = R.prepend(
    h('option.default', {props: {value: undefined, selected: true}}, I18n.t('nonprofits.donate.payment.card.year'))
  , R.map(y => h('option', String(y)), yearRange)
  )
  return h('fieldset.col-left-3.u-margin--0', [
    field(h('select.select'
  , {props: {name: 'exp_year'}}
  , options)) 
  ])
}


const zipInput = (field, zip) => 
  h('fieldset.col-right-6.u-margin--0', [
    field(h('input'
    , { props: {
        type: 'text'
      , name: 'address_zip'
      , value: zip || ''
      , placeholder: I18n.t('nonprofits.donate.payment.card.postal_code')
      }} 
    ))
  ])


module.exports = {view, init}

