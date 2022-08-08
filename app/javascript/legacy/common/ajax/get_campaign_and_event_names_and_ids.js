// License: LGPL-3.0-or-later
var request = require('../client').default

const {
  nameAndIdNonprofitCampaignsPath,
  nameAndIdNonprofitEventsPath,
} =  require('../../../routes');

module.exports = function(npo_id) {
  const campaignsPath = nameAndIdNonprofitCampaignsPath(npo_id)
  const eventsPath = nameAndIdNonprofitEventsPath(npo_id)

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
