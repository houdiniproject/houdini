// License: LGPL-3.0-or-later
require('../../common/pikaday-timepicker')
require('../../components/wizard')
require('../../common/image_uploader')
var checkName = require('../../common/ajax/check_campaign_or_event_name')
var format_err = require('../../common/format_response_error')


appl.def('advance_event_name_step', function(form_obj) {
  var name = form_obj['event[name]']
  checkName(name, 'event', function(){
    appl.def('new_event', form_obj) 
    appl.wizard.advance('new_event_wiz')
  })
})

// Post a new event.
appl.def('create_event', function(el) {
	var form_data = utils.toFormData(appl.prev_elem(el))
	form_data = utils.mergeFormData(form_data, appl.new_event)
	appl.def('new_event_wiz.loading', true)

	post_event(form_data)
		.then(function(req) {
			appl.notify("Redirecting to your new event...")
			appl.redirect(JSON.parse(req.response).url)
		})
		.catch(function(req) {
			appl.def('new_event_wiz.loading', false)
			appl.def('new_event_wiz.error', req.responseText)
		})
})


// Using the bare-bones XMLHttpRequest API so we can post form data and upload the image
function post_event(form_data) {
	return new Promise(function(resolve, reject) {
		var req = new XMLHttpRequest()
		req.open("POST", '/nonprofits/' + app.nonprofit_id + '/events')
		req.setRequestHeader('X-CSRF-Token', window._csrf)
		req.send(form_data)
		req.onload = function(ev) {
			if(req.status === 200) resolve(req)
			else reject(req)
		}
	})
}


// Pikaday and timepicker initialization nonsense

var Pikaday = require('pikaday')
var moment = require('moment')
new Pikaday({
	field: document.querySelector('#date-string-input'),
	format: 'M/D/YYYY',
	minDate: moment().toDate()
})

