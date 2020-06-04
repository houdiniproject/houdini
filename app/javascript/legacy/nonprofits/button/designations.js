// License: LGPL-3.0-or-later
var flyd = require("flyd")
var h = require("virtual-dom/h")

var footer = require('./footer')
var radioAndLabelWrapper = require('../../components/radio-and-label-wrapper')

var nameStream = flyd.stream()
var countStream = flyd.stream()
var inputStream = flyd.stream()


flyd.map(function(keyup){
	keyup.target.value = keyup.target.value.replace(/[&"_*`'~]/g, "")
}, inputStream)


var namePrefix = 'settings.designations.'

module.exports = {
	root: root,
	streams: {
		name:  flyd.merge(nameStream, inputStream),
		count: countStream
	}
}

function root(state) {
	return [
		h('header.step-header', h('h4.step-title', 'Designations')),
		h('div.step-inner',
			[
				body(state),
				footer.root('Next', 'amounts')
			])
		]
}

function body(state){
	var desigs = state.settings.designations
	return [menu(),
	input(desigs),
	inputs(desigs)]
}

function menu(){
	return h('aside',[
		radioAndLabelWrapper('radio-no-designations', namePrefix + 'name', {'checked': 'checked', 'value': ''},
			["I want ", h('strong', 'no'), " designation."], nameStream),
		radioAndLabelWrapper('radio-single-designations',  namePrefix + 'name', {'value': 'single'},
			["I want a ", h('strong', 'single,  preset'),  " designation."], nameStream),
		radioAndLabelWrapper('radio-multiple-designations',  namePrefix + 'name', {'value': 'multiple'},
			["I want donors to be able to select from ", h('strong', 'multiple'),  " designations (up to 20)."], nameStream),
	])
}

function input(desigs){
	return h('input.u-marginTop--15.input--400',
		{placeholder: 'Designation name', attributes: {'maxlength': 50}, name: namePrefix + 'single', style: {display: desigs.name === 'single' ? 'block' : 'none'},
			onchange: inputStream
		}
	)
}

function inputs(desigs){
	var prompt = [h('p.pastelBox--green.u-padding--10.u-marginY--10', 'If you would like to add a custom prompt to your donors, \
		please enter it below. Example: "Which radio show would you like to donate to?".  The default prompt is "Please select a designation".'),
			h('input.u-marginTop--10.input--400',
			{placeholder: 'Prompt to donors', attributes: {'maxlength': 50}, name: namePrefix + 'prompt', onkeyup: inputStream})
		]
	var inputs = []
	for(var i = 0; i < desigs.count; i++) {
		inputs.push(h('li', h('input.input--400', {attributes: {'maxlength': 50}, placeholder: 'Designation name', name: namePrefix + 'multiples.' + i, onchange: inputStream})))
	}
	return h('div', {style: {display: desigs.name === 'multiple' ? 'block' : 'none'}}, [
		prompt,
		h('p.pastelBox--blue.u-padding--10.u-marginY--10', 'Enter your designations below.'),
		h('ol',  [
			inputs,
			h('a.button--tiny.edit', {onclick: countStream, attributes: isDisabled(desigs.count)}, [h('i.fa.fa-plus'), ' Add another designation']),
		])
	])
}

function isDisabled(count){ if(count >= 20){return {'disabled' : ''}}}

