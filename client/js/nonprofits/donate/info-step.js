// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
const uuid = require('uuid')
const supporterFields = require('../../components/supporter-fields')
const dedicationForm = require('./dedication-form')
const serialize = require('form-serialize')
const request = require('../../common/request')
const format = require('../../common/format')
const { default: customFields } = require('./components/info-step/customFields')
const { formatFormData } = require('./components/info-step/utils');

const sepaTab = 'sepa'
const cardTab = 'credit_card'

function init(donation$, parentState) {
//console.log(donation$().val);
  var state = {
    donation$: donation$
  , submitSupporter$: flyd.stream()
  , submitDedication$: flyd.stream()
  , params$: parentState.params$
  , currentStep$: flyd.stream()
  , selectedPayment$: parentState.selectedPayment$
  , donationAmount$: parentState.donationAmount$
  }

  // Save supporter for dedication logic
  state.dedicationData$ = flyd.map(form => serialize(form, {hash: true}), state.submitDedication$)
  const dedicationSuppData$ = flyd.map(
    data => R.merge(
      R.pick(['phone', 'email', 'address'], data)
    , {name: `${data.first_name||''} ${data.last_name||''}`}
    )
  , state.dedicationData$
  )
  state.showDedicationForm$ = flyd.map(()=> false, state.submitDedication$)

  // Save donor supporter record
  const formData$ = flyd.map(formatFormData, state.submitSupporter$)

  state.supporterFields = supporterFields.init({required: {email: true}}, state.params$)
  state.savedSupp$ = flyd.flatMap(postSupporter, flyd.map(
    supporter => ({ ...supporter, tags: state.params$().tags }),
    formData$
  ))

  state.savedDedicatee$ = flyd.map(
    supporter => ({supporter, note: state.dedicationData$().dedication_note, type: state.dedicationData$().dedication_type})
  , flyd.flatMap(postSupporter, dedicationSuppData$)
  )
  const changedDedication$ = flyd.merge(state.dedicationData$, state.savedDedicatee$)
  state.supporter$ = flyd.merge(flyd.stream({}), state.savedSupp$)

  return state
}


const postSupporter = supporter =>
  flyd.map(
    resp => resp.body
  , request({
      method: 'post'
    , path: `/nonprofits/${app.nonprofit_id}/supporters`
    , send: {supporter: R.merge(supporter, {locale: I18n.locale})}
    }).load
  )


function recurringMessage(state){
//function recurringMessage(isRecurring, state) {
  var isRecurring=state.donation$().recurring;
  var amountLabel = isRecurring ? ` ${I18n.t('nonprofits.donate.payment.monthly_recurring')}` : ` ${I18n.t('nonprofits.donate.payment.one_time')}`
  var weekly= "";
  if (state.donation$().weekly) {
    amountLabel =   amountLabel.replace(I18n.t('nonprofits.donate.amount.monthly'),I18n.t('nonprofits.donate.amount.weekly')) + "*";
    weekly= h('div.u-centered.notice',[h("small",I18n.t('nonprofits.donate.amount.weekly_notice',{amount:(format.weeklyToMonthly(state.donationAmount$())/100.0),currency:app.currency_symbol}))]);

  }
  return h('div', [
    h('p.u-fontSize--18 u.marginBottom--0.u-centered.amount', [
      h('span', app.currency_symbol + format.centsToDollars(state.donationAmount$()))
    , h('strong', amountLabel)
    ])
  , weekly]
  )
}

function view(state) {

  var form = h('form', {
    on: {
      submit: ev => {ev.preventDefault(); state.currentStep$(2); state.submitSupporter$(ev.currentTarget)}
    }
  }, [
  recurringMessage(state)
  , supporterFields.view(state.supporterFields)
  , customFields(state.params$().custom_fields)
  , dedicationLink(state)
  , anonField(state)
  , h('div', paymentMethodButtons(["card"], state))
  ])
  return h('div.wizard-step.info-step.u-padding--10', [
    form
  , h('div', {
      style: {background: '#f8f8f8', position: 'absolute', 'top': '0', left: '3px', height: '100%', width: '99%'}
    , class: {'u-hide': !state.showDedicationForm$(), opacity: 0, transition: 'opacity 1s', delay: {opacity: 1}}
    }, [dedicationForm.view(state)] )
  ])
}

function paymentMethodButtons(paymentMethods, state){
  return h('section.group'), [
    paymentButton({error$: state.errors$, buttonText: 'Next'}, cardTab, state)
    ]
}

function paymentButton(options, label, state){
  options.error$ = options.error$ || flyd.stream()
  options.loading$ = options.loading$ || flyd.stream()

  let btnclass={ 'ff-button--loading': options.loading$() };
  btnclass[label]=true;

  return h('div.ff-buttonWrapper.u-centered.u-marginTop--10', {
    class: { 'ff-buttonWrapper--hasError': options.error$() }
  }, [
    h('p.ff-button-error', {style: {display: options.error$() ? 'block' : 'none'}} , options.error$())
  , h('button.ff-button', {
      props: { type: 'submit', disabled: options.loading$() }
    , on: { click: e => state.selectedPayment$(label) }
    , class: btnclass
    }, [
      options.loading$() ? (options.loadingText || " Saving...") : (options.buttonText ||  I18n.t('nonprofits.donate.payment.card.submit'))
    ])
  ])
}

function anonField(state) {
  if (state.params$().hide_anonymous) return '';

  state.anon_id = state.anon_id || uuid.v1() // we need a unique id in case there are multiple supporter forms on the page -- the label 'for' attribute needs to be unique
  return h('div.u-marginTop--10.u-centered', [
    h('input', {
      props: {
        type: 'checkbox'
      , name: 'anonymous'
      , checked: state.anonymous
      , id: `anon-checkbox-${state.anon_id}`
      }
    })
  , h('label', {
      props: {
        type: 'checkbox'
      , htmlFor: `anon-checkbox-${state.anon_id}`
      , id: 'anonLabel'
      }
    }, [
      h('small', I18n.t('nonprofits.donate.info.anonymous_checkbox'))
    ])
  ])
}

const dedicationLink = state => {
  if(state.params$().hide_dedication) return ''
  return h('label.u-centered.u-marginTop--10', [
    h('small', [
      h('a', {
        on: { click: [state.showDedicationForm$, true] },
        style: {'border-width': 'thin', 'border-style': 'solid', padding: '2px', 'border-color': `${app.nonprofit.brand_color || '#4DAE7F'}`, 'border-radius': '2px', 'box-shadow': `3px 3px ${app.nonprofit.brand_color || '#4DAE7F'}7F`}
      }, state.dedicationData$() && state.dedicationData$().first_name
      ? [h('i.fa.fa-check'), I18n.t('nonprofits.donate.info.dedication_saved') + `${state.dedicationData$().first_name || ''} ${state.dedicationData$().last_name || ''}`]
      : [I18n.t('nonprofits.donate.info.dedication_link')]
      )
    ])
  ])
}


module.exports = {view, init}
