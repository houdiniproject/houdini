// License: LGPL-3.0-or-later
$.fn.serializeObject = function() {
	return this.serializeArray().reduce(function(obj, field) {
		if(field.value)
			var val = field.value
		else if(field.files && field.files[0])
			var val = field.files[0]
		obj[field.name] = val
		return obj 
	}, {})
}

// Make a button enter the ajax loading state, where it's disabled and has a little spinner.
$.fn.loading = function(message) {
	this.each(function() {
		var msg = message || this.getAttribute('data-loading')
		this.setAttribute('data-text', this.innerHTML)
		this.innerHTML = "<i class='fa fa-spin fa-spinner'></i> " + msg
		this.setAttribute('disabled', 'disabled')
	})
	return this
}

$.fn.disableLoading = function() {
	this.each(function() {
		if(!this.hasAttribute('disabled')) return
		var old_text = this.getAttribute('data-text')
		this.innerHTML = old_text
		this.removeAttribute('disabled')
	})
	return this
}
