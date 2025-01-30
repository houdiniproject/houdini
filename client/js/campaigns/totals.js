// License: LGPL-3.0-or-later
const request = require('../common/request')
const flyd = require('flyd')
var path = `/nonprofits/${app.nonprofit_id}/campaigns/${ENV.campaignID}/totals`

const resp$ = flyd.map(r => r.body, request({path, method: 'GET'}).load)

appl.def('loading_totals', true)

flyd.map(response => {
  appl.def('loading_totals', false)
  appl.def('campaign_totals', response)
}, resp$)

