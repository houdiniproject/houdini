require('../../common/pikaday-timepicker')
require('../../components/wizard')
require('../../common/image_uploader')
var confirmation = require('../../common/confirmation')
var format_err = require('../../common/format_response_error')

appl.def('advance_campaign_template_name_step', function(form_obj) {
  appl.def('new_campaign_template', form_obj)
  appl.wizard.advance('new_campaign_template_wiz')
})

// Post a new campaign template
appl.def('create_campaign_template', function(el) {
	var form_data = utils.toFormData(appl.prev_elem(el))
	form_data = utils.mergeFormData(form_data, appl.new_campaign_template)
	appl.def('new_campaign_template_wiz.loading', true)

	post_campaign_template(form_data)
		.then(function(req) {
			appl.notify("Campaign template created!")
      var template_id = JSON.parse(req.response).id
			appl.redirect('/nonprofits/' + app.nonprofit_id + '/campaign_templates')
		})
		.catch(function(req) {
			appl.def('new_campaign_template_wiz.loading', false)
			appl.def('new_campaign_template_wiz.error', req.responseText)
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
function post_campaign_template(form_data) {
	return new Promise(function(resolve, reject) {
		var req = new XMLHttpRequest()
		req.open("POST", '/nonprofits/' + app.nonprofit_id + '/campaign_templates')
		req.setRequestHeader('X-CSRF-Token', window._csrf)
		req.send(form_data)
		req.onload = function(ev) {
			if(req.status === 200) resolve(req)
			else reject(req)
		}
	})
}

appl.def('delete_template', function(id) {
  var result = confirmation('Are you sure?')
  result.confirmed = function() {
    appl.def('loading', true)
    var url = '/nonprofits/' + app.nonprofit_id + '/campaign_templates/' + id

    return new Promise(function(resolve, reject) {
      var req = new XMLHttpRequest()
      req.open("DELETE", url)
      req.setRequestHeader('X-CSRF-Token', window._csrf)
      req.send({ campaign_template: {id: id} })
      req.onload = function(ev) {
        if(req.status === 204) resolve(req)
        else reject(req)
      }
    }).then(function() {
      appl.def('loading', false)
      appl.notify('Successfully deleted template.')
      appl.redirect('/nonprofits/' + app.nonprofit_id + '/campaign_templates')
    })
  }
})


appl.def('create_campaign_from_template', function(campaign_params) {
  appl.def('loading', true)

  var url = '/nonprofits/' + app.nonprofit_id + '/campaigns/create_from_template'
  var params = new Object
  params.campaign = JSON.parse(campaign_params)
  params.campaign.profile_id = app.profile_id

  return new Promise(function(resolve, reject) {
    var req = new XMLHttpRequest()
    req.open("POST", url)
    req.setRequestHeader('X-CSRF-Token', window._csrf)
    req.setRequestHeader('Content-Type', 'application/json')
    req.send(JSON.stringify(params))
    req.onload = function(ev) {
      if(req.status === 200) resolve(req)
      else reject(req)
    }
  }).then(function(req) {
    appl.def('loading', false)
    appl.notify('Redirecting you to your campaign…')
    var campaign_id = JSON.parse(req.response).id
    appl.redirect(url + '/' + campaign_id)
  })
  .catch(function(req) {
    appl.def('loading', false)
    appl.notify(req.responseText)
  })
})


