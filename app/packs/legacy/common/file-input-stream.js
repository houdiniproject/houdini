// License: LGPL-3.0-or-later
const flyd = require('flyd')
const R = require('ramda')

// Given an input element, return a stream of the input file data as text

module.exports = R.curry(node => {
  var $stream = flyd.stream()
  var file = node.files[0]
  var reader = new FileReader()
  if(file instanceof Blob) {
    reader.readAsText(file)
    reader.onload = e => $stream(reader.result)
  }
  return $stream
})

