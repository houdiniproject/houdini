// License: LGPL-3.0-or-later
var notification = require('./notification')

$('form.dynamic').submit(function(e) {
	var self = this
	e.preventDefault()
	var path = this.getAttribute('action')
	var meth = this.getAttribute('method')
	var form_data = new FormData(this)
	$(this).find('button[type="submit"]').loading()

	$.ajax({
		type: meth,
		url: path,
		data: form_data,
		dataType: 'json',
		processData: false,
		contentType: false
	})
	.done(function(d) {
		$('.modal').modal('hide')
		notification(d.notification)
	})
	.fail(function(d) {
		$(self).find('.error').text(utils.print_error(d))
	})
	.complete(function() {
		$(self).find('button[type="submit"]').disableLoading()
	})
})
