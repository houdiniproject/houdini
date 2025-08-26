// License: LGPL-3.0-or-later
// Functionality for Event Editors (a nonprofit admin, the event creator, or a super admin)

require('../../common/image_uploader')

const dupeIt = require('../../components/duplicate_fundraiser')

var prefix = `/nonprofits/${app.nonprofit_id}/events` 

// takes prefix and fundraiser id
dupeIt(prefix, app.event_id)

var url = `${prefix}/${app.event_id}`
var Pikaday = require('pikaday')
var moment = require('moment')

require('../../components/ajax/toggle_soft_delete')(url, 'event')

new Pikaday({
	field: document.querySelector('.date-picker'),
	format: 'M/D/YYYY',
	minDate: app.event_date || moment().toDate()
})


$('input[type=radio][name="event[in_person_or_virtual]"]').on('change', (event) => {
	if (event.currentTarget.value === 'in_person')
		$('#editEventInPersonFields').removeClass('u-hide')
	else
		$('#editEventInPersonFields').addClass('u-hide')
})


var editable = require('../../common/editable')

editable($('#js-eventDescription'), {
	sticky: true,
	placeholder: "Add any event related text, images, videos or custom HTML here. We strongly recommend that this section is filled out with at least 250 words. It will be saved automatically as you type."
})

editable($('#js-customReceipt'), {
  button: ["bold", "italic", "formatBlock", "align", "createLink",
  		"insertImage", "insertUnorderedList", "insertOrderedList",
  		"undo", "redo", "insert_donate_button", "html"]
	, placeholder: "Add optional message here. It will be saved automatically as you type."
})


appl.def('remove_this_image', function() {
	appl.remove_background_image(url, 'event')
})
