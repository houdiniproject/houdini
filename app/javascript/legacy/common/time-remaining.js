// License: LGPL-3.0-or-later
const flyd = require('flyd')
const flyd_every = require('flyd/module/every')
const moment = require('moment-timezone')
const format = require('../common/format')
const pluralize = format.pluralize

// Given an end dateTime ("2015-11-17 19:00") and a time-zone ("America/Los_Angeles"),
// if the end dateTime has passed, return false
// if the end dateTime is more than a day away
//   then return the number of days away
// if the end dateTime is less than a day away
//   then return a countdown stream with seconds precision
//
// This function returns a stream.
//
// This function takes a timezone in the format "Country/City"
// See here: http://momentjs.com/timezone/
//


const timeRemaining = (endDateTime, tz) => {
  if(!endDateTime) return flyd.stream(false)
  const format = "YYYY-MM-DD hh:mm:ss zz"
  tz = tz || ENV.nonprofitTimezone || 'America/Los_Angeles'
  const [now, end] = [moment().tz(tz), moment(endDateTime, format).tz(tz).seconds(59)]
  console.log({now, end})
  if(end.isBefore(now)) return flyd.stream(false)

  if(end.diff(now, 'hours') <= 24) {
    return flyd.map(
      t => moment.utc(end.diff(moment(t))).format("HH:mm:ss")
    , flyd_every(1000))
  } else {
    return flyd.stream(pluralize(end.diff(now, 'days'), 'days'))
  }
}

module.exports = timeRemaining
