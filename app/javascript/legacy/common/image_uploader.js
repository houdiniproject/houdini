// License: LGPL-3.0-or-later
$('.image-upload input').change(function(e) {
	var self = this
	appl.def('image_upload.is_selecting', true)
	if(this.files && this.files[0]) {
		var reader = new FileReader()
		reader.onload = function(e) {
			if(e.valueOf().loaded >= 3000000) {
				appl.def('image_upload.error', 'Please select a file smaller than 3mb')
			} else {
				appl.def('image_upload.error', '')
			}
			$(self).parent().css('background-image', "url('" + e.target.result + "')")
			$(self).parent().addClass('live-preview')
		}
		reader.readAsDataURL(this.files[0])
	}
})

appl.def('remove_image', function(url, resource, notification, payload) {
	var data = {}
	data[resource] = payload
	appl.notify(notification)
	appl.def('loading', true)
	$.ajax({
		type: 'put',
		url: url,
		data: data,
	})
		.done(function() {
			appl.reload()
		})
		.fail(function(e) { })
})
