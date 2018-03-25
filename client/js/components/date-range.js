// License: LGPL-3.0-or-later
const moment = require('moment')
require('moment-range')

// returns an array of moments
// timeSpan is one of 'day, 'week', 'month', 'year' (see moment.js docs)
module.exports = (startDate, endDate, timeSpan) => {
  var dates = [moment(startDate), moment(endDate)]
  return moment.range(dates).toArray(timeSpan)
}

