// License: LGPL-3.0-or-later
// superapi wrapper with our api defaults

var request = require('superagent')

var wrapper = {}

wrapper.post = function() {
	return request.post.apply(this, arguments).set('X-CSRF-Token', window._csrf).type('json')
}

wrapper.put = function() {
	return request.put.apply(this, arguments).set('X-CSRF-Token', window._csrf).type('json')
}

wrapper.del = function() {
	return request.del.apply(this, arguments).set('X-CSRF-Token', window._csrf).type('json')
}

wrapper.get = function(path) {
	return request.get.call(this, path).accept('json')
}

module.exports = wrapper

