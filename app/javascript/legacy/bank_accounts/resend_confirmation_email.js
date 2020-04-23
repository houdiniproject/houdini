// License: LGPL-3.0-or-later
var request = require('../common/super-agent-frp')

var a = document.querySelector(".js-event-resendBankConfirmEmail")

if(a) a.addEventListener('click', resendBankConfirmation)

function resendBankConfirmation() {
	request.post('/nonprofits/' + app.nonprofit_id + '/bank_account/resend_confirmation').perform()
	appl.open_modal('bankConfirmResendModal')
}
