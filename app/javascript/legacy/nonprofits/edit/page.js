// License: LGPL-3.0-or-later
require('../../common/image_uploader')
require('../../common/on-change-sanitize-slug').default
var url = "/nonprofits/" + app.nonprofit_id

appl.def('remove_this_image', function() {
	appl.remove_background_image(url, 'nonprofit')
})
