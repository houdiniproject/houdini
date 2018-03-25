// License: LGPL-3.0-or-later
const request = require('../common/request')
const flyd = require('flyd')
const R = require('ramda')
var path = `/nonprofits/${app.nonprofit_id}/campaigns/${ENV.campaignID}/totals`

const resp$ = flyd.map(R.prop('body'), request({path, method: 'GET'}).load)

appl.def('loading_totals', true)

flyd.map(response => {
  appl.def('loading_totals', false)
  appl.def('campaign_totals', response)
}, resp$)

