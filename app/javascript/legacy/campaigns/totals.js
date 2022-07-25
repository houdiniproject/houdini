// License: LGPL-3.0-or-later
const request = require('../common/request')
const flyd = require('flyd')
const get = require('lodash/get')
var path = `/nonprofits/${app.nonprofit_id}/campaigns/${ENV.campaignID}/totals`

const resp$ = flyd.map(get(request({path, method: 'GET'}).load, 'body'))

appl.def('loading_totals', true)

flyd.map(response => {
  appl.def('loading_totals', false)
  appl.def('campaign_totals', response)
}, resp$)

