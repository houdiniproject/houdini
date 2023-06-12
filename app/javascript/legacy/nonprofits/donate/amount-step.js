// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
const format = require('../../common/format').default
flyd.scanMerge = require('flyd/module/scanmerge')

function init(donationDefaults, params$) {
    var state = {
        params$: params$
        , evolveDonation$: flyd.stream() // Stream of objects that can be used to R.evolve the initial donation object
        , buttonAmountSelected$: flyd.stream(true) // Whether the button or input is selected
        , currentStep$: flyd.stream()
    }

  // A stream of objects that an be used to modify the existing donation by using R.evolve
  donationDefaults = R.merge(donationDefaults, {
    amount: format.dollarsToCents(state.params$().single_amount || 0)
  , designation: state.params$().designation
  , recurring: state.params$().type === 'recurring'
  , weekly: (typeof state.params$().weekly !== 'undefined')
  })
  // Apply R.evolve using every value on the evolveDonation$ stream, starting with the defaults
  state.donation$ = flyd.scanMerge([
    [state.params$ || flyd.stream(), setDonationFromParams]
  , [state.evolveDonation$, R.flip(R.evolve)]
  ], donationDefaults)

    return state
}

const setDonationFromParams = (donation, params) => {
    if(params.single_amount) {
        donation.amount = format.dollarsToCents(params.single_amount)
    }
    else
        donation.amount = undefined
    if(params.designation)
        donation.designation = params.designation
    else
        donation.designation = undefined
    if (params.type === 'recurring')
        donation.recurring = true
    else
        donation.recurring = undefined
    return donation
}

function view(state) {
    const isRecurring = state.donation$().recurring
    return h('div.wizard-step.amount-step', [
        chooseDesignation(state)
        , recurringCheckbox(isRecurring, state)
        , recurringMessage(isRecurring, state)
        , amountFields(state)
        , showSingleAmount(isRecurring, state)
    ])
}


// Dropdown to choose among custom designations
function chooseDesignation(state) {
  if(!state.params$().multiple_designations) return ''
  var defaultDesigs = [
    state.params$().designations_prompt || I18n.t('nonprofits.donate.amount.designation.choose')
  , I18n.t('nonprofits.donate.amount.designation.most_needed')
  ]
  return h('section.u-paddingX--5', {
    class: {'u-hide': !state.params$().multiple_designations}
  }, [
    h('select.donate-designationDropdown.select.u-marginBottom--10', {
      on: { change: ev => state.evolveDonation$({designation: R.always(ev.currentTarget.value)}) }
    }, R.concat(
        R.map(
          d => h('option', {props: {value: ''}}, d)
        , defaultDesigs
        )
      , R.map(
          d => h('option', {props: {value: d}}, d)
        , state.params$().multiple_designations
            )
        )
    )
    ])
}

// Checkbox to make the donation monthly recurring
function recurringCheckbox(isRecurring, state) {
  if(state.params$().type === 'recurring' || state.params$().type === 'one-time') return ''
  return h('section.donate-recurringCheckbox.u-paddingX--5 u-marginBottom--10', [
    h('div.u-padding--8.u-background--grey.u-centered', {
      class: {highlight: isRecurring}
    }, [
      h('input.u-margin--0.donationWizard-amount-input', {
        props: {type: 'checkbox', selected: isRecurring, id: 'checkbox-recurring'}
      , on: {change: ev => state.evolveDonation$({recurring: t => !t})}
      })
    , h('label', {props: {htmlFor: 'checkbox-recurring'}}, composeTranslation(
          I18n.t('nonprofits.donate.amount.sustaining')
        , I18n.t('nonprofits.donate.amount.sustaining_bold')
        )
      )
    ])
    ])
}

// If recurring, an extra message to reinforce that it is in fact charged every month
function recurringMessage(isRecurring, state) {
  if(!isRecurring) return ''
  var label=I18n.t('nonprofits.donate.amount.sustaining_selected')
  var bolded=I18n.t('nonprofits.donate.amount.sustaining_selected_bold');
  if (state.donation$().weekly) {
    label = label.replace(I18n.t('nonprofits.donate.amount.monthly'),I18n.t('nonprofits.donate.amount.weekly'));
     bolded=I18n.t('nonprofits.donate.amount.weekly');
  }
  return h('section.donate-recurringMessage.group', [
    h('p.u-paddingX--5.u-centered', {
      class: {'u-hide': !isRecurring}
    }, [
      state.params$().single_amount ? '' : h('small.info', composeTranslation(label,bolded))
      ])
    ])
}

function prependCurrencyClassname() {
  if (app.currency_symbol === '$') {
    return 'prepend--dollar'
  } else if (app.currency_symbol === '€') {
    return 'prepend--euro'
  }
}

function composeTranslation(full, bold) {
  const texts = full.split(bold)
  if(texts.length > 1) {
    return [texts[0], h('strong', bold), texts[1]]
  } else {
    return full
  }
}

// All the buttons and the custom input for the amounts to select
function amountFields(state) {
  if(state.params$().single_amount) return ''
  return h('div.fieldsetLayout--three--evenPadding', [
    
      ...R.map(
        amt => h('fieldset', [
          h('button.button.u-width--full.white.amount', {
            class: {'is-selected': state.buttonAmountSelected$() && state.donation$().amount === amt*100}
          , on: {click: ev => {
              state.evolveDonation$({amount: R.always(format.dollarsToCents(amt))})
              state.buttonAmountSelected$(true)
              state.currentStep$(1) // immediately advance steps when selecting an amount button
            } }
          }, [
            h('span.dollar', app.currency_symbol)
          , String(amt)
          ])
        ])
    , state.params$().custom_amounts || [] )
    
  , h('fieldset.' + prependCurrencyClassname(), [
      h('input.amount.other', {
        props: {name: 'amount', step: 'any', type: 'number', min: 1, placeholder: I18n.t('nonprofits.donate.amount.custom')}
      , class: {'is-selected': !state.buttonAmountSelected$()}
      , on: {
          focus: ev => state.buttonAmountSelected$(false)
        , change: ev => state.evolveDonation$({amount: R.always(format.dollarsToCents(ev.currentTarget.value))})
        }
      })
    ])
  , h('fieldset', [
      h('button.button.u-width--full.btn-next', {
        props: {type: 'submit', disabled: !state.donation$().amount || state.donation$().amount <= 0}
      , on: {click: [state.currentStep$, 1]}
      }, I18n.t('nonprofits.donate.amount.next'))
    ])
  ])
}

// If the params have a single amount, show a large message saying how much it is
function showSingleAmount(isRecurring, state) {
  if(!state.params$().single_amount) return ''
  var gift = state.params$().gift_option || {}
  if(state.params$().gift_option_name) gift.name = state.params$().gift_option_name
  var desig = state.params$().designation
  return h('section.u-centered', [
    h('p.singleAmount-message', [
      h('strong', app.currency_symbol + format.centsToDollars(format.dollarsToCents(state.params$().single_amount)))
    , h('span.u-padding--0', { class: {'u-hide': !isRecurring} }, ' monthly')
    , h('span', {class: {'u-hide': !state.params$().designation && !gift.id}}, [ ' for ' + (desig || gift.name) ])
    ])
  , h('button.button.u-marginBottom--20', {on: {click: [state.currentStep$, 1]}}, I18n.t('nonprofits.donate.amount.next'))
  ])
}

module.exports = {view, init}

