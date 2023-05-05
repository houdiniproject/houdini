// License: LGPL-3.0-or-later
const request = require("../common/super-agent-frp")
const view = require("vvvview")
const flyd = require('flyd')
const flatMap = require('flyd/module/flatmap')
const scanMerge = require('flyd/module/scanmerge')
const h = require('virtual-dom/h')
const Im = require('immutable')
const fromJS = Im.fromJS
const OrderedMap = Im.OrderedMap
const format = require('../common/format')

var state = fromJS({is_visible: false, data: {}, coords: {top: 0, right: 0, left: 0}})

var $showClicks = flyd.stream()
var $hideClicks = flyd.stream()

const root = state => {
	if(state.get('is_visible') && state.get('data')) {
		return h('aside.infoCard', {
				style: {
					display: state.get('is_visible') ? 'block' : 'none',
					top: state.getIn(['coords', 'top']) - state.get('rows') * 23 + 'px',
					left: state.getIn(['coords', 'left']) + 'px',
					right: state.getIn(['coords', 'right']) + 'px'
				}
			}, [
					h('i.fa.fa-times', {onclick: $hideClicks}),
					supporterTable(state.get('data')),
					h('a.button--micro', {href: state.getIn(['data', 'link'])}, 'View Full Details')
			])
	} else return h('span')
}

const supporterDetail = pair => {
	var [key, val] = pair
  if(key === 'link') return ''
	return val ? h('tr', [h('td', format.snake_to_words(key)), h('td', val)]) : ''
}

const supporterTable = supporter =>
	h('table', supporter.entrySeq().map(supporterDetail).toJS())

const displayCard = (state, node) => {
	var clientTop = document.documentElement.clientTop
	var clientLeft = document.documentElement.clientLeft
	var box = node.getBoundingClientRect()
	var top = box.top + window.pageYOffset - clientTop
	var left = box.left + window.pageXOffset - clientLeft

	// Place card 15px from right when it's too far over.
	if(left + 350 >= document.body.offsetWidth) {
		state = state.setIn(['coords', 'right'], 15)
		state = state.setIn(['coords', 'left'], 'initial')
	} else {
		state = state.setIn(['coords', 'left'], left)
		state = state.setIn(['coords', 'right'], 'initial')
	}

	return state
		.setIn(['coords', 'top'], top)
		.set('is_visible', true)
		.set('data', false)
}

// Count the number of rows of data the supporter has
const calculateRows = state => 
	state.set('rows', state.get('data').entrySeq().filter(pair => {
		var [key, val] = pair
		return val && String(val).length
	}).count() + 1.5)

const ajaxSupporter = node => {
  var id = node.getAttribute('data-id')
	return request.get(`/nonprofits/${app.nonprofit_id}/supporters/${id}/info_card`).perform()
}

var $responses = flatMap(ajaxSupporter, $showClicks)

const setSupporterData = (state, response) => {
  var d = response.body
	if(!d) return state
	state = state.set('data', OrderedMap({
    name: d.name
  , email: d.email
  , phone: utils.pretty_phone(d.phone)
  , address: utils.address_with_commas(d.address, d.city, d.state_code, d.zip_code,d.country)
  , organization: d.organization
  , total_raised: '$' + utils.cents_to_dollars(d.raised)
  , link: `/nonprofits/${app.nonprofit_id}/supporters?sid=${d.id}/`
	}))
	// Count the rows of present data to calculate the card height
	state = calculateRows(state)
	return state
}

var $state = flyd.immediate(scanMerge([
	[$hideClicks, state => state.set('is_visible', false)],
	[$showClicks, displayCard],
	[$responses, setSupporterData],
], state))

var infoCard = view(root, document.body, state)

flyd.map(infoCard, $state)


// XXX viewscript lol
appl.def('show_supporter_info_card', function(node){ $showClicks(appl.prev_elem(node)) })

