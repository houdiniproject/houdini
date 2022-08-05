// License: LGPL-3.0-or-later
var flyd = require("flyd")
var h = require("virtual-dom/h")
var footer = require('./footer')
var radioAndLabelWrapper = require('../../components/radio-and-label-wrapper')
const recurringSvg = require('../../../../assets/images/graphics/recurring.svg')
const oneTimeSvg = require('../../../../assets/images/graphics/one-time.svg')

var namePrefix = 'settings.type.'

var nameStream = flyd.stream()

module.exports = {root: root, stream: nameStream}

function root() {
	return [
		h('header.step-header', [h('h4.step-title', 'Recurring or One-Time')]),
		body()
	]
}

function body(){
	return h('div.step-inner', [
		menu(),
		footer.root('Next', 'hideDedication')
	])
}

function menu() {
	var recurringImg = h('img', {src: recurringSvg})
	var oneTimeImg = h('img', {src: oneTimeSvg})
	var message = "We highly recommend that you accept recurring donations whenever possible. They are a great source of recurring revenue!"

	return h('section',[
		h('p', message),
		radioAndLabelWrapper('radio-type-both', namePrefix + 'name', {'checked': 'checked', 'value': 'both'},
			["Recurring ", h('strong', 'and'), " one time.", recurringImg, oneTimeImg], nameStream),
		radioAndLabelWrapper('radio-type-oneTime', namePrefix + 'name', {'value': 'one time'},
			[h('strong', 'Only '), " one time.", oneTimeImg], nameStream),
		radioAndLabelWrapper('radio-type-recurring', namePrefix + 'name', {'value': 'recurring'},
			[h('strong', 'Only '), " recurring.", recurringImg], nameStream),
	])
}
