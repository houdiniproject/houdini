// License: LGPL-3.0-or-later
require('../../common/pikaday-timepicker')
require('../../components/wizard')
require('../../common/image_uploader')
var checkName = require('../../common/ajax/check_campaign_or_event_name')

/**
 * NOTE: does not handle duplicate keys at all
 * @param {FormData} formData 
 * @returns {Record<string, any>} an object with the keys and values from the FormData object. Does not handle duplicates
 *
 * 
 */
function formDataToObject(formData) { 
	const obj = {}
	for(let prop of formData) {obj[prop[0]] = prop[1]};
	return obj;
}


appl.def('advance_event_name_step', function(form_obj) {
  var name = form_obj['event[name]']
  checkName(name, 'event', function(){
    appl.def('new_event', form_obj) 
    appl.wizard.advance('new_event_wiz')
  })
})

appl.def('advance_event_location_step', function(formData) {
	appl.def('new_event', formDataToObject(formData)) 
	appl.wizard.advance('new_event_wiz')
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

/**
 * The list of event attributes whose inputs are listed as required. They only need to be required when the the event is in_person
 */ 
const requiredEventFieldNames = ['venue_name', 'address', 'city'];

/**
 * 
 * @param {string} name one of the items in requiredEventFieldName
 * @returns a full selector to be used by jQuery to find an element
 */
function getFullFieldSelector(name) {
	return `input[type=text][name="event[${name}]"]`;
}

$('input[type=radio][name="event[in_person_or_virtual]"]').on("change", (event) => {
	if (event.currentTarget.value === 'in_person') {
		/** show all of the in person address fields */
		$('#newEventModalInPersonFields').removeClass('u-hide')
		requiredEventFieldNames.forEach((i) => {
			const fieldSelector = getFullFieldSelector(i)
			/** mark the in person address fields which should be required */
			$(fieldSelector).attr('required', true)
		});
	}
	else {
		/** hide the in person address fields */
		$('#newEventModalInPersonFields').addClass('u-hide');
		requiredEventFieldNames.forEach((i) => {
			/** unmark the in person address fields which should be required */
			const fieldSelector = getFullFieldSelector(i)
			$(fieldSelector).removeAttr('required');
		});
	}
});


