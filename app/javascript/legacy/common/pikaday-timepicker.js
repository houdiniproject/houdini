// License: LGPL-3.0-or-later
const bind = require('attr-binder')
const Pikaday = require('pikaday-time')
const moment = require('moment')

bind('pikaday-timepicker', function(container, format) {
  const button = container.querySelector('a')
  const input = container.querySelector('input')
  input.readOnly = true

  const maxDate_str = input.getAttribute('pikaday-maxDate')
  const maxDate = maxDate_str ? moment(maxDate_str) : undefined
  const defaultDate_str = input.getAttribute('pikaday-defaultDate')
  const defaultDate = defaultDate_str ? moment(defaultDate_str) : undefined
  new Pikaday({
    showTime: true
  , showMinutes: true
  , showSeconds: false
  , autoClose: false
  , timeLabel: 'Time'
  , format
  , setDefaultDate: Boolean(defaultDate)
  , field: input
  , maxDate
  , defaultDate
  , trigger: button
  })

})

