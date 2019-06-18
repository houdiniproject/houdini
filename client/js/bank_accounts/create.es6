// License: LGPL-3.0-or-later
var request = require('../common/super-agent-promise')
var format_err = require('../common/format_response_error')

module.exports = create_bank_account

function create_bank_account(form_data, el) {
    return new Promise((resolve, reject) =>{
        appl.def('new_bank_account', {loading: true, error: ''})
        return confirm_auth(form_data)
            .then(tokenize_with_stripe)
            .then(create_record)
            .then(complete)
            .catch(display_err)
    })
}


// Post to confirm user's password
function confirm_auth(form_data) {

    return request.post('/users/confirm_auth').send({password: form_data.user_password})
        .perform()
        .then((resp) =>{ return {token: resp.body.token, form: form_data}})


}


// Post to stripe to get back a stripe_bank_account_token
function tokenize_with_stripe(data) {
    return new Promise(function(resolve, reject) {
        stripeV3.createToken('bank_account', data.form).then((resp) => {
            data.stripe_resp = resp
            if(resp.error) reject(resp.error.message)
            else resolve(data)
        })
    })
}


// 'data' must have a stripe response as '.stripe_resp' and a user password confirmation token as '.token
function create_record(data) {
    return request.post('/nonprofits/' + app.nonprofit_id + '/bank_account')
        .send({
            pw_token: data.token,
            bank_account: {
                stripe_bank_account_token: data.stripe_resp.token.id,
                stripe_bank_account_id: data.stripe_resp.token.bank_account.id,
                name: data.stripe_resp.token.bank_account.bank_name + ' *' + data.stripe_resp.token.bank_account.last4,
                email: app.user.email
            }
        })
        .perform()
}

function complete() {
    appl.is_loading()
    appl.reload()
}

function display_err(resp) {

    var error_message = null;

    if (typeof resp == 'string')
        error_message = resp
    else
        error_message = format_err(resp)

    appl.def('new_bank_account', {error: error_message, loading: false})
}



