// License: LGPL-3.0-or-later
var actions = [ 'change', 'click', 'dblclick', 'mousedown', 'mouseup', 'mouseenter', 'mouseleave', 'scroll', 'blur', 'focus', 'input', 'submit', 'keydown', 'keypress', 'keyup' ]

function event(id, fn) {
	// Find all classes ending in the event id
	actions.forEach(function(action) {
		$('*[on-' + action + '="' + id + '"]').each(function() {
			if(this.getAttribute('on-' + action).indexOf(id) !== -1)
				$(this).on(action, fn)
		})
	})
}

module.exports = event
