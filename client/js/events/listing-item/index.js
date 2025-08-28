// License: LGPL-3.0-or-later
const format = require('../../common/format')
const h = require('snabbdom/h')
const moment = require('moment-timezone')
const {commaJoin} = require('./common');

const dateTime = (startTime, endTime) => {
  const tz = ENV.nonprofitTimezone || 'America/Los_Angeles'
  startTime = moment(startTime).tz(tz)
  endTime = moment(endTime).tz(tz)
  const sameDate = startTime.format("YYYY-MM-DD") === endTime.format("YYYY-MM-DD")
  const ended = moment() > endTime ? ' (ended)' : ''
  const format = 'MM/DD/YYYY h:mma'
  const endTimeFormatted = sameDate ? endTime.format("h:mma") : endTime.format(format)

  return [
    h('strong', startTime.format(format) + ' - ' + endTimeFormatted)
  , h('span.u-color--grey', ended)
  ]
}

const metric = (label, val) => 
  h('span.u-inlineBlock.u-marginRight--20', [h('strong', `${label}: `), val || '0'])

const row = (icon, content) => 
  h('tr', [
    h('td.u-centered', [h(`i.fa.${icon}`)])
  , h('td.u-padding--10', content)
  ])

/**
 * 
 * @param {*} event an event for a location
 * @returns {ReturnType<typeof h>[]}
 */
const locationElements = (event) => {
  if (event.in_person_or_virtual === 'virtual') {
    return [
      h('p.strong.u-margin--0', 'Virtual')
    ]
  }
  else {
    return [
      h('p.strong.u-margin--0', event.venue_name) 
    , h('p.u-margin--0', commaJoin([event.address, event.city, event.state_code, event.zip_code]))
    ]
  }
}

module.exports = e => {
  const path = `/nonprofits/${app.nonprofit_id}/events/${e.id}`
  const location = locationElements(e)
  const attendeesMetrics = [
    metric('Attendees', e.total_attendees) 
  , metric('Checked In', e.checked_in_count) 
  , metric('Percent Checked In', Math.round((e.checked_in_count || 0) * 100 / (e.total_attendees || 0)) + '%')
  ]
  const moneyMetrics = [
    metric('Ticket Payments', '$' + format.centsToDollars(e.tickets_total_paid))
  , metric('Donations', '$' + format.centsToDollars(e.donations_total_paid))
  , metric('Total', '$' + format.centsToDollars(e.total_paid))
  ]
  const links = [
    h('a.u-marginRight--20', {props: {href: path, target: '_blank'}}, 'Event Page')
  , h('a', {props: {href: path + '/tickets', target: '_blank'}}, 'Attendees Page')
  ]
  return h('div.u-paddingTop--10.u-marginBottom--20', [
    h('h5.u-paddingX--20', e.name)
  , h('table.table--striped.u-margin--0', [
      row('fa-clock-o', dateTime(e.start_datetime, e.end_datetime))
    , row('fa-map-marker', location)
    , row('fa-users', attendeesMetrics)
    , row('fa-dollar', moneyMetrics)
    , row('fa-user', [h('strong', 'Organizer: '), e.organizer_email || 'None'])
    , row('fa-link', links)
    ])
  ])
}

