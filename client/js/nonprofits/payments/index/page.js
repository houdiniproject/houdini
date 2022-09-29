// License: LGPL-3.0-or-later
require('../../../components/date_range_picker')
require('../../../common/panels_layout')
require('./tour')
require('../../../common/restful_resource')
require('../../../refunds/create')
require('../../supporters/get_name')
require('./payment_details')
require('../../../components/tables/filtering/apply_filter')('payments')
require('../../../common/ajax/get_campaign_and_event_names_and_ids')(app.nonprofit_id)
require('../../supporters/index/import')
var format = require('../../../common/format')

appl.def('format', require('../../../common/format'))

appl.def('payments.index', function() {
	appl.def('loading', true)
	appl.ajax.index('payments').then(function(resp) {
		appl.def('loading', false)
		if(appl.payments.query.page > 1) {
			var main_panel = document.querySelector('.mainPanel')
			main_panel.scrollTop = main_panel.scrollHeight
		}
	})
})


appl.def('payments.clear_search_if_deleted', function(val) {
	if(val === '') {
		appl.def('payments.query', {search: '', page: 1})
		appl.payments.index()
	}
})


appl.def("payments", {
	query: {page: 1},
	concat_data: true
})

appl.def('filter_count', 0)

if(window.location.search)
	ajax_from_params()
else
	appl.payments.index()


appl.def('payments.toggle_panel', function(id, el){
	var tr = el.parentNode

	if(tr.hasAttribute('data-selected')) {
		appl.close_side_panel()
		tr.removeAttribute('data-selected','')
	} else {
		appl.ajax_payment_details.fetch(id)
		$('.mainPanel').find('tr').removeAttr('data-selected')
		tr.setAttribute('data-selected','')
		var path =  window.location.pathname + "?pid=" + id
		window.history.pushState({},'payment id', path)
	}
})


appl.def('readable_kind', function(kind, el) {
	if(kind === "Donation") return "One-Time Donation"
  else if(kind === "OffsitePayment") return "Offsite Donation"
  else if(kind === "Ticket") return "Ticket Purchase"
  else return format.camelToWords(kind)
})


appl.def('kind_icon_class', function(kind) {
	if(kind === "Donation") return "fa-heart"
	if(kind === "OffsitePayment") return "fa-money"
	if(kind === "RecurringDonation") return "fa-refresh"
	if(kind === "Ticket") return "fa-ticket"
	if(kind === "Refund") return "fa-rotate-left"
	if(kind === "ManualAdjustment") return "fa-plus"
})

appl.def('formatted_gross_amount', function(amt) {
	if(amt < 0) {
		return '(' + appl.cents_to_dollars(Math.abs(amt)) + ')'
	} else {
		return appl.cents_to_dollars(amt)
	}
})

function ajax_from_params() {
	var payment_id = utils.get_param('pid')
	var supporter_id = utils.get_param('sid')
	appl.is_loading()
	if(supporter_id) {
		appl.payments.query = {page: appl.payments.query.page, search: supporter_id}
		appl.payments.index()
	}
	if(payment_id) {
		appl.payments.index()
		appl.ajax_payment_details.fetch(payment_id)
	}
}

