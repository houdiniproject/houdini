// License: LGPL-3.0-or-later
// super-agent with default json and csrf wrappers
// Also has a Promise api ('.then' and '.catch') rather than the default '.end'

var request = require('superagent')

var wrapper = {}
module.exports = wrapper

wrapper.post = function() {
	var req = request.post.apply(this, arguments).set('X-CSRF-Token', window._csrf).type('json')
	return convert_to_promise(req)
}

wrapper.put = function() {
	var req = request.put.apply(this, arguments).set('X-CSRF-Token', window._csrf).type('json')
	return convert_to_promise(req)
}

wrapper.del = function() {
	var req = request.del.apply(this, arguments).set('X-CSRF-Token', window._csrf).type('json')
	return convert_to_promise(req)
}

wrapper.get = function(path) {
	var req = request.get.call(this, path).accept('json')
	return convert_to_promise(req)
}

function convert_to_promise(req) {
	req.perform = function() {
		return new Promise(function(resolve, reject) {
			req.end(function(err, resp) {
				if(resp && resp.ok) { resolve(resp) }
				else { reject(resp) }
			})
		})
	}
	return req
}

