// License: LGPL-3.0-or-later
var request = require('../client')

module.exports = function(npo_id) {
  var campaignsPath = '/nonprofits/' + npo_id + '/campaigns/name_and_id'
  var eventsPath = '/nonprofits/' + npo_id + '/events/name_and_id'

  request.get(campaignsPath).end(function(err, resp){
    resp.body.unshift(false)
    appl.def('campaigns.data', resp.body)
  })
  request.get(eventsPath).end(function(err, resp){
    resp.body.unshift(false)
    appl.def('events.data', resp.body)
  })
}
