// License: LGPL-3.0-or-later
require('../../common/pikaday-timepicker')
require('../../common/fundraiser_metrics')
require('../../components/fundraising/add_header_image').default
require('../../tickets/new')
require('../../ticket_levels/manage')
require('../discounts/index')
require('../../common/on-change-sanitize-slug').default
const donateWiz = require('../../nonprofits/donate/wizard')
const snabbdom = require('snabbdom')
const h = require('snabbdom/h')
const flyd = require('flyd')
const R = require('ramda')
const render = require('ff-core/render')
const modal = require('ff-core/modal')

const {
  activitiesNonprofitEventPath,
  nonprofitEventPath,
  dashboardNonprofitPath,
} = require('../../../routes')

function createClickListener(startWiz$){
    return (...props) => {
        startWiz$(...props)
    }


}

// -- Flim flam root component for event pages
function init() {
  const state = { }
  const startWiz$ = flyd.stream()
  const donateButtons = document.querySelectorAll('.js-openDonationModal')
  R.map(x => x.addEventListener('click', createClickListener(startWiz$)), donateButtons)
  state.modalID$ = flyd.map(R.always('donationModal'), startWiz$)
  state.donateWiz = donateWiz.init(flyd.stream({event_id: app.event_id}))
  return state
}

function view(state) {
  return h('div', [
    h('div.donationModal', [
      modal({
        thisID: 'donationModal'
      , id$: state.modalID$
      , body: donateWiz.view(state.donateWiz)
      })
    ])
  ])
}

// -- Render to page
const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
render({state: init(), view, patch, container: document.querySelector('#js-main')})

const renderActivities = require('../../components/render-activities')

if(!app.hide_activities) {
  renderActivities('event', activitiesNonprofitEventPath(app.nonprofit_id, app.event_id))
}

// -- Legacy viewscript stuff


if (app.nonprofit.brand_color) {
	require('../../components/branded_fundraising').default
}

const request = require('../../common/client').default
const path =   nonprofitEventPath( app.nonprofit_id, app.event_id )


if(app.current_event_editor) {
	require('./editor')
	require('./tour')
	require('../../supporters/info-card.js')
}


// Event metrics init (total raised, total attendees)
appl.def('metrics.path_prefix', path + '/')
appl.ajax_metrics.index()


appl.ticket_wiz.on_complete = function(tickets) {
	appl.ajax_metrics.index()
}

appl.def('donate_wiz.donation.event_id', app.event_id)

appl.def('remove_event', function(e) {
	request.del(path).end(function(err, resp) {
		appl.redirect(dashboardNonprofitPath(app.nonprofit_id))
	})
})
