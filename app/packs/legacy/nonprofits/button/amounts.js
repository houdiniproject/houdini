// License: LGPL-3.0-or-later
var flyd = require("flyd")
var h = require("virtual-dom/h")

var footer = require('./footer')
var radioAndLabelWrapper = require('../../components/radio-and-label-wrapper')

var namePrefix = 'settings.amounts.'

var nameStream = flyd.stream()

module.exports = {root: root, stream: nameStream}

function root(state) {
	return [
		h('header.step-header', [h('h4.step-title', 'Amounts')]),
		body(state)
	]
}

function body(state){
	return h('div.step-inner', [
		menu(),
		singleInput(state),
		multipleInputs(state),
		footer.root('Next', 'type')
	])
}

function menu() {
	return h('section',[
		radioAndLabelWrapper('radio-multiple-amounts', namePrefix + 'name', {'checked': 'checked', 'value': 'multiple'},
			["I want donors to be able to select from ", h('strong', 'multiple'), " amounts."], nameStream),
		radioAndLabelWrapper('radio-single-amount', namePrefix + 'name', {'value': 'single'},
			["I want a ", h('strong', 'single, preset'), " amount."], nameStream),
	])
}

function input(value, key) {
	return h('span.prepend--dollar',
		h('input.input--200', {name: namePrefix + key, value: value, onchange: nameStream})
	)
}

function displayIf(state, matcher) {
	return state.settings.amounts.name === matcher ? 'block' : 'none'
}

function singleInput(state) {
	return h('div.u-marginTop--15', {style: {display: displayIf(state, 'single')}}, input(state.settings.amounts.single, 'single'))
}

function multipleInputs(state) {
	var multiples = state.settings.amounts.multiples
	var inputs = []
	for (var key in multiples) {
		inputs.push(input(multiples[key], 'multiples.' + key))
	}
	return h('section.layout--three.u-marginTop--15', {style: {display: displayIf(state, 'multiple')}}, inputs)
}
