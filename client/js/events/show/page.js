// License: LGPL-3.0-or-later
require('../../common/pikaday-timepicker')
require('../../common/fundraiser_metrics')
require('../../components/fundraising/add_header_image')
require('../../tickets/new')
require('../../ticket_levels/manage')
require('../discounts/index')
require('../../common/on-change-sanitize-slug')
const donateWiz = require('../../nonprofits/donate/wizard')
const snabbdom = require('snabbdom')
const h = require('snabbdom/h')
const flyd = require('flyd')
const R = require('ramda')
const render = require('ff-core/render')
const modal = require('ff-core/modal')

function createClickListener(startWiz$){
    return (...props) => {
        startWiz$(...props)
    }


}

// -- Flim flam root component for event pages
function init() {
  var state = { }
  const startWiz$ = flyd.stream()
  const donateButtons = document.querySelectorAll('.js-openDonationModal')
  R.map(x => x.addEventListener('click', createClickListener(startWiz$)), donateButtons)
  state.modalID$ = flyd.map(R.always('donationModal'), startWiz$)
  state.donateWiz = donateWiz.init(flyd.stream({event_id: app.event_id, hide_cover_fees_option: app.hide_cover_fees_option}))
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
  renderActivities('event', `/nonprofits/${app.nonprofit_id}/events/${app.event_id}/activities`)
}

// -- Legacy viewscript stuff


if (app.nonprofit.brand_color) {
	require('../../components/branded_fundraising')
}

var request = require('../../common/client')
var path = '/nonprofits/' + app.nonprofit_id + '/events/' + app.event_id


if(app.current_event_editor) {
	require('./editor')
	require('./tour')
	var create_info_card = require('../../supporters/info-card.es6')
}


// Event metrics init (total raised, total attendees)
appl.def('metrics.path_prefix', path + '/')
appl.ajax_metrics.index()


appl.ticket_wiz.on_complete = function(tickets) {
	appl.ajax_metrics.index()
}

appl.def('donate_wiz.donation.event_id', appl.event_id)

appl.def('remove_event', function(e) {
	request.del(path).end(function(err, resp) {
		appl.redirect('/nonprofits/' + app.nonprofit_id + '/dashboard')
	})
})
