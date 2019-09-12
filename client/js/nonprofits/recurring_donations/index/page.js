// License: LGPL-3.0-or-later
require('./index.es6')
require('./create')
require('./update')
require('./delete')
require('../../../common/restful_resource')
require('../../../common/vendor/bootstrap-tour-standalone')
require('../../../common/panels_layout')
var format = require('../../../common/format')
appl.def('is_usa', format.geography.isUS)
require('./tour')

const {CommitchangeStripeFeeStructure} = require('../../../../../javascripts/src/lib/payments/commitchange_stripe_fee_structure')

const {Money} = require('../../../../../javascripts/src/lib/money')

const calc = require('../../../nonprofits/donate/calculate-total')

appl.def('readable_interval', require('../readable_interval'))

appl.def('recurring_donations', {
	query: {page: 1},
	concat_data: true
})

appl.def('recurring_donations.index', function() {
		appl.def('loading', true)
		return appl.ajax.index('recurring_donations').then(function(resp) {
			appl.def('loading', false)
			if(appl.recurring_donations.query.page > 1) {
				var main_panel = document.querySelector('.mainPanel')
				main_panel.scrollTop = main_panel.scrollHeight
			}
			return resp
		})
})

appl.recurring_donations.index()

const wiz = {}

wiz.apply_amount_change = function() {
	//handle change
	const amount = appl.recurring_donation_details.amount || 0
	
	const feeCovering = appl.recurring_donation_details.fee_covered
	if (!app.nonprofit.feeStructure) {
		throw new Error("billing Plan isn't found!")
	}
	
	if (amount === 0){
		appl.def('recurring_donation_details.total', 0)
		appl.def('recurring_donation_details.fee_amount', 0)
	} else {
		const feeStructure = new CommitchangeStripeFeeStructure(app.nonprofit.feeStructure)

	
		appl.def('recurring_donation_details.total', calc.calculateTotal({feeCovering, amount}, feeStructure))
		appl.def('recurring_donation_details.fee_amount', feeStructure.calcFromNet(Money.fromCents(amount, 'usd')).fee.amountInCents)
	}

	if (appl.recurring_donation_details.total === 0){
		appl.def('recurring_donation_details.written_fee_amount', null)	
	}
	else {
		appl.def('recurring_donation_details.written_fee_amount', format.centsToDollars(appl.recurring_donation_details.fee_amount))
	}
}

wiz.fee_covered__apply = function(node) {
	const item = appl.prev_elem(node).checked
	appl.recurring_donation_details.fee_covered = item || false
	wiz.apply_amount_change()
}

wiz.amount_changed__apply = function(node) {
	const value = appl.prev_elem(node).value
	if (parseFloat(value) !== NaN) {
		appl.recurring_donation_details.amount = (parseFloat(value) || 0) * 100
		wiz.apply_amount_change()
	}
	
}

appl.def('recurring_donation_details', {
	resource_name: 'recurring_donations',

	apply_amount_change: wiz.apply_amount_change,
	fee_covered__apply: wiz.fee_covered__apply,
	amount_changed__apply: wiz.amount_changed__apply
})


appl.def('ajax_details', {
	fetch: function(id, node) {
		appl.def('loading', true)
		appl.ajax.fetch('recurring_donation_details', id).then(function(resp) {
			createRecurringDonationEdit()
			wiz.apply_amount_change()
			appl.open_side_panel(node)
			appl.def('loading', false)
		})
	},
	
})



function createRecurringDonationEdit() {
	const fee_covered = !!appl.recurring_donation_details.data.fee_covered
	appl.def('recurring_donation_details.fee_covered', fee_covered)
	if (fee_covered) {
		if (!app.nonprofit.feeStructure) {
			throw new Error("billing Plan isn't found!")
		}

		const feeStructure = new CommitchangeStripeFeeStructure(app.nonprofit.feeStructure)
		const result = feeStructure.calc(Money.fromCents(appl.recurring_donation_details.data.donation.amount, 'usd'))
		appl.def('recurring_donation_details.amount', result.net.amountInCents)
		appl.def('recurring_donation_details.total', appl.recurring_donation_details.data.donation.amount)
	}
	else {

		appl.def('recurring_donation_details.amount', appl.recurring_donation_details.data.donation.amount)
	
		appl.def('recurring_donation_details.total', appl.recurring_donation_details.data.donation.amount)
	}
	
}




