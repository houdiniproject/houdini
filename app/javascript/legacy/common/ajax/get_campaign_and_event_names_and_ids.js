// License: LGPL-3.0-or-later
var request = require('../client').default

const campaign = require('../../../routes/nonprofits/campaigns').default
const events = require('../../../routes/nonprofits/events').default

module.exports = function(npo_id) {
  const campaignsPath = campaign.nameAndIdNonprofitCampaigns.path(npo_id)
  const eventsPath = events.nameAndIdNonprofitEvents.path(npo_id)

  request.get(campaignsPath).end(function(err, resp){
    var dataResponse = []

    if (!err) {
      resp.body.unshift(false)
      dataResponse = resp.body.map((i) => {
        if (i.isChildCampaign)
        {
          return {id: i.id, name: i.name + " - " + i.creator}
        }
        else
        {
          return {id: i.id, name: i.name}
        }
      })
    }
    appl.def('campaigns.data', dataResponse)
  })

  request.get(eventsPath).end(function(err, resp){
    var dataResponse = []
    if(!err) {
      resp.body.unshift(false)
      dataResponse = resp.body
    }

    appl.def('events.data', dataResponse)
  })
}
