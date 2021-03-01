// License: LGPL-3.0-or-later
var flyd = require("flyd")
var h = require("virtual-dom/h")

var footerStream = flyd.stream()

function root(text, next) {
	return h('footer.step-footer', h('button.button', {data: {next: next}, onclick: footerStream}, text))
}

module.exports = {root: root, stream: footerStream}
