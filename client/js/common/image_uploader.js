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

appl.def('remove_background_image', function(url, resource) {
	var data = {}
	data[resource] = {remove_background_image: true}
	appl.notify('Removing background image...')
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
