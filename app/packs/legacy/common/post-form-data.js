// License: LGPL-3.0-or-later
const flyd = require('flyd')
const R = require('ramda')

// TODO make this use flyd-ajax
// Using the bare-bones XMLHttpRequest API so we can post form data and upload the image
// Returns a flyd stream

module.exports = R.curryN(2, (url, object) => {
  var stream = flyd.stream()
  var req = new XMLHttpRequest()
  var formData = new FormData()
  R.mapObjIndexed((val, key) => {
    if(val.constructor === Object) val = JSON.stringify(val)
    formData.append(key, val)
  }, object)
  req.open("POST", url)
  // req.setRequestHeader('X-CSRF-Token', window._csrf)
  req.send(formData)
  req.onload = ev => {
    var body = {}
    try { body = JSON.parse(req.response) } catch(e) { }
    stream( {status: req.status, body: body } )
  }
  return stream
})

