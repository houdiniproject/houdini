// License: LGPL-3.0-or-later
const jQuery = require ('jquery')

/**
 * A wrapper for replicating Stripe.js v2's tokenizing features
 * with a compatible API. It allows a service provider to use fully free software
 * for Stripe integration. Whether that meets your needs is up to you :)
 *
 * To use it set the `payment_provider.stripe_proprietary_v2_js` to `false`
 * (which is the default in settings)
 */
class Stripe {

    setPublishableKey(key) {
   
      this.card = new TokenizerWrapper( 'card', key)
      this.bankAccount = new TokenizerWrapper('bank_account',key)
    }
}

class TokenizerWrapper {
    constructor( inner_field_name, key)
    {
        this.inner_field_name = inner_field_name
        this.key = key
    }

    createToken(outer_obj, callback) {
        var self = this
        var auth = 'Bearer '+ self.key
        

        var inner_field_name = self.inner_field_name

        var obj = {}

        obj[inner_field_name] = outer_obj

        jQuery.ajax('https://api.stripe.com/v1/tokens', {
            headers: {
                'Authorization': auth,
                'Accept': 'application/json',
                'Content-Type': 'application/x-www-form-urlencoded'},
            method: 'POST',
            data: obj
        }).done((data, textStatus, jqXHR) => {
            callback(jqXHR.status, data)
        }).fail((jqXHR, textStatus, errorThrown) => {
            callback(jqXHR.status, jqXHR.responseJSON)
        })
    }
}

global.Stripe = new Stripe()