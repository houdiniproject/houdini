// License: LGPL-3.0-or-later
const flyd = require('flyd')
const R = require('ramda')
const h = require('snabbdom/h')
const url = require('url')
const render = require('ff-core/render')
const wizard = require('ff-core/wizard')
const scanMerge = require('flyd/module/scanmerge')
flyd.mergeAll = require('flyd/module/mergeall')
flyd.flatMap = require('flyd/module/flatmap')
flyd.zip = require('flyd-zip')

const getParams = require('./get-params')

const paymentStep = require('./payment-step.es6')
const amountStep = require('./amount-step.es6')
const followupStep = require('./followup-step')

const request = require('../../common/request')
const format = require('../../common/format')

const brandedWizard = require('./branded-wizard.es6')
const renderStyles = require('../../components/styles/render-styles')



// pass in a stream of configuration parameters
const init = params => {
    var state = {
        error$: flyd.stream()
        , loading$: flyd.stream()
        , clickFinish$: flyd.stream()
        , params$: flyd.map(getParams, flyd.stream(params))
    }

    renderStyles()(brandedWizard(state.params$().nonprofit.brand_color ? state.params$().nonprofit.brand_color : null))

    app.campaign = app.campaign || {} // so we don't have to hot switch all the calls to app.campaign.name, etc
    var donationDefaults = setDonationFromParams({
        nonprofit_id: app.nonprofit_id
        , campaign_id: app.campaign.id
        , event_id: app.event_id
    }, state.params$())

    state.amountStep = amountStep.init(donationDefaults, state.params$)

    state.donation$ = scanMerge([
        [state.amountStep.donation$, R.merge]

        , [state.params$, setDonationFromParams]

    ], donationDefaults )

    state.paymentStep = paymentStep.init(state.params$, state.donation$)

    const currentStep$ = flyd.mergeAll([
        state.amountStep.currentStep$
        , flyd.map(R.always(0), state.params$) // if the params ever change, jump back to step one
        , flyd.stream(0)
    ])
    state.wizard = wizard.init({currentStep$, isCompleted$: state.paymentStep.success$})


    // Handle the Finish button from the followup step -- will close modal, redirect, or refresh
    flyd.lift(
        (ev, params) => {
            if(!parent) return
            if(params.redirect) parent.postMessage(`commitchange:redirect:${params.redirect}`, '*')
            else if(params.mode !== 'embedded') parent.postMessage('commitchange:close', '*')
        }
        , state.clickFinish$, state.params$ )

    return state
}

const setDonationFromParams = (don, params) => {
    if(!params.single_amount || isNaN(format.dollarsToCents(params.single_amount))) delete params.single_amount
    return R.merge({
        amount: params.single_amount ? format.dollarsToCents(params.single_amount) : 0
    }, don)
}


const view = state => {
    return h('div', {
        // class: {'is-modal': state.params$().offsite}
    }, [
        // h('img.closeButton', {
        //     props: {src: '/assets/ui_components/close.svg'}
        //     , on: {click: ev => state.params$().offsite ? parent.postMessage('commitchange:close', '*') : null}
        //     , class: {'u-hide': !state.params$().offsite}
        // })
         h('div.titleRow', [
            h('img', {props: {src: app.pageLoadData.nonprofit.logo.normal.url}})
            , h('div.titleRow-info', [
                h('h2', app.pageLoadData.nonprofit.name )
                , h('p', [
                    state.params$().designation && !state.params$().single_amount
                        ? headerDesignation(state)
                        :  app.pageLoadData.nonprofit.tagline || ''
                ])
            ])
        ])
        , wizardWrapper(state)
    ])
}

const headerDesignation = state => {
    return h('span', [
        h('i.fa.fa-star', {style: {color: app.nonprofit.brand_color || ''}})
        , h('strong', ' Designation: ')
        , String(state.params$().designation)
        , state.params$().designation_desc
            ? h('span', [h('br'), h('small', state.params$().designation_desc)])
            : ''
    ])
}

const wizardWrapper = state => {
    return h('div.wizard-steps.donation-steps', [
        wizard.view(R.merge(state.wizard, {
            steps: [
                {name: 'Amount',   body: amountStep.view(state.amountStep)}
                , {name: 'Confirm Card',     body: paymentStep.view(state.paymentStep)}

            ]
            , followup: followupStep.view(state)
        }))
    ])
}

module.exports = {view, init}