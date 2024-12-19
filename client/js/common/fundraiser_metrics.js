// License: LGPL-3.0-or-later
const clamp = require('lodash/clamp');
const format = require('../common/format')
require('../common/restful_resource')

appl.def('ajax_metrics', {
	index: function() {
		appl.ajax.index('metrics').then(function(resp) {
       appl.def('metrics.percentage_funded',  clamp(format.percent(
          resp.body.goal_amount
        , resp.body.total_raised
          ), 1,100)
        )
		})
	}
})
