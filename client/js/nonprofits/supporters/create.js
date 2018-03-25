// License: LGPL-3.0-or-later
var request = require('../../common/super-agent-promise')

module.exports = create_supporter

function create_supporter(form_obj, ui) {
	ui.start()
	return request.post('/nonprofits/' + app.nonprofit_id + '/supporters')
		.send(form_obj).perform()
		.then(function(resp) {
			ui.success(resp)
			return resp
		})
		.catch(function(resp) {
			ui.fail(show_err(resp))
		})
}
