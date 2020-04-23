// License: LGPL-3.0-or-later
require('../../common/pikaday-timepicker')
require('../../components/wizard')
require('../../common/image_uploader')
var checkName = require('../../common/ajax/check_campaign_or_event_name')
var format_err = require('../../common/format_response_error')


appl.def('advance_campaign_name_step', function(form_obj) {
  var name = form_obj['campaign[name]']
  checkName(name, 'campaign', function(){
    appl.def('new_campaign', form_obj) 
    appl.wizard.advance('new_campaign_wiz')
  })
})

// Post a new campaign.
appl.def('create_campaign', function(el) {
	var form_data = utils.toFormData(appl.prev_elem(el))
	form_data = utils.mergeFormData(form_data, appl.new_campaign)
	appl.def('new_campaign_wiz.loading', true)

// TODO: for p2p capmaigns, merge with preset campaing params

	post_campaign(form_data)
		.then(function(req) {
			appl.notify("Redirecting to your campaign...")
			appl.redirect(JSON.parse(req.response).url)
		})
		.catch(function(req) {
			appl.def('new_campaign_wiz.loading', false)
			appl.def('new_campaign_wiz.error', req.responseText)
		})
})


var Pikaday = require('pikaday')
var moment = require('moment')
new Pikaday({
	field: document.querySelector('.js-date-picker'),
	format: 'M/D/YYYY',
	minDate: moment().toDate()
})

// Using the bare-bones XMLHttpRequest API so we can post form data and upload the image
function post_campaign(form_data) {
	return new Promise(function(resolve, reject) {
		var req = new XMLHttpRequest()
		req.open("POST", '/nonprofits/' + app.nonprofit_id + '/campaigns')
		req.setRequestHeader('X-CSRF-Token', window._csrf)
		req.send(form_data)
		req.onload = function(ev) {
			if(req.status === 200) resolve(req)
			else reject(req)
		}
	})
}
