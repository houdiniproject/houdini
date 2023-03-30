// License: LGPL-3.0-or-later
var confirmation = require('./confirmation')
var notification = require('./notification')
var moment = require('moment-timezone')
var appl = require('view-script')

module.exports = appl

// A couple short convenience functions for disabling/enabling the global
// loading state
appl.is_loading = function() {appl.def('loading', true)}
appl.not_loading = function() {appl.def('loading', false)}
appl.not_loading()

// Define the current payment plan tier for a signed-in nonprofit
appl.def('current_plan_tier', app.current_plan_tier)

appl.def("is_at_least_plan", function(tier) {
   return app.current_plan_tier >= tier
})

appl.def("is_dispute_transaction", function (kind) {
	return kind === 'Dispute' || kind === 'DisputeReversed'
})

appl.def("is_not_dispute_transaction", function (kind) {
	return kind !== 'Dispute' && kind !== 'DisputeReversed'
})

appl.def('is_manual_adjustment', function(kind) {
	return kind === 'ManualAdjustment'
})

appl.def("hide_refund_donation_button", function(kind, refund_total, gross_amount) {
	return kind === undefined || refund_total >= gross_amount ||
	kind === 'OffsitePayment' || 
	kind === 'Refund' ||
	kind === 'Dispute' ||
	kind === 'DisputeReversed'
})

appl.def("show_receipting", function(kind) {
	return kind !== undefined &&
	kind !== 'OffsitePayment' &&
	kind !== 'Dispute' &&
	kind !== 'DisputeReversed'
})

// Open a modal given by its modal id (uses the modal div's 'id' attribute)
appl.def('open_modal', function(modalId) {
	$('.modal').removeClass('inView')

    //$('body').scrollTop(0)
	$('#' + modalId).addClass('inView')

	$('body').addClass('is-showingModal')

	return appl
})

// Close any and all open modals
appl.def('close_modal', function() {
	$('.modal').removeClass('inView')
	$('body').removeClass('is-showingModal')

	return appl
})

// Open a given modal id only when the User's Account is confirmed via email
// If the user's account is not confirmed, then show an informational modal
// about confirming their account
appl.def('open_modal_if_confirmed', function(modalId){
	if (app.user && app.user.confirmed)
		appl.open_modal(modalId)
	else if (app.user && !app.user.confirmed)
		appl.open_modal('emailConfirmationModal')
	else
		appl.open_modal('signUpModal')
	return appl
})


// Open a confirmation modal for the user to click 'yes' or 'no'
// Optionally pass in a string message as the first arg (default is 'Are you sure?')
// The last argument is the function to execute when 'yes' is clicked
// Clicking 'no' simply closes the modal
appl.def_lazy('confirm', function() {
	var msg, expr, node, self = this
	if(arguments.length === 2) {
		msg = 'Are you sure?'
		expr = arguments[0]
		node = arguments[1]
	} else {
		msg = appl.vs(arguments[0])
		expr = arguments[1]
		node = arguments[2]
	}

	var result = confirmation(msg)
	result.confirmed = function() { appl.vs(expr, node) }
	return self
})


// Display a temporary notification message at the bottom of the window
appl.def('notify', function(msg) {
	notification(msg)
	return appl
})

// Convert cents to dollars
appl.def('cents_to_dollars', function(cents) {
	return utils.cents_to_dollars(cents)
})


const momentTz = date =>  
  moment.tz(date, "YYYY-MM-DD HH:mm:ss", 'UTC').tz(ENV.nonprofitTimezone || 'UTC')

// Return a date in the format MM/DD/YY for a given date string or moment obj
appl.def('readable_date', function(date) {
  if(!date) return
  return momentTz(date).format("MM/DD/YY")
})

appl.def('payments_readable_date', function(date) {
	if(!date) return
	return moment.tz(date, "YYYY-MM-DD HH:mm:ss", ENV.nonprofitTimezone || 'UTC').format("MM/DD/YY")
})

// Given a created_at string (eg. Charge.last.created_at.to_s), convert it to a readable date-time string
appl.def('readable_date_time', function(date) {
  if(!date) return
  return momentTz(date).format("MM/DD/YY H:mma z")
})

// converts the return value of readable_date_time to it's ISO equivalent 
appl.def('readable_date_time_to_iso', date => {
  if(!date) return
  return moment.tz(date, 'MM/DD/YY H:mma z', ENV.nonprofitTimezone || 'UTC')
    .tz('UTC')
    .toISOString()
})

// Get the month number (eg 01,02...) for the given date string (or moment obj)
appl.def('get_month', function(date) {
  var monthNum = moment(date).month()
  return moment().month(monthNum).format('MMM')
})

// Get the year (eg 2017) for the given date string (or moment obj)
appl.def('get_year', function(date) {
	return moment(date).year()
})

// Get the day (number in the month) for the given date string (or moment obj)
appl.def('get_day', function(date) {
	return moment(date).date()
})


// Get the percentage of x over y
// eg: appl.percentage(34, 69) -> "49.28%"
appl.def('percentage', function(x, y) {
	return String(x / y * 100) + '%'
})


// Given a quantity and a plural word describing that quantity,
// return the proper version of that word for that quantitiy
// eg: appl.pluralize(4, 'tomatoes') -> "4 tomatoes"
// appl.pluralize(1, 'donors') -> "1 donor"
appl.def('pluralize', function(quantity, plural_word) {
	var str = String(quantity) + ' '
	if(quantity !== 1) return str+plural_word
	else return str + appl.to_singular(plural_word)
})


// Convert (most) words from their plural to their singular form
// Works with simple s-endings, ies-endings, and oes-endings
appl.def('to_singular', function(plural_word) {
		return plural_word
		.replace(/ies$/, 'y')
		.replace(/oes$/, 'o')
		.replace(/s$/, '')
})


// Truncate a text and add ellipsis to the end
appl.def('append_ellipsis', function(text, length) {
	if(text.length <= length) return text
	return text.slice(0,length).replace(/ [^ ]+$/, ' ...')
})


// General viewscript utilities
// All of these are to be added to the actual viewscript package in the future

// Push a given value into the arr given by the property name 'arr_key'
// Mutates the array stored at 'arr_key'
// appl.def('arr', [1,2,3])
// appl.push('arr', 4)
// appl.arr == [1,2,3,4]
appl.def('push', function(val, arr_key, node) {
	var arr = appl.vs(arr_key, node)
	if(!arr || !arr.length) arr = []
	arr.push(val)
	appl.def(arr_key, arr)
	return appl
})


// Concatenate two arrays (this is mutating)
// The first array is given by its property name and will be mutated
// The second array is the array itself to concatenate
// appl.def('arr1', [1,2,3])
// appl.concat('arr1', [4,5,6])
// appl.arr1 == [1,2,3,4,5,6]
appl.def('concat', function(arr1_key, arr2, node) {
	var arr1 = appl.vs(arr1_key, node)
	appl.def(arr1_key, arr1.concat(arr2))
	return appl
})


// Merge all key/vals from set_obj into all objects in the array given by the property 'arr_key'
// eg:
// appl.def('arr_of_objs', [{id: 1, name: 'Bob'}, {id: 2, name: 'Holga'}]
// appl.update_all('arr_of_objs', {name: 'Morty'})
// appl.arr_of_objs == [{id: 1, name: 'Morty'}, {id: 2, name: 'Morty'}]
appl.def('update_all', function(arr_key, set_obj, node) {
	appl.def(arr_key, appl.vs(arr_key).map(function(obj) {
		for(var key in set_obj) obj[key] = set_obj[key]
		return obj
	}))
})


// Given an array of objects in the view state (with property name 'arr_key'),
// and given an object to match on ('obj_matcher'),
// and given an object with values to set ('set_obj'),
// then set each object that matches key/vals in the obj_matcher to the key/vals in set_obj
//
// eg, if val at arr_key is: [{id: 1, name: 'Bob'}, {id: 2, name: 'Holga'}]
// and obj_matcher is: {id: 1}
// and set_obj is: {name: 'Gertrude'}
// then result will be: [{id: 1, name: 'Gertrude'}, {id: 2, name: 'Holga'}]
appl.def('find_and_set', function(arr_key, obj_matcher, set_obj, node) {
	var arr = appl.vs(arr_key)
	if(!arr) return appl
	var result = arr.map(function(obj) {
		for (var key in obj_matcher) {
			if(obj_matcher[key] === obj[key]) {
				return utils.merge(obj, set_obj)
			}
		}
		return obj
	})
	appl.def(arr_key, result)
	return appl
})

appl.def('find_and_remove', function(arr_key, obj_matcher, set_obj, node) {
	var arr = appl.vs(arr_key)
	if(!arr) return appl
	var result = arr.reduce(function(new_arr, obj) {
		for (var key in obj_matcher) {
			if(obj_matcher[key] === obj[key]) {
				return new_arr
			} else {
				new_arr.push(obj)
				return new_arr
			}
		}
	}, [])
	appl.def(arr_key, result)
	return appl
})


// Return a boolean whether the parent input is checked (must be a type checkbox)
appl.def('is_checked', function(node) {
	return appl.prev_elem(node).checked
})

// Check a parent input node (must be type checkbox)
appl.def('check', function(node) {
	appl.prev_elem(node).checked = true
})

// Uncheck a parent input node (must be type checkbox)
appl.def('uncheck', function(node) {
	appl.prev_elem(node).checked = false
})

// Check the parent node if the predicate is true
appl.def('checked_if', function(pred, node) {
	if(pred) appl.prev_elem(node).checked = true
	else     appl.prev_elem(node).checked = false
})

// Remove an attribute from the parent node
appl.def('remove_attr', function(attr, node) {
	appl.prev_elem(node).removeAttribute(attr)
})

appl.def('remove_attr_if', function(pred, attr, node) {
	if(!node) return
  var n = appl.prev_elem(node)
	if(pred) {
    if(!n.hasAttribute('data-attr-' + attr)) n.setAttribute('data-attr-' + attr, n.getAttribute(attr)) // cache attr to add back in
		n.removeAttribute(attr)
  } else if(!n.hasAttribute(attr)) {
    var val = n.getAttribute('data-attr-' + attr)
    n.setAttribute(attr, val)
  }
})

// Map over the given list and update it in the view
appl.transform = function(name, fn) {
	var result = appl.vs(name).map(fn)
	appl.def(name, result)
	return result
}

// Return the root url
appl.def('root_url', function() { return window.location.origin })

// Trigger a property to get updated in the view
appl.def('trigger_update', function(prop) {
	return appl.def(prop, appl.vs(prop))
})


appl.def('snake_case', function(string) {
	return string.replace(/ /g,'_')
})

appl.def('sort_arr_of_objs_by_key', function(arr_of_objs, key) {
	return arr_of_objs.sort(function(a, b) {
  	return a[key].localeCompare(b[key]);
		})
})

// Convert a positive integer into an ordinal (1st, 2nd, 3rd...)
appl.def('ordinalize', function(n) {
	if(n <= 0) return n
	// Deal with the preteen punks first
	if([11,12,13].indexOf(n) !== -1) return String(n) + 'th'
	var str = String(n)
	var lst = str[str.length-1]
	if(lst === '1') return String(n) + 'st'
	else if(lst === '2') return String(n) + 'nd'
	else if(lst === '3') return String(n) + 'rd'
	else return String(n) + 'th'
})

appl.def('toggle_side_nav', function(){
	if(appl.side_nav_is_open)
		appl.def('side_nav_is_open', false)
	else
		appl.def('side_nav_is_open', true)
})

appl.def('head', function(arr) {
	if(arr === undefined) return undefined
	return arr[0]
})

appl.def('select_drop_down', function(node) {
	var $li = $(node).parent()
	var $dropDown = $li.parents('.dropDown')
	$dropDown.find('li').removeClass('is-selected')
	$dropDown.find('.dropDown-toggle').removeClass('is-droppedDown')
	$li.addClass('is-selected')
})

appl.def('clear_drop_down', function(node){
	var $dropDown = $(node).parents('.dropDown')
	$dropDown.find('li').removeClass('is-selected')
	$dropDown.find('.dropDown-toggle').removeClass('is-droppedDown')
})

appl.def('strip_tags', function(html){
	if(!html) return
	return html.replace(/(<([^>]+)>)/ig," ")
})

appl.def('replace', function(string, matcher, replacer) {
	if(!string) return
	// the new RegExp constructor takes a string
	// and returns a regex: new RegExp("a|b", "i") becomes /a|b/i
	return string.replace(new RegExp(matcher, 'g'), replacer)
})

appl.def('number_with_commas', function(n){
	if(!n){return}
	return utils.number_with_commas(n)
})

appl.def('remove_commas', function(s) {
  return s.replace(/,/g, '')
})

appl.def('percentage', function(x, y, number_of_decimals){
  if(!x || !y) return 0
  number_of_decimals = number_of_decimals || 2
  return Number((y/x * 100).toFixed(number_of_decimals))
})

appl.def('clean_url', function(string){
  return string.replace(/.*?:\/\//g, "")
})

appl.def('address_with_commas', function(address, city, state){
  return utils.address_with_commas(address, city, state)
})

appl.def('format_phone', function(st) {
  return utils.pretty_phone(st)
})

