// License: LGPL-3.0-or-later
// Console fallback
if (!window.console) {
	window.console = new function() {
		this.log = function(str) {}
		this.dir = function(str) {}
	}
}

// Promises polyfill
require('es6-promise').polyfill()
