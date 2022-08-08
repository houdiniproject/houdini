// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const validatedForm = require('ff-core/validated-form')
const button = require('ff-core/button')
const flyd = require('flyd')
flyd.flatMap = require('flyd/module/flatmap')
flyd.filter = require('flyd/module/filter')
flyd.sampleOn = require('flyd/module/sampleon')
const scanMerge = require('flyd/module/scanmerge')
const IBAN = require('iban')


const request = require('../common/request')

// Form validation constraints, validator functions, and error messages:
const constraints = {
  name: {required: true}
, iban: {required: true, ibanFormat: /[a-zA-Z]{2}\d{14}/}
, bic: {required: true}
}

const validators = { ibanFormat: IBAN.isValid }

//  You can pass in the .hideButton boolean if you want to control whether the submit button is shown/hidden
//  Pass in a .card object, which can have default objects for the card form (name, number, cvc, exp_month, etc)
//  Pass in .path to set the endpoint for saving the card
//  Pass in .payload for default data to send to the server for every card save request (such as a request token)
const init = (state) => {
  state = state || {}

  var messages = {
    required: I18n.t('nonprofits.donate.payment.card.errors.field.presence')
    , ibanFormat: I18n.t('nonprofits.donate.payment.card.errors.field.format')
  }

  state.form = validatedForm.init({constraints, validators, messages})
  state.supp$ = flyd.sampleOn(state.form.validData$, state.supporter)
  state.sepa$ = flyd.combine((supporter, sepaParams) => {
    return {sepa_params: sepaParams(), supporter_id: supporter()}
  }, [state.supp$, state.form.validData$])

  const response$ = flyd.flatMap(saveTransferData, state.sepa$)
  state.reponseOk$ = flyd.filter(response => !response.error, response$)
  state.error$ = flyd.map(R.prop('error'), flyd.filter(response => response.error, state.reponseOk$))
  state.saved$ = flyd.filter(response => !response.error, state.reponseOk$)

  state.loading$ = scanMerge([
    [state.form.validSubmit$, R.always(true)]
  , [state.error$, R.always(false)]
  , [state.saved$, R.always(false)]
  ], false)

  return state
}

// Save transfer details to our own servers, and return a response stream
function saveTransferData(params){
  return flyd.map(R.prop('body'), request({
      method: 'post'
    , path: '/sepa'
    , send: params
    }).load
  )
}

// -- Virtual DOM

const view = state => {
  var field = validatedForm.field(state.form)
  return validatedForm.form(state.form, h('form.sepaForm', [
    h('div.u-background--grey.group.u-padding--8', [
      nameInput(field)
    , ibanInput(field)
    , bicInput(field)
    ])
  , h('div.u-centered', [
      button({
        error$: state.hideErrors ? flyd.stream() : state.error$
      , buttonText: I18n.t('nonprofits.donate.payment.card.submit')
      , loadingText: ` ${I18n.t('nonprofits.donate.payment.card.loading')}`
      , loading$: state.loading$
      })
    ])
  ])
 )
}

const nameInput = (field, name) =>
  h('fieldset', [
    field(h('input.u-margin--0',
      { props: { name: 'name' , value: name || '', placeholder: I18n.t('nonprofits.donate.payment.sepa.name') } }
    ))
  ])

const ibanInput = field =>
  h('fieldset.col-12.u-margin--0', [
    field(h('input.u-margin--0',
      {props: { type: 'text' , name: 'iban' , placeholder: I18n.t('nonprofits.donate.payment.sepa.iban') } }
    ))
  ])

const bicInput = field =>
  h('fieldset.col-right-0.u-margin--0', [
    field(h('input.u-margin--0.hidden',
      { props: { name: 'bic' , type: 'hidden', value:'NOTPROVIDED', placeholder: I18n.t('nonprofits.donate.payment.sepa.bic') } }
    ))
  ])

module.exports = {view, init}
