// License: LGPL-3.0-or-later
const request = require('../client')

module.exports = function(name, event_or_campaign, callback) {
  request.get(`/nonprofits/${app.nonprofit_id}/${event_or_campaign}s/name_and_id`)
    .end(function(err, resp){
      var names = resp.body.map(x => x.name)
      if(names.includes(name)) {
        appl.notify(`Oops.  It looks like you already have ${event_or_campaign === 'campaign' ? 'a' : 'an'} ${event_or_campaign} named '${name}'.  Please choose a different name and try again.`)
        return
      }
      callback()
  })
}

