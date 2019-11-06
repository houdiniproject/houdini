// License: LGPL-3.0-or-later
const bind = require('attr-binder')
const Pikaday = require('pikaday')
const moment = require('moment')

bind('apply-pikaday', function(field, format) {
  const setDefaultDate = field.getAttribute('pikaday-setDefaultDate')
  const maxDate_str = field.getAttribute('pikaday-maxDate')
  const maxDate = maxDate_str ? moment(maxDate_str) : undefined
  const defaultDate_str = field.getAttribute('pikaday-defaultDate')
  const defaultDate = defaultDate_str ? moment(defaultDate_str) : undefined
  new Pikaday({format, setDefaultDate, field, maxDate, defaultDate})
})

