// License: LGPL-3.0-or-later
const flyd = require('flyd')
const R = require('ramda')
const h = require('snabbdom/h')
const wizard = require('ff-core/wizard')
const scanMerge = require('flyd/module/scanmerge')
flyd.mergeAll = require('flyd/module/mergeall')
flyd.flatMap = require('flyd/module/flatmap')
flyd.zip = require('flyd-zip')

const getParams = require('./get-params')

const paymentStep = require('./payment-step')
const amountStep = require('./amount-step')
const infoStep = require('./info-step')
const followupStep = require('./followup-step')

const {handleWizardFinished} = require('./wizard/utils');

const request = require('../../common/request')
const format = require('../../common/format')

const brandedWizard = require('../../components/styles/branded-wizard')
const renderStyles = require('../../components/styles/render-styles')

const closeButton = require('../../../../app/assets/images/ui_components/close.svg')

renderStyles()(brandedWizard(null))

// pass in a stream of configuration parameters
const init = params$ => {
  var state = {
    error$: flyd.stream()
  , loading$: flyd.stream()
  , clickLogout$: flyd.stream()
  , clickFinish$: flyd.stream()
  , params$: flyd.map(getParams, params$)
  }

  app.iframeParams = app.iframeParams || ""
  app.utmParams = app.utmParams || {}
  // maps utmParams from URL params string into object:
  // { $utm_param: … } if params from iframe are present
   app.iframeParams = app.iframeParams.split("?")[2] ? Object.assign(...app.iframeParams.split("?")[2].split("&").map((param) => param.split("=")).map(
       array => ({[array[0]]: array[1]}))
   ) : {}


  app.utmParams = {
    utm_campaign: app.utmParams.utm_campaign || app.iframeParams.utm_campaign,
    utm_content: app.utmParams.utm_content || app.iframeParams.utm_content,
    utm_medium: app.utmParams.utm_medium || app.iframeParams.utm_medium,
    utm_source: app.utmParams.utm_source || app.iframeParams.utm_source
  }

  app.campaign = app.campaign || {} // so we don't have to hot switch all the calls to app.campaign.name, etc
  var donationDefaults = setDonationFromParams({
    nonprofit_id: app.nonprofit_id
  , campaign_id: app.campaign.id
  , event_id: app.event_id
  }, state.params$())

  state.hide_cover_fees_option = state.params$().hide_cover_fees_option

  state.hide_anonymous = state.params$().hide_anonymous || app.nonprofit.no_anon

  state.selectedPayment$ = flyd.stream('sepa')

  state.amountStep = amountStep.init(donationDefaults, state.params$)
  
  state.donationAmount$ = flyd.map((donation) => { return donation.amount}, state.amountStep.donation$)
  state.infoStep = infoStep.init(state.amountStep.donation$, state)

  state.donation$ = scanMerge([
    [state.amountStep.donation$, R.merge]
  , [state.infoStep.savedSupp$, (d, supp) => R.assoc('supporter_id', supp.id, d)]
  , [state.params$, setDonationFromParams]
  , [state.infoStep.savedDedicatee$, setDonationDedication]
  ], donationDefaults )

  state.paymentStep = paymentStep.init({
    supporter$: state.infoStep.savedSupp$
  , donation$: state.donation$
  , dedicationData$: state.infoStep.dedicationData$
  , activePaymentTab$: state.selectedPayment$
  , params$: state.params$
  })

  const currentStep$ = flyd.mergeAll([
    state.amountStep.currentStep$
  , state.infoStep.currentStep$
  , flyd.map(R.always(0), state.params$) // if the params ever change, jump back to step one
  , flyd.stream(0)
  ])
  state.wizard = wizard.init({currentStep$, isCompleted$: state.paymentStep.paid$})

  // Save dedication as a supporter note once the donation is saved
  // Requires the donor supporter, the dedicatee supporter, the dedication form data, and the paid donation
  const dedicationParams$ = flyd.zip([state.infoStep.savedDedicatee$, state.infoStep.savedSupp$, state.paymentStep.paid$])
  const savedDedication$ = flyd.flatMap(R.apply(postDedication), dedicationParams$)

  flyd.lift(
    (_completedEv, params) => {
      if (params['skipFinish']) {
        handleWizardFinished(params, window);
      }
    }
  , state.wizard.isCompleted$, state.params$ )

  // Log people out
  flyd.map(ev => {request({method: 'get', path: '/users/sign_out'}); window.location.reload()}, state.clickLogout$)

  // Handle the Finish button from the followup step -- will close modal, redirect, or refresh
  flyd.lift(
    (ev, params) => {
      handleWizardFinished({...params, window});
    }
  , state.clickFinish$, state.params$ )

  return state
}

const setDonationFromParams = (don, params) => {
  if(!params.single_amount || isNaN(format.dollarsToCents(params.single_amount))) delete params.single_amount
  return R.merge({
    amount: params.single_amount ? format.dollarsToCents(params.single_amount) : 0
  , recurring: params.type === 'recurring'
  , gift_option_id: params.gift_option_id
  , designation: params.designation
  }, don)
}

// Set the text field to save to the server as serialized JSON
const setDonationDedication = (don, dedication) => {
  return R.assoc(
    'dedication'
  , JSON.stringify({
      supporter_id: dedication.supporter.id
    , name: dedication.supporter.name
    , contact: {email: dedication.supporter.email,
        phone: dedication.supporter.phone,
        address: dedication.supporter.address}
    , note: dedication.note
    , type: dedication.type
    })
  , don)
}


// Save a dedication to the server by saving a note to the supporter
const postDedication = (dedication, donor, donation) => {
  const pathPrefix = `/nonprofits/${ENV.nonprofitID}`
  // TODO: translate content
  var content = `[${donor.name}](${pathPrefix}/supporters?sid=${donor.id}) made a [donation of $${format.centsToDollars(donation.donation.amount)}](${pathPrefix}/payments?pid=${donation.payment.id}) in ${dedication.type || 'honor'} of this person.`
  if(dedication.note) content += ` ${I18n.t('nonprofits.donate.dedication.donor_note')} "${dedication.note}".`
  return flyd.map(r => r.body, request({
    method: 'post'
  , path: `/nonprofits/${app.nonprofit_id}/supporters/${dedication.supporter.id}/supporter_notes`
  , send: {supporter_note: {supporter_id: dedication.supporter.id, user_id: ENV.support_user_id, content}}
  }).load)
}

const titleInfo = state => {
  if (state.params$().title_image_url) {
    return [
      h('img', {
        props: {
          src: state.params$().title_image_url
        , alt: state.params$().title_image_alt || app.campaign.tagline || app.nonprofit.tagline || ''
        },
      }),
    ];
  }

  return [
    h('h2', app.campaign.name || app.nonprofit.name)
  , h('p', [
      state.params$().designation && !state.params$().single_amount
        ? headerDesignation(state)
        : app.campaign.tagline || app.nonprofit.tagline || '',
    ]),
  ];
}

const view = state => {
  return h('div.js-donateForm', {
    class: {'is-modal': state.params$().offsite}
  }, [
    h('img.closeButton', {
      props: {src: closeButton}
      , on: {click: ev => state.params$().offsite && !state.params$().embedded ? parent.postMessage('commitchange:close', '*') : null}
      , class: {'u-hide': (state.params$().embedded || state.params$().mode === 'embedded') || !state.params$().offsite }
    })
  , h('div.titleRow', [
      h('img.logo', {props: {src: app.nonprofit.logo.normal.url}})
    , h('div.titleRow-info', titleInfo(state))
    ])
  , wizardWrapper(state)
  ])
}

const headerDesignation = state => {
  return h('span', [
    h('i.fa.fa-star', {style: {color: app.nonprofit.brand_color || ''}})
  , h('strong', ` ${I18n.t('nonprofits.donate.amount.designation.label')} `)
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
        {name: I18n.t('nonprofits.donate.amount.label'),   body: amountStep.view(state.amountStep)}
      , {name: I18n.t('nonprofits.donate.info.label'),     body: infoStep.view(state.infoStep)}
      , {name: I18n.t('nonprofits.donate.payment.label'),  body: paymentStep.view(state.paymentStep)}
      ]
    , followup: followupStep.view(state)
    }))
  ])
}

module.exports = {view, init}
