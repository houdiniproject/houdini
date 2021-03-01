// License: LGPL-3.0-or-later
var request = require('../common/super-agent-promise')
var format = require('../common/format')

module.exports = create_offsite_donation

function create_offsite_donation(data, ui) {
	ui.start()
  if(data.dollars) {
    data.amount = format.dollarsToCents(data.dollars)
    delete data.dollars
  }
  if(data.date) data.date = format.date.toStandard(data.date)
	return request.post('/nonprofits/' + app.nonprofit_id + '/donations/create_offsite')
		.send({donation: data}).perform()
		.then(function(resp) {
			ui.success(resp)
			return resp
		})
		.catch(function(resp) {
			ui.fail(resp)
			throw new Error(resp)
		})
}
