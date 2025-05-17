// License: LGPL-3.0-or-later
const flyd = require('flyd')
const h = require('snabbdom/h')
const donateWiz = require('../../nonprofits/donate/wizard')
const render = require('ff-core/render')
const snabbdom = require('snabbdom')
const modal = require('ff-core/modal')
flyd.mergeAll = require('flyd/module/mergeall')
flyd.scanMerge = require('flyd/module/scanmerge')
const format = require('../../common/format')
const giftOptions = require('./gift-option-list')
const chooseGiftOptionsModal = require('./choose-gift-options-modal')
const metricsAndContributeBox = require('./metrics-and-contribute-box')
const timeRemaining = require('../../common/time-remaining')
const request = require('../../common/request')

const activities = require('../../components/public-activities')

const { parseDonateParams } = require('../../nonprofits/donate/wizard/utils');

// Viewscript legacy side effect stuff
require('../../components/branded_fundraising')
require('../../common/on-change-sanitize-slug')
require('../../common/fundraiser_metrics')
require('../../components/fundraising/add_header_image')
require('../../common/restful_resource')
require('../../gift_options/index')
appl.ajax_gift_options.index()



// Campaign editor only functionality
if(app.current_campaign_editor) {
	require('./admin')
	appl.def('current_campaign_editor', true)
	require('../../gift_options/admin')
	var create_info_card = require('../../supporters/info-card.es6')
}

// Initialize the state for the top-level campaign component
// This includes the metrics, contribute button, gift options listing, and the donate wizard (most of right sidebar)
// Later can include the other viewscript pieces
function init() {
  var state = { 
    timeRemaining$: timeRemaining(app.end_date_time, app.timezone),
  }

  state.giftOptions = giftOptions.init(flyd.stream(), state)

  const metricsResp$ = flyd.map(r => r.body, request({
    method: 'get'
  , path: `/nonprofits/${app.nonprofit_id}/campaigns/${app.campaign.id}/metrics`
  }).load)
  state.loadingMetrics$ = flyd.mergeAll([
    flyd.map(_ => false, metricsResp$)
  , flyd.stream(true)
  ])
  state.metrics$ = flyd.merge(
    flyd.stream({goal_amount: 0, total_raised: 0, supporters_count: 0})
  , metricsResp$
  )
  state.metrics = metricsAndContributeBox.init(state)

  state.activities = activities.init('campaign', `/nonprofits/${app.nonprofit_id}/campaigns/${app.campaign_id}/activities`)

 
  const contributeModalType$ = flyd.map(
    () => (state.timeRemaining$() && state.giftOptions.giftOptions$().length ? 'gifts' : 'regular'),
    state.metrics.clickContribute$
  );

  const clickContributeGifts$ = flyd.filter(x => x === 'gifts', contributeModalType$)
  
  const clickContributeRegular$ = flyd.filter(x => x === 'regular', contributeModalType$)

  state.clickRegularContribution$ = flyd.stream()

  const startWiz$ = flyd.mergeAll([
      state.giftOptions.clickOption$
    , clickContributeRegular$
    , state.clickRegularContribution$
  ])

  state.selectedModalGift$ = flyd.stream({})

  state.modalID$ = flyd.merge(
    flyd.map(() => 'chooseGiftOptionsModal', clickContributeGifts$),
    flyd.map(() => 'donationModal', startWiz$)
  );
  const params = parseDonateParams(document.location, app);
  params.campaign_id = app.campaign.id



  // Stream of which gift option you have selected
  const giftOption$ = flyd.map(setGiftParams, state.giftOptions.clickOption$)
  const donateParam$ = flyd.scanMerge([
    [state.metrics.clickContribute$, resetDonateForm]
  , [giftOption$, setGiftOption]
  ], params )

  state.donateWiz = donateWiz.init(donateParam$)

  return state
}

const resetDonateForm = (params, _) => ({
  ...params,
  single_amount: undefined,
  gift_option: undefined,
  type: undefined,
});

const setGiftOption = (params, gift) => ({
  ...params,
  single_amount: gift.amount / 100,
  gift_option: gift,
  type: gift.type,
});


// Set the donate wizard parameters using data from a gift option
const setGiftParams = (triple) => {
  var [gift, amount, type] = triple
  return { amount: amount, type: type , id: gift.id, name: gift.name, to_ship: gift.to_ship}
}

function view(state) {
  return h('div', [ 
    metricsAndContributeBox.view(state.metrics)
  , giftOptions.view(state.giftOptions) 
  , activities.view(state.activities)
  , h('div.donationModal', [
      modal({
        thisID: 'donationModal'
      , id$: state.modalID$
      , body: donateWiz.view(state.donateWiz)
      // , notCloseable: state.donateWiz.paymentStep.cardForm.loading$()
      })
    , modal({
        thisID: 'chooseGiftOptionsModal'
      , title: 'Contribute'
      , id$: state.modalID$
      , body: chooseGiftOptionsModal(state) 
      })
    ])
  ])
}

// -- Render to the page

const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])

render({state: init(), view, patch, container: document.querySelector('.ff-sidebar')})

