// License: LGPL-3.0-or-later
var format = require('../../../common/format')

module.exports = function(scope) {

	appl.def(scope + '.filter_count', 0)

	var readable_keys = {
		total_raised_greater_than: 'total contributed',
		total_raised_less_than: 'total contributed',
		last_payment_before: 'last payment',
		location: 'location',
		after_date: 'date',
		before_date: 'date',
		sort_date: 'date',
    year: 'year',
		sort_name: 'name',
    campaign_id: 'campaign',
    event_id: 'event',
		sort_towards: 'towards',
    sort_contributed: 'total contributed',
    sort_last_payment: 'last payment',
		sort_type: 'type',
		sort_amount: 'amount',
		amount_less_than: 'amount less than',
		amount_greater_than: 'amount greater than',
		amount: 'amount'
  , has_contributed_during: 'contributed after'
  , has_not_contributed_during: 'not contributed after'
  , donation_type: 'payment type'
  , recurring: 'recurring donors'
  , tags: 'tags'
  , notes: 'notes'
  , custom_fields: 'custom fields'
	, check_number: 'check number'
	, anonymous: 'anonymous'
	}

	appl.def('readable_filter_names', function() {
		var arr = []
		var q = appl[scope].query
		for(var key in q) {
			var name = readable_keys[key]
			if(name && q[key] && q[key].length) arr.push(name)
		}
		return utils.uniq(arr).map(function(s) { return "<span class='filteringBy-key'>" + s + "</span>" }).join(' ')
	})

	appl.def('clear_all_filters', function() {
		for(var key in appl[scope].query) {
			appl.def(scope + '.query.' + key, '')
		}
		appl[scope].index()
		document.querySelector('.filterPanel').reset()
		$('.sortArrows').attr('sort', 'none')
		appl.def(scope + '.filter_count', 0)
	})

	appl.def('apply_input_filter', function(name, val) {
		if(val && !appl[scope].query[name]) {
			appl.incr(scope + '.filter_count')
		} else if(!val && appl[scope].query[name]) {
			appl.decr(scope + '.filter_count')
		}
		appl.def(scope + '.query.' + name, val)
		re_fetch()
	})

	appl.def('apply_sort_filter', function(name) {
		var old_val = appl[scope].query[name]
		if(!old_val || old_val === '') {
			appl.incr(scope + '.filter_count')
			appl.def(scope + '.query.' + name, 'desc')
		} else if(old_val === 'asc') {
			appl.decr(scope + '.filter_count')
			appl.def(scope + '.query.' + name, '')
		} else {
			appl.def(scope + '.query.' + name, 'asc')
		}
		re_fetch()
	})

  appl.def('apply_checkbox_filter', function(el) {
    el = appl.prev_elem(el)
    var prop = scope + ".query." + el.name
    if(el.checked) {
      appl.incr(scope + '.filter_count')
      appl.def(prop, 'true')
    } else {
      appl.decr(scope + '.filter_count')
      appl.def(prop, '')
    }
    re_fetch()
  })

  // Instead of having checkboxes mark a single property as true/false, we want
  // to have many checked checkboxes with the same name attribute get their
  // values aggregated into a single array under the single property name.
  // Eg. for tag filtering, we want the checked checkboxes to construct a
  // single array of tag names.
  appl.def('apply_checkbox_array_aggregator', function(el) {
    el = appl.prev_elem(el)
    var prop = scope + '.query.' + el.name
    var array = appl[scope]['query'][el.name] || []
    if(el.checked) {
      appl.incr(scope + '.filter_count')
      array.push(el.value)
    } else {
      appl.decr(scope + '.filter_count')
      array.splice(array.indexOf(el.value), 1) // Remove the tag name from the array
    }
    appl.def(prop, array)
    re_fetch()
  })

	appl.def('apply_radio_filter', function(el) {
    el = appl.prev_elem(el)
    if(el.checked) {
      var prop = scope + ".query." + el.name
      if(el.value && !appl[prop]) appl.incr(scope + '.filter_count')
      if(!el.value) appl.decr(scope + '.filter_count')
      appl.def(prop, el.value)
      re_fetch()
    }
	})


	function re_fetch() {
		appl.def(scope + '.query.page', 1)
		appl[scope].index()
	}

} // module.exports
