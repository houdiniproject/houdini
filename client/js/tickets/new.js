// License: LGPL-3.0-or-later
var path = '/nonprofits/' + app.nonprofit_id + '/events/' + appl.event_id + '/ticket_levels'
var indexTicketLevels = require('../ticket_levels/manage')
var formSerialize = require('form-serialize')
var request = require('../common/super-agent-promise')

require('../components/wizard')
require('./wizard')

appl.def('show_new_tickets', function(){
    // indexes ticket levels before showing the new ticket modal
    // so that ticket level quantites are up-to-date.
    // indexTicketLevels takes the path and a callback
    indexTicketLevels(path, show_new_modal)
})

appl.def('add_ticket_note', function(n) {
  var data = formSerialize(appl.prev_elem(n), {hash: true})
  appl.def('loading', true)
  request.put('/nonprofits/' + app.nonprofit_id + '/events/' + app.event_id + '/tickets/' + appl.created_ticket_id + '/add_note')
    .send({ticket: data})
    .perform()
    .then(function(resp) {
      appl.def('loading', false)
      appl.close_modal()
    })
})

function show_new_modal(){
  appl.open_modal('newTicketModal')
}

