// License: LGPL-3.0-or-later
const R = require('ramda')
const request = require('flyd-ajax')

module.exports = options => {
  options.headers = R.merge({
    'Content-Type': 'application/json'
  , 'X-CSRF-Token': window._csrf
  }, options.headers || {})
  return request(options)
}
