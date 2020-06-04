// License: LGPL-3.0-or-later
const h = require('flimflam/h')
const modal = require('flimflam/ui/modal')

// convenience wrapper for setting modal sizes
// sizes can be 'small' or 'large'
module.exports = (obj, size='medium') => 
  h('div', {class: {[`modal-${size}`] : size}}, [ modal(obj)])

