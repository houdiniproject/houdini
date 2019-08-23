// License: LGPL-3.0-or-later
var request = require('../../common/client')
var R = require('ramda')

appl.def('discounts.url', '/nonprofits/' + app.nonprofit_id + '/events/' + appl.event_id + '/event_discounts')

appl.def('discounts.index', function(){
  request.get(appl.discounts.url).end(function(err, resp) {
    appl.def('discounts.data', resp.body || [])
  })
})

appl.discounts.index()



if(app.current_event_editor) {
    require('./manage')
}

