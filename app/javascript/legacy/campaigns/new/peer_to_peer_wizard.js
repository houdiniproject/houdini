// License: LGPL-3.0-or-later

//This is used for federated p2p campaigns
require('../../components/wizard')
var format_err = require('../../common/format_response_error')

appl.def('advance_p2p_campaign_name_step', function(form_obj) {
  var name = form_obj['campaign[name]']
  appl.def('new_p2p_campaign', form_obj)
  appl.wizard.advance('new_p2p_campaign_wiz')
})

// Post a new campaign.
appl.def('create_p2p_campaign', function(el) {
	var form_data = utils.toFormData(appl.prev_elem(el))
	form_data = utils.mergeFormData(form_data, appl.new_p2p_campaign)
	appl.def('new_p2p_campaign_wiz.loading', true)

	post_p2p_campaign(form_data)
		.then(function(req) {
			appl.notify("Redirecting to your campaign...")
			appl.redirect(JSON.parse(req.response).url)
		})
		.catch(function(req) {
			appl.def('new_p2p_campaign_wiz.loading', false)
			appl.def('new_p2p_campaign_wiz.error', req.responseText)
		})
})

// Using the bare-bones XMLHttpRequest API so we can post form data and upload the image
function post_p2p_campaign(form_data) {
	return new Promise(function(resolve, reject) {
		var req = new XMLHttpRequest()
		req.open("POST", '/nonprofits/' + app.nonprofit_id + '/campaigns')
		req.setRequestHeader('X-CSRF-Token', window._csrf)
    console.log(form_data)
		req.send(form_data)
		req.onload = function(ev) {
			if(req.status === 200) resolve(req)
			else reject(req)
		}
	})
}
