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
        , recurring: state.params$().type === 'recurring'
    })
    // Apply R.evolve using every value on the evolveDonation$ stream, starting with the defaults
    state.donation$ = flyd.scanMerge([
        [state.params$ || flyd.stream(), setDonationFromParams]
        , [state.evolveDonation$, R.flip(R.evolve)]
    ], donationDefaults)

    return state
}

const setDonationFromParams = (donation, params) => {
    if(params.single_amount) donation.amount = format.dollarsToCents(params.single_amount)
    if(params.designation) donation.designation = params.designation
    donation.recurring = params.type === 'recurring'
    return donation
}

function view(state) {
    const isRecurring = state.donation$().recurring
    return h('div.wizard-step.amount-step', [
        chooseNewDonationAmount()
        , amountFields(state)
    ])
}

// If recurring, an extra message to reinforce that it is in fact charged every month
function recurringMessage(isRecurring, state) {
    if(!isRecurring) return ''
    return h('section.donate-recurringMessage.group', [
        h('p.u-paddingX--5.u-centered', {
            class: {'u-hide': !isRecurring}
        }, [
            state.params$().single_amount ? '' : h('small', [
                'Select an amount for your '
                , h('strong', 'monthly')
                , ' contribution'
            ])
        ])
    ])
}


function chooseNewDonationAmount() {

    return h('section.donate-recurringMessage.group', [
        h('p.u-paddingX--5.u-centered', 'Choose your new donation amount')
    ])
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
                        h('span.dollar', '$')
                        , String(amt)
                    ])
                ])
                , state.params$().custom_amounts || [] )
        
        , h('fieldset.prepend--dollar', [
            h('input.amount', {
                props: {name: 'amount', step: 'any', type: 'number', min: 1, placeholder: 'Custom'}
                , class: {'is-selected': !state.buttonAmountSelected$()}
                , on: {
                    focus: ev => state.buttonAmountSelected$(false)
                    , change: ev => state.evolveDonation$({amount: R.always(format.dollarsToCents(ev.currentTarget.value))})
                }
            })
        ])
        , h('fieldset', [
            h('button.button.u-width--full', {
                props: {type: 'submit', disabled: !state.donation$().amount || state.donation$().amount <= 0}
                , on: {click: [state.currentStep$, 1]}
            }, 'Next')
        ])
    ])
}



module.exports = {view, init}