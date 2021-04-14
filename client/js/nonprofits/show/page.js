// License: LGPL-3.0-or-later
if (app.nonprofit.brand_color) {
	require('../../components/branded_fundraising')
}

require('../../common/image_uploader')
require('../../components/fundraising/add_header_image')

if(app.current_user) {
	require('../../campaigns/new/wizard')
	require('../../events/new/wizard')
}

if(app.current_nonprofit_user) {
	var editable = require('../../common/editable')
	editable($('.editable'), {
    placeholder: "Enter your nonprofit's story and impact here. We strongly recommend that this section is filled out with at least 250 words. It will automatically save as you type.", 
    sticky: $('.editable').length > 0
  })
	require('./tour')
	var create_info_card = require('../../supporters/info-card.es6')

	appl.def('todos_action', '/profile_todos')
	var todos = require('../../components/todos')
	todos(function(data) {
		appl.def('todos.items', [
			{text: "Add logo", done: data['has_logo'], modal_id: 'settingsModal' },
			{text: "Add header image", done: data['has_background'], modal_id: 'uploadBackgroundImage' },
			{text: "Add summary", done: data['has_summary'], modal_id: 'settingsModal' },
			{text: "Add images", done: data['has_image'], modal_id: 'uploadCarouselImages' },
			{text: "Add highlights", done: data['has_highlight'], modal_id: 'settingsModal' },
			{text: "Add services and impact", done: data['has_services'], link: '#js-servicesAndImpact' }
		])
	})
}

// -- Flimflam

const snabbdom = require('snabbdom')
const h = require('snabbdom/h')
const flyd = require('flyd')
const R = require('ramda')
const donateWiz = require('../../nonprofits/donate/wizard')
const modal = require('ff-core/modal')
const render = require('ff-core/render')
const branding = require('../../components/nonprofit-branding')

function init() {
  var state = {}
  state.donateWiz = donateWiz.init(flyd.stream({hide_cover_fees_option: app.hide_cover_fees_option}))
  state.modalID$ = flyd.stream()
  return state
}

function view(state) {
  return h('section.box-r', [
    h('aside', [
      h('a.button--jumbo u-width--full', {
        style: {background: branding.dark}
      , on: {click: [state.modalID$, 'donationModal']}
      }, [
        `Donate to ${app.nonprofit.name}`
      ])
    , h('div.donationModal', [
        modal({
          thisID: 'donationModal'
        , id$: state.modalID$
        , body: donateWiz.view(state.donateWiz)
        // , notCloseable: state.donateWiz.paymentStep.cardForm.loading$()
        })
      ])
    ])
  ])
}


// -- Render

const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
var container = document.querySelector('.ff-container')
var state = init()
render({container, view, patch, state})

