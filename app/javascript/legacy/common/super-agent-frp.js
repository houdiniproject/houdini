// License: LGPL-3.0-or-later
// super-agent with default json and csrf wrappers
// Also has a FRP api (using flyd) rather than the default '.end'
// Every call to .perform() returns a flyd stream

var request = require('superagent')
var flyd = require("flyd")

var wrapper = {
  post: function() {
    return injectFlyd(request.post.apply(this, arguments).set('X-CSRF-Token', window._csrf).type('json'))
  }
, put: function() {
    return injectFlyd(request.put.apply(this, arguments).set('X-CSRF-Token', window._csrf).type('json'))
  }
, del: function() {
    return injectFlyd(request.del.apply(this, arguments).set('X-CSRF-Token', window._csrf).type('json'))
  }
, get: function() {
    return injectFlyd(request.get.apply(this, arguments).accept('json'))
  }
}

function injectFlyd(req) {
	req.perform = function() {
		var $stream = flyd.stream()
		req.end(function(err, resp) { $stream(resp) })
		return $stream
	}
	return req
}

module.exports = wrapper
