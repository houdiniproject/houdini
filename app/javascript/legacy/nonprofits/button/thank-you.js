// License: LGPL-3.0-or-later
var flyd = require("flyd")
var h = require("virtual-dom/h")

var footer = require('./footer')

var namePrefix = 'settings.thankYou.'

var urlStream = flyd.stream()

module.exports = {root: root, stream: urlStream}

function root(state) {
	return [
		h('header.step-header', h('h4.step-title', 'Thank-you page (optional)')),
		h('div.step-inner', [
			body(),
			footer.root('Next', 'preview')
		])
	]
}

function body() {
	var message = "You can provide a custom URL to your own thank-you page. Your donors will be directed to this page when they complete the donation. Be sure to include the 'http://' or 'https://' part of your url."

	return [h('p', message),
		h('input.u-marginTop--10', {type: 'url', placeholder: 'Type your thank-you page URL here', name: namePrefix + 'url', onchange: urlStream})
	]
}
