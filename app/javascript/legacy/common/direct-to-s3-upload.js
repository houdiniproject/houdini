// License: LGPL-3.0-or-later
const flyd = require('flyd')
const R = require('ramda')
const activestorage = require('../../common/activestorage')

// Pass in a stream of Input Nodes with type file
// Make a post request to our server to start the import
// Will create a backgrounded job and email the user when 
// completed
// Returns a stream of {uri: 'uri of uploaded file on s3', formData: 'original form data'}
const uploadFile =  (controllerUrl) => {
  return R.curry(input => {
    const $stream  = flyd.stream()
    activestorage.uploadFile(controllerUrl, input.files[0]).then((blob) => $stream(blob))
    return $stream;
  })
}

module.exports = uploadFile

