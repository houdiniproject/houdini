// License: LGPL-3.0-or-later
const R = require('ramda')
const flyd = require('flyd')
flyd.flatMap = require('flyd/module/flatmap')
const request = require('../../common/request')
const confirmation = require('../../common/confirmation')

const stream = flyd.stream()

var table = document.querySelector('.js-table')
table.addEventListener('click', ev=> {
  if(ev.target.hasAttribute('data-remove-ticket')) {
    confirmation('Are you sure you want to remove this attendee?',
      () => stream(ev.target.getAttribute('data-ticket-id'))
    )
  }
})

const pathPrefix = `/nonprofits/${app.nonprofit_id}/events/${appl.event_id}/tickets/`

const response = flyd.flatMap(
  ticketID => flyd.map(R.prop('body'), request({method: 'delete', path: pathPrefix + ticketID})).load
, stream )

// XXX remove viewscript here 
flyd.map(
  res => {
    appl.notify('Successfully removed that attendee')
    appl.tickets.index()
  }
, response )

