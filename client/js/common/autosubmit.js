// License: LGPL-3.0-or-later
var confirmation = require('./confirmation')
var notification = require('./notification')

$('form[autosubmit]').submit(function(e) {
	var self = this
	e.preventDefault()

	if(this.hasAttribute('data-confirm')) {
		var result = confirmation()
		result.confirmed = function() {
			submit_form(e.currentTarget)
		}
	} else submit_form(e.currentTarget)
})

function submit_form(form_el, on_success) {
	var path = form_el.getAttribute('action')
	var method = form_el.getAttribute('method')
	var form_data = new FormData(form_el)
	$(form_el).find('button[type="submit"]').loading()
	$(form_el).find('.error').text('')

	var notice = form_el.getAttribute('notice')
	if(notice) $.cookie('notice', notice, {path: '/'})

	$.ajax({
		type: method,
		url: path,
		data: form_data,
		dataType: 'json',
		processData: false,
		contentType: false
	})
	.done(function(d) {
		if(form_el.hasAttribute('data-reload-with-slug'))
			window.location = d['url']
		else if(form_el.hasAttribute('data-reload'))
			window.location.reload()
		else if(form_el.hasAttribute('data-redirect')) {
			var redirect = form_el.getAttribute('data-redirect')
			if(redirect) window.location.href = redirect
			else if(d.url) window.location.href = d.url
		} else {
			var msg = form_el.getAttribute('data-success-message')
			if(msg) notification(msg)
			$(form_el).find('button[type="submit"]').disableLoading()
		}
		if(on_success) on_success(d)
	})
	.fail(function(d) {
		$(form_el).find('.error').text(utils.print_error(d))
		$(form_el).find('button[type="submit"]').disableLoading()
	})
}

// Third closure

appl.def_lazy('autosubmit', function(callback, node) {
	if(!node || !node.parentNode) return

	var self = this, parent = node.parentNode

	parent.onsubmit = function(ev) {
		ev.preventDefault()

		if(parent.hasAttribute('data-confirm'))
			confirmation().confirmed = function() { submit_form(parent, function() {appl.vs(callback)}) }
		else submit_form(parent, function() { appl.vs(callback) })
	}
})

