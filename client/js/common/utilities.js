// License: LGPL-3.0-or-later
// Utilities!
// XXX remove this whole file and split into modules with specific concerns
const phoneFormatter = require('phone-formatter');

var utils = {}

module.exports = utils

// XXX remove
utils.capitalize = string =>
  string.charAt(0).toUpperCase() + string.slice(1)

// Print a single message for Rails error responses
// XXX remove
utils.print_error = function (response) {
	const msg = 'Sorry! We encountered an error.'
	if(!response) return msg
	if(response.status === 500) return msg
	else if(response.status === 404) return "404 - Not found"
	else if(response.status === 422 || response.status === 401) {
		if(!response.responseJSON) return msg

		const json = response.responseJSON
		if(json.length) return json[0]

		else if(json.errors)
			for (var key in json.errors)
				return key + ' ' + json.errors[key][0]

		else if(json.error) return json.error

		else return msg
	}
}

// Retrieve a URL parameter
// XXX remove
utils.get_param = function(name) {
	const param = decodeURI((RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) || [null])[1])
	return (param == 'undefined') ? undefined : param
}

// XXX remove
utils.change_url_param = function(key, value) {
	if (!history || !history.replaceState) return
	history.replaceState({}, "", utils.update_param(key, value))
}

// XXX remove. Depended on only by 'change_url_param' above
utils.update_param = function(key, value, url) {
	if(!url) url = window.location.href
	const re = new RegExp("([?&])" + key + "=.*?(&|#|$)(.*)", "gi")

	if(re.test(url)) {
		if(typeof value !== 'undefined' && value !== null)
			return url.replace(re, '$1' + key + "=" + value + '$2$3')
		else {
			var hash = url.split('#')
			url = hash[0].replace(re, '$1$3').replace(/(&|\?)$/, '')
			if(typeof hash[1] !== 'undefined' && hash[1] !== null)
				url += '#' + hash[1]
			return url
		}
	} else {
		if (typeof value !== 'undefined' && value !== null) {
			var separator = url.indexOf('?') !== -1 ? '&' : '?',
				hash = url.split('#')
			url = hash[0] + separator + key + '=' + value
			if(typeof hash[1] !== 'undefined' && hash[1] !== null)
				url += '#' + hash[1]
			return url
		}
		else return url
	}
}

// Pad a number with leading zeros
// XXX remove
utils.zero_pad = function(num, size) {
	let str = num + ""
	while (str.length < size) str = "0" + str
	return str
}

// for doing an action after the user pauses for a second after an event
// XXX remove
utils.delay = (function() {
	let timer = 0
	return function(ms, callback) {
		clearTimeout(timer)
		timer = setTimeout(callback, ms)
	}
})()

utils.number_with_commas = function(n) {
	return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
}

// Merge x's properties with y (mutating)
utils.merge = function(x, y) {
	for (const key in y) { x[key] = y[key]; }
	return x
}

var format = require('./format')
utils.dollars_to_cents = format.dollarsToCents
utils.cents_to_dollars = format.centsToDollars

// Create a single FormData object from any number of inputs and forms (not bound to a single form)
// Kind of a re-implementation of: http://www.w3.org/html/wg/drafts/html/master/forms.html#constructing-the-form-data-set
// XXX remove
utils.toFormData = function(form_el) {
	const form_data = new FormData()
	$(form_el).find('input, select, textarea').each(function() {
		if(!this.name) return
		if(this.files && this.files[0])
			form_data.append(this.name, this.files[0])
		else if(this.getAttribute("type") === "checkbox")
			form_data.append(this.name, this.checked)
		else if(this.value)
			form_data.append(this.name, this.value)
	})
	return form_data
}

utils.mergeFormData = function(formData, obj) {
	for(const key in obj) formData.append(key, obj[key])
	return formData
}


// Given an array of values, return an array only with unique values
// XXX remove
utils.uniq = function(arr) {
	var obj = {}
	var index
	const len = arr.length
	var result = [];
	for(index = 0; index < len; index += 1) obj[arr[index]] = arr[index];
	for(index in obj) result.push(obj[index]);
	return result
}

// XXX remove
utils.address_with_commas = function(street, city, state){
	var address = [street, city, state]
	var pretty_print_add = []
	for(var i = 0; i < address.length; i += 1) {
		if (address[i] !== '' && address[i] != null) pretty_print_add.push(address[i])
	}
	return pretty_print_add.join(', ')
}

utils.pretty_phone = function(phone){
	if(!phone) {return false}
  
  // first remove any non-digit characters globally 
  // and get length of phone number
  var clean = String(phone).replace(/\D/g, '')
  var len = clean.length

  var format = "(NNN) NNN-NNNN"

  // then format based on length
  if(len === 10) {
    return phoneFormatter.format(clean, format) 
  }
  if(len > 10) {
    var first = clean.substring(0, len - 10)
    var last10 = clean.substring(len - 10) 
    return `+${first} ${phoneFormatter.format(last10, format)}`
  }

  // if number is less than 10, don't apply any formatting
  // and just return it
  return clean
}

