// License: LGPL-3.0-or-later
var Pikaday = require('pikaday')
var moment = require('moment')

var el = document.querySelector('#dateRange')
if(el) {
	var before_date = el.querySelector('#beforeDate')
	var after_date = el.querySelector('#afterDate')
}

function format_date(el) {
	return function(date) {
		el.value = moment(date).format('MM/DD/YYYY')
	}
}

if(el && before_date) {
	new Pikaday({
		field: before_date,
		format: 'MM/DD/YYYY',
		onSelect: format_date(before_date)
	})
}

if(el && after_date) {
	new Pikaday({
		field: after_date,
		format: 'MM/DD/YYYY',
		onSelect: format_date(after_date)
	})
}

