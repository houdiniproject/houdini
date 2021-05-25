// License: LGPL-3.0-or-later
require('../../common/image_uploader')
require('../../common/on-change-sanitize-slug')
var url = "/nonprofits/" + app.nonprofit_id

appl.def('remove_background_image', function () {
	var url = '/nonprofits/' + app.nonprofit_id
	var notification = 'Removing background image...'
	var payload = { remove_background_image : true }
	appl.remove_image(url, 'nonprofit', notification, payload)
})
