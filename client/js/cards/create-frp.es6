// License: LGPL-3.0-or-later
const flyd = require('flyd')

// Given an object of card data, return a stream of stripe tokenization responses
module.exports = (cardObject, cardholderName) => {
	var $ = flyd.stream()
	stripeV3.createToken(cardObject, {name:cardholderName}).then(resp => $(resp))
	return $
}

