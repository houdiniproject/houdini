// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
flyd.lift = require('flyd/module/lift')
flyd.flatMap = require('flyd/module/flatmap')
const request = require('../../common/request')
const cardForm = require('../../components/card-form.es6')
const sepaForm = require('../../components/sepa-form.es6')
const progressBar = require('../../components/progress-bar')
const DonationAmountCalculator = require('./DonationSubmitter/DonationAmountCalculator').default
const DonationSubmitter = require('./DonationSubmitter').default
const { centsToDollars } = require('../../common/format')
const cloneDeep = require('lodash/cloneDeep')

const sepaTab = 'sepa'
const cardTab = 'credit_card'

function init(state) {
  const params$ = (state && state.params$) || flyd.stream({});

  const payload$ = flyd.map(supp => ({ card: { holder_id: supp.id, holder_type: 'Supporter' } }), state.supporter$)
  const supporterID$ = flyd.map(supp => supp.id, state.supporter$)
  const card$ = flyd.merge(
    flyd.stream({})
    , flyd.map(supp => ({ name: supp.name, address_zip: supp.zip_code }), state.supporter$))

  const coverFees$ = flyd.map(params => (params.manual_cover_fees || params.hide_cover_fees_option) ? false : true, params$)

  const hideCoverFeesOption$ = flyd.map(params => params.hide_cover_fees_option, params$)

  const donationAmountCalculator = new DonationAmountCalculator(app.nonprofit.feeStructure);
  const donationSubmitter = new DonationSubmitter()

  // Give a donation of value x, this returns x + estimated fees (using fee coverage formula) if fee coverage is selected OR
  // x if fee coverage is not selected
  state.donationTotal$ = flyd.stream();

  //Given a donation of value x, this gives the amount of fees that would be added if fee coverage were selected, i.e. so 
  // the nonprofit gets a net of x
  state.potentialFees$ = flyd.stream();

  function updateFromDonationAmountCalculator() {
    state.donationTotal$(donationAmountCalculator.calcResult.donationTotal)
    state.potentialFees$(donationAmountCalculator.calcResult.potentialFees);

  }

  function handleDonationAmountCalcEvent(e) {
    updateFromDonationAmountCalculator();
  }

  state.loading$ = flyd.stream();
  state.error$ = flyd.stream();
  // Control progress bar for card payment
  state.progress$ = flyd.stream({hidden:true});

  function updateProgress() {
    const progress = donationSubmitter.progress;

    if (progress) {
      if (progress === 20) {
        state.progress$({status: I18n.t('nonprofits.donate.payment.loading.checking_card'), percentage: 20})
      }
      else if (progress === 100) {
        state.progress$({status: I18n.t('nonprofits.donate.payment.loading.sending_payment'), percentage: 100})
      }
    }
    else {
      state.progress$({hidden:true})
    }
  }

  function updateFromDonationSubmitter() {
    state.loading$(donationSubmitter.loading);
    state.error$(donationSubmitter.error);
    updateProgress();
  }

  function handleDonationSubmitterChanged(e) {
    updateFromDonationSubmitter();
  }

  function onInit() {
    donationAmountCalculator.inputAmount = state.donation$().amount
    donationAmountCalculator.coverFees = coverFees$();
    updateFromDonationAmountCalculator(donationAmountCalculator);
  }

  state.onInsert = ()  => {
    donationAmountCalculator.addEventListener('updated', handleDonationAmountCalcEvent)
    donationSubmitter.addEventListener('updated', handleDonationSubmitterChanged)
  }

  state.onRemove = () => {
    donationAmountCalculator.removeEventListener('updated', handleDonationAmountCalcEvent)
    donationSubmitter.removeEventListener('updated', handleDonationSubmitterChanged)
  }

  flyd.combine((donation$, coverFees$) => {
    donationAmountCalculator.inputAmount = donation$().amount
    donationAmountCalculator.coverFees = coverFees$();
  }, [state.donation$, coverFees$]);

  


  state.cardForm = cardForm.init({
    path: '/cards', card$, payload$, donationTotal$: state.donationTotal$, coverFees$, potentialFees$: state.potentialFees$,
    hide_cover_fees_option$: hideCoverFeesOption$
  })
  state.sepaForm = sepaForm.init({ supporter: supporterID$ })

  // Set the card ID into the donation object when it is saved
  const cardToken$ = flyd.map((i) => {
    return i['token']
  }, state.cardForm.saved$)
  const donationWithAmount$ = flyd.combine((donation, donationTotal, coverFees$) => {
    const d = cloneDeep(donation())
    d.amount = donationTotal()
    d.fee_covered = coverFees$()
    return d;
  }, [state.donation$, state.donationTotal$, coverFees$])
  const donationWithCardToken$ = flyd.lift(R.assoc('token'), cardToken$, donationWithAmount$)

  // Set the sepa transfer details ID into the donation object when it is saved
  const sepaId$ = flyd.map(R.prop('id'), state.sepaForm.saved$)
  const donationWithSepaId$ = flyd.lift(R.assoc('direct_debit_detail_id'), sepaId$, state.donation$)

  state.donationParams$ = flyd.immediate(
    flyd.combine((sepaParams, cardParams, activeTab) => {
      if (activeTab() == sepaTab) {
        return sepaParams()
      } else if (activeTab() == cardTab) {
        return cardParams()
      }
    }, [donationWithSepaId$, donationWithCardToken$, state.activePaymentTab$])
  )
  const donationResp$ = flyd.flatMap(postDonation, state.donationParams$)

  // Post the gift option, if necessary
  const paramsWithGift$ = flyd.filter(params => params.gift_option_id || params.gift_option && params.gift_option.id, state.params$)
  const paidWithGift$ = flyd.map(
    (result) => {
      const hasParamsWithGift = paramsWithGift$() && (paramsWithGift$().gift_option_id || paramsWithGift$().gift_option.id)
      if (result.error || !hasParamsWithGift) {
        return result
      }
      else {
        return postGiftOption(paramsWithGift$().gift_option_id || paramsWithGift$().gift_option.id, result)
      }
    }
    , donationResp$
  )

  state.paid$ = flyd.filter(resp => !resp.error, paidWithGift$)

  flyd.map((paid) => {
    donationSubmitter.reportCompleted(donationResp$());
  }, state.paid$)

  flyd.map((saved) => {
    donationSubmitter.reportSavedCard();
  }, state.cardForm.saved$);

  flyd.map((submit) => {
    donationSubmitter.reportBeginSubmit();
  }, state.cardForm.form.validSubmit$)

  flyd.map((submit) => {
    donationSubmitter.reportBeginSubmit();
  }, state.sepaForm.form.validSubmit$)

  flyd.map((error) => {
    donationSubmitter.reportError(error);
  }, state.cardForm.error$)

  flyd.map((error) => {
    donationSubmitter.reportError(error);
  }, state.sepaForm.error$)

  // post utm tracking details after donation is saved
  flyd.map(
    R.apply((utmParams, donationResponse) => postTracking(app.utmParams, donationResp$))
    , state.paid$
  )

  flyd.map(
    R.apply((donationResponse) => postSuccess(donationResp$))
    , state.paid$
  )

  onInit();

  return state
}

const postGiftOption = (campaign_gift_option_id, result) => {
  return flyd.map(R.prop('body'), request({
    path: '/campaign_gifts'
    , method: 'post'
    , send: {
      campaign_gift: {
        donation_id: result.json
          ? result.json.donation.id // for recurring
          : result.donation.id // for one-time
        , campaign_gift_option_id
      }
    }
  }).load)
}

const postTracking = (utmParams, donationResponse) => {
  const params = R.merge(utmParams, { donation_id: donationResponse().donation.id })

  if (utmParams.utm_source || utmParams.utm_medium || utmParams.utm_content || utmParams.utm_campaign) {
    return flyd.map(R.prop('body'), request({
      path: `/nonprofits/${app.nonprofit_id}/tracking`
      , method: 'post'
      , send: params
    }).load)
  }
}

const postSuccess = (donationResponse) => {
  try {
    const plausible = window['plausible'];
    if (plausible) {
      const resp = donationResponse()
      plausible('payment_succeeded', {props: {amount: resp && resp.charge && resp.charge.amount && (resp.charge.amount / 100)}});
    }
  }
  catch(e) {
    console.error(e)
  }
}

var posting = false // hack switch to prevent any kind of charge double post
// Post either a recurring or one-time donation
const postDonation = (donation) => {
  if (posting) return flyd.stream()
  else posting = true
  var prefix = `/nonprofits/${app.nonprofit_id}/`
  var postfix = donation.recurring ? 'recurring_donations' : 'donations'

  if (donation.weekly) {
    donation.amount = Math.round(4.3 * donation.amount);
  }
  delete donation.weekly; // needs to be removed to be processed

  if (donation.recurring) donation = { recurring_donation: donation }
  return flyd.map(R.prop('body'), request({
    path: prefix + postfix
    , method: 'post'
    , send: donation
  }).load)
}

const paymentTabs = (state) => {
  if (state.activePaymentTab$() == sepaTab) {
    return payWithSepaTab(state)
  } else if (state.activePaymentTab$() == cardTab) {
    return payWithCardTab(state)
  }
}

const payWithSepaTab = state => {
  return h('div.u-marginBottom--10', [
    sepaForm.view(state.sepaForm)
  ])
}

const payWithCardTab = state => {
  var result = h('div.u-marginBottom--10', [
    cardForm.view(R.merge(state.cardForm, { error$: state.error$, hideButton: state.loading$() }))
    , progressBar(state.progress$())
  ])
  return result
}

function view(state) {
  var isRecurring = state.donation$().recurring
  var dedic = state.dedicationData$()
  var amountLabel = isRecurring ? ` ${I18n.t('nonprofits.donate.payment.monthly_recurring')}` : ` ${I18n.t('nonprofits.donate.payment.one_time')}`
  var weekly = "";
  if (state.donation$().weekly) {
    amountLabel = amountLabel.replace(I18n.t('nonprofits.donate.amount.monthly'), I18n.t('nonprofits.donate.amount.weekly')) + "*";
    weekly = h('div.u-centered.notice', [h("small", I18n.t('nonprofits.donate.amount.weekly_notice', { amount: (format.weeklyToMonthly(state.donationTotal$()) / 100.0), currency: app.currency_symbol }))]);
  }
  return h('div.wizard-step.payment-step', {
    hook: {
      insert: () => state.onInsert(),
      remove: () => state.onRemove(),
    },
  }, [
    h('p.u-fontSize--18 u.marginBottom--0.u-centered.amount', [
      h('span', app.currency_symbol + centsToDollars(state.donationTotal$()))
      , h('strong', amountLabel)
    ])
    , weekly
    , dedic && (dedic.first_name || dedic.last_name)
      ? h('p.u-centered', `${dedic.dedication_type === 'memory' ? I18n.t('nonprofits.donate.dedication.in_memory_label') : I18n.t('nonprofits.donate.dedication.in_honor_label')} ` + `${dedic.first_name || ''} ${dedic.last_name || ''}`)
      : ''
    , paymentTabs(state)
  ])
}

module.exports = { view, init }
