// License: LGPL-3.0-or-later
var flyd = require("flyd")
var h = require("virtual-dom/h")

var footer = require('./footer')

var hideStream = flyd.stream()

var name = 'hideDedication'

module.exports = {root: root, stream: hideStream}

function root(state) {
	return [
		h('header.step-header', [h('h4.step-title', 'Hide dedication (optional)')]),
		h('div.step-inner', [
			body(),
			footer.root('Next', 'thankYou')
		])
	]
}

function body() {
	var message = "If you don't want to give your donors the option to set a dedication, click the checkbox below."

	return [h('p.u-marginBottom--20', message),
		h('input.u-marginTop--10',
      {id: name + '-checkbox', type: 'checkbox', name: 'settings.' + name, onchange: hideStream}),
    h('label.u-bold', {attributes: {for: name + '-checkbox'}}, 'Hide dedication')
	]
}
