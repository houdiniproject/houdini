// License: LGPL-3.0-or-later
const flyd = require('flyd')
const flyd_flatMap = require('flyd/module/flatmap')

// Given an object of card data, return a stream of stripe tokenization responses
module.exports = obj => {
	var $ = flyd.stream()
	Stripe.card.createToken(obj, (status, resp) => $(resp))
	return $
}

