// License: LGPL-3.0-or-later
const flyd = require("flyd")
const h = require("virtual-dom/h")

const footer = require('./footer')

const hideStream = flyd.stream()

const name = 'hideDedication'

module.exports = {root: root, stream: hideStream}

function root(_state) {
	return [
		h('header.step-header', [h('h4.step-title', 'Hide dedication (optional)')]),
		h('div.step-inner', [
			body(),
			footer.root('Next', 'thankYou')
		])
	]
}

function body() {
	const message = "If you don't want to give your donors the option to set a dedication, click the checkbox below."

	return [h('p.u-marginBottom--20', message),
		h('input.u-marginTop--10',
      {id: name + '-checkbox', type: 'checkbox', name: 'settings.' + name, onchange: hideStream}),
    h('label.u-bold', {attributes: {for: name + '-checkbox'}}, 'Hide dedication')
	]
}
