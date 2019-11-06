// License: LGPL-3.0-or-later
const R = require('ramda')
const format = require('../common/format')
require('../common/restful_resource')

appl.def('ajax_metrics', {
	index: function() {
		appl.ajax.index('metrics').then(function(resp) {
       appl.def('metrics.percentage_funded',  R.clamp(1,100, format.percent(
          resp.body.goal_amount
        , resp.body.total_raised
          ))
        )
		})
	}
})
