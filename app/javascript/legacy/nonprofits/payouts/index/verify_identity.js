// License: LGPL-3.0-or-later
var request = require('../../../common/super-agent-promise')
var format_err = require('../../../common/format_response_error').default

module.exports = verify_identity

function verify_identity(form_obj) {
	appl.def("identity_verification", {loading: true, error: ""})
	return request.put("/nonprofits/" + app.nonprofit_id + "/verify_identity")
		.send({legal_entity: form_obj}).perform()
		.then(function(resp) {
			appl.def("identity_verification.loading", false)
			appl.notify("Thank you! Your identity verification form was successfully saved.")
			appl.close_modal()
			appl.reload()
			return resp
		})
		.catch(function(resp) {
			appl.def("identity_verification", {
				loading: false,
				error: format_err(resp)
			})
		})
}
