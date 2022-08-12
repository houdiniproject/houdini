// License: LGPL-3.0-or-later
const flyd = require("flyd")
const h = require("virtual-dom/h")

const footerStream = flyd.stream()

function root(text, next) {
	return h('footer.step-footer', h('button.button', {data: {next: next}, onclick: footerStream}, text))
}

module.exports = {root: root, stream: footerStream}
