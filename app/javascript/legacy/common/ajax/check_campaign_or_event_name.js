// License: LGPL-3.0-or-later
const includes = require('lodash/includes');
var request = require('../client').default

const {
  nameAndIdNonprofitCampaignsPath,
  nameAndIdNonprofitEventsPath,
} =  require('../../../routes');

module.exports = function(name, event_or_campaign, callback) {
  const url = event_or_campaign == "event" ? 
    nameAndIdNonprofitCampaignsPath(app.nonprofit_id) :
    nameAndIdNonprofitEventsPath(app.nonprofit_id);

  request.get(url)
    .end(function(err, resp){
      var names = resp.body.map(x => x.name)
      if(includes(names, name)) {
        appl.notify(`Oops.  It looks like you already have ${event_or_campaign === 'campaign' ? 'a' : 'an'} ${event_or_campaign} named '${name}'.  Please choose a different name and try again.`)
        return
      }
      callback()
  })
}

