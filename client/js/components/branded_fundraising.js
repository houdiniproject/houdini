// License: LGPL-3.0-or-later
const brandColors = require('../components/nonprofit-branding')

$('[if-branded]').each(function() {
  var params = this.getAttribute("if-branded").split(',').map(function(s) { return s.trim() })
  $(this).css(params[0], brandColors[params[1]])
})

exports = brandColors

