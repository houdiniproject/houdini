// License: LGPL-3.0-or-later
var R = require('ramda')
var request = require('../client').default
const campaign = require('../../../routes/nonprofits/campaigns').default;
const event = require('../../../routes/nonprofits/events').default;

module.exports = function(name, event_or_campaign, callback) {
  const url = event_or_campaign == "event" ? 
    campaign.nameAndIdNonprofitCampaigns(app.nonprofit_id) :
    event.nameAndIdNonprofitEvents(app.nonprofit_id);

  request.get(url)
    .end(function(err, resp){
      var names = resp.body.map(x => x.name)
      if(R.contains(name, names)) {
        appl.notify(`Oops.  It looks like you already have ${event_or_campaign === 'campaign' ? 'a' : 'an'} ${event_or_campaign} named '${name}'.  Please choose a different name and try again.`)
        return
      }
      callback()
  })
}

