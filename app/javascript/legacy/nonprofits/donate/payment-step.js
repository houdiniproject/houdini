// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
flyd.lift = require('flyd/module/lift')
flyd.flatMap = require('flyd/module/flatmap')
const request = require('../../common/request')
const cardForm = require('../../components/card-form.es6')
const sepaForm = require('../../components/sepa-form.es6')
const format = require('../../common/format')
const progressBar = require('../../components/progress-bar')

const sepaTab = 'sepa'
const cardTab = 'credit_card'

function init(state) {
  const payload$ = flyd.map(supp => {
    
    return {card: {holder_id: supp.id, holder_type: 'Supporter'}};
    
}, state.supporter$)
  const supporterID$ = flyd.map(supp => supp.id, state.supporter$)
  const card$ = flyd.merge(
    flyd.stream({})
  , flyd.map(supp => ({name: supp.name, address_zip: supp.zip_code}), state.supporter$)) 

  state.cardForm = cardForm.init({ path: '/cards', card$, payload$ }) 
  state.sepaForm = sepaForm.init({ supporter: supporterID$ } )

  // Set the card ID into the donation object when it is saved
  const cardToken$ = flyd.map(R.prop('token'), state.cardForm.saved$)
  const donationWithCardToken$ = flyd.lift(R.assoc('token'), cardToken$, state.donation$)

  // Set the sepa transfer details ID into the donation object when it is saved
  const sepaId$ = flyd.map(R.prop('id'), state.sepaForm.saved$)
  const donationWithSepaId$ = flyd.lift(R.assoc('direct_debit_detail_id'), sepaId$, state.donation$)

  state.donationParams$ = flyd.immediate(
    flyd.combine((sepaParams, cardParams, activeTab) => {
      if(activeTab() == sepaTab) {
        return sepaParams()
      } else if(activeTab() == cardTab) {
        return cardParams()
      }
    }, [donationWithSepaId$, donationWithCardToken$, state.activePaymentTab$])
  )
  const donationResp$ = flyd.flatMap(postDonation, state.donationParams$)

  state.error$ = flyd.mergeAll([
    flyd.map(R.prop('error'), flyd.filter(resp => resp.error, donationResp$))
  , flyd.map(R.always(undefined), state.cardForm.form.submit$)
  , flyd.map(R.always(undefined), state.sepaForm.form.submit$)
  , state.cardForm.error$
  , state.sepaForm.error$
  ])
  state.paid$ = flyd.filter(resp => !resp.error, donationResp$)

  // Control progress bar for card payment
  state.progress$ = flyd.scanMerge([
    [state.cardForm.form.validSubmit$, R.always({status: I18n.t('nonprofits.donate.payment.loading.checking_card'), percentage: 20})]
  , [state.cardForm.saved$,        R.always({status: I18n.t('nonprofits.donate.payment.loading.sending_payment'), percentage: 100})]
  , [state.cardForm.error$, R.always({hidden: true})] // Hide when an error shows up
  , [flyd.filter(R.identity, state.error$), R.always({hidden: true})] // Hide when an error shows up
  ], {hidden: true})

  state.loading$ = flyd.mergeAll([
    flyd.map(R.always(true), state.cardForm.form.validSubmit$)
  , flyd.map(R.always(true), state.sepaForm.form.validSubmit$)
  , flyd.map(R.always(false), state.paid$) 
  , flyd.map(R.always(false), state.cardForm.error$) 
  , flyd.map(R.always(false), state.sepaForm.error$)
  , flyd.map(R.always(false), state.error$)
  ])

  // Post the gift option, if necessary
  const paramsWithGift$ = flyd.filter(params => params.gift_option_id || params.gift_option && params.gift_option.id, state.params$)
  const paidWithGift$ = flyd.lift(R.pair, paramsWithGift$, state.paid$)
  flyd.map(
    R.apply((params, result) => postGiftOption(params.gift_option_id || params.gift_option.id, result))
  , paidWithGift$
  )

  // post utm tracking details after donation is saved
  flyd.map(
    R.apply((utmParams, donationResponse) => postTracking(app.utmParams, donationResp$))
  , state.paid$
  )

  return state
}

const postGiftOption = (campaign_gift_option_id, result) => {
  return flyd.map(R.prop('body'), request({
      path: '/campaign_gifts'
    , method: 'post'
    , send: {campaign_gift: {donation_id: result.json 
        ? result.json.donation.id // for recurring
        : result.donation.id // for one-time
        , campaign_gift_option_id}}
    }).load)
}

const postTracking = (utmParams, donationResponse) => {
  const params = R.merge(utmParams, {donation_id: donationResponse().donation.id})

  if(utmParams.utm_source || utmParams.utm_medium || utmParams.utm_content || utmParams.utm_campaign) {
    return flyd.map(R.prop('body'), request({
      path: `/nonprofits/${app.nonprofit_id}/tracking`
    , method: 'post'
    , send: params
    }).load)
  }
}

var posting = false // hack switch to prevent any kind of charge double post
// Post either a recurring or one-time donation
const postDonation = (donation) => {
  if(posting) return flyd.stream()
  else posting = true
  var prefix = `/nonprofits/${app.nonprofit_id}/`
  var postfix = donation.recurring ? 'recurring_donations' : 'donations'

  if(donation.weekly) { 
    donation.amount = Math.round(4.3 * donation.amount);
  }
  delete donation.weekly; // needs to be removed to be processed

  if(donation.recurring) donation = {recurring_donation: donation}
  return flyd.map(R.prop('body'), request({
    path: prefix + postfix
  , method: 'post'
  , send: donation
  }).load)
}

const paymentTabs = (state) => {
  if(state.activePaymentTab$() == sepaTab) {
    return payWithSepaTab(state)
  } else if(state.activePaymentTab$() == cardTab) {
    return payWithCardTab(state)
  }
}

const payWithSepaTab = state => {
  return h('div.u-marginBottom--10', [
    sepaForm.view(state.sepaForm)
  ])
}

const payWithCardTab = state => {
  return h('div.u-marginBottom--10', [
    cardForm.view(R.merge(state.cardForm, {error$: state.error$, hideButton: state.loading$()}))
  , progressBar(state.progress$())
  ])
}

function view(state) {
  var isRecurring = state.donation$().recurring
  var dedic = state.dedicationData$()
  var amountLabel = isRecurring ? ` ${I18n.t('nonprofits.donate.payment.monthly_recurring')}` : ` ${I18n.t('nonprofits.donate.payment.one_time')}`
  var weekly="";
  if (state.donation$().weekly) {
    amountLabel =   amountLabel.replace(I18n.t('nonprofits.donate.amount.monthly'),I18n.t('nonprofits.donate.amount.weekly')) + "*";
    weekly= h('div.u-centered.notice',[h("small",I18n.t('nonprofits.donate.amount.weekly_notice',{amount:(format.weeklyToMonthly(state.donation$().amount)/100.0),currency:app.currency_symbol}))]);
  }
  return h('div.wizard-step.payment-step', [
    h('p.u-fontSize--18 u.marginBottom--0.u-centered.amount', [
      h('span', app.currency_symbol + format.centsToDollars(state.donation$().amount))
    , h('strong', amountLabel)
    ])
  , weekly
  , dedic && (dedic.first_name || dedic.last_name)
      ? h('p.u-centered', `${dedic.dedication_type === 'memory' ? I18n.t('nonprofits.donate.dedication.in_memory_label') : I18n.t('nonprofits.donate.dedication.in_honor_label')} ` + `${dedic.first_name || ''} ${dedic.last_name || ''}`)
      : ''
  , paymentTabs(state)
  ])
}

module.exports = {view, init}
