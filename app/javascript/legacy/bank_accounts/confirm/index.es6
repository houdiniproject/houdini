// License: LGPL-3.0-or-later
const h = require('virtual-dom/h')
const request = require('../../common/super-agent-frp')
const view = require('vvvview')
const flyd = require('flyd')
const flatMap = require('flyd/module/flatmap')
const thunk = require('vdom-thunk')
const format = require('../../common/format')
const Im = require('immutable')
const fromJS = Im.fromJS
const Map = Im.Map

var npURL = '/nonprofits/' + app.nonprofit_id


const root = state => {
	var headerContent = ''
	if(state.get('loading')) {
		headerContent = [h('i.fa.fa-spin.fa-gear'), ' Confirming Bank Account...']
	} else if(!state.get('loading') && !state.get('pending_verification')) {
		headerContent = [h('i.fa.fa-check'), ' Bank Account Confirmed!']
	} else { // not loading and unable to confirm
		headerContent = ['Unable to confirm bank account.']
	}

	var confirmedMsg = !state.get('pending_verification') 
		? h('p', [
			'Your bank account connection has been confirmed with your email address. ',
				h("br"),
				h('a', {href: npURL + '/payouts'}, [h('i.fa.fa-return'), 'Return to your payouts dashboard'])
			])
		: ''

	return h('div', [
		h('h2', headerContent),
		confirmedMsg,
		thunk(accountInfo, state),
		h('hr'),
		h('p', [
			'If any of this looks incorrect, please contact: ',
			h('a', {href: 'mailto:support@commitchange.com'}, 'support@commitchange.com')
		])
	])
}


const accountInfo = state =>
	h('div.well', [
		h('p', ['Nonprofit: ', h('strong', state.getIn(['nonprofit', 'name'])), ]),
		h('p', ['New bank account: ', h('strong', state.get('name')), ]),
		h('p', ['User who made the change: ', h('strong', state.get('email')), ]),
		h('p', ['Date and time of update: ', h('strong', format.date.toSimple(state.get('created_at'))), ]),
	])


var state = fromJS(app.bankAccount).set('loading', true)

var confirmView = view(root, document.querySelector('.js-view-confirm'), state)


if(app.bankAccount.pending_verification) {
	var $confirmResponse = request.post(npURL + '/bank_account/confirm')
		.send({token: utils.get_param('t')})
		.perform()

	var $state = flyd.scan(
		(state, resp) => state.set('loading', false).set('pending_verification', false)
		, state
		, $confirmResponse)

	flyd.map(confirmView, $state)
} else {
	confirmView(state.set('loading', false).set('pending_verification', false))
}

