// License: LGPL-3.0-or-later
var flyd = require("flyd")
var h = require("virtual-dom/h")

module.exports = {root: root}

function root(state) {
	return [
		h('header.step-header', h('h4.step-title', 'Preview')),
		h('div.step-inner', [
			body(state.settings)
		])
	]
}

function body(settings){
	if(settings.designations.name === 'multiple'){
		settings.designations.multiples = objToArray(settings.designations.multiples)
	}
	if(settings.amounts.name === 'multiple') {
		settings.amounts.multiples = objToArray(settings.amounts.multiples)
	}
	return [
		h('p.strong.u-centered', 'Below is a live preview of your donate form'),
		donateButton(settings),
		table(settings)
	]
}

function table(settings) {
	var table = h('table.table--plaid',[
		h('tr', [h('td', 'Appearance'), appearanceTd(settings.appearance)]),
		singleOrMultipleRow(settings.designations, 'Designation'),
		singleOrMultipleRow(settings.amounts, 'Amount'),
		h('tr', [h('td', 'Recurring or one-time'), h('td', settings.type.name)]),
    h('tr', [h('td', 'Hide dedication'), h('td', ifAny(settings.hideDedication ? 'true' :  h('span.u-color--grey', 'false')))]),
		h('tr', [h('td', 'Thank-you page url'), h('td', ifAny(settings.thankYou.url))]),
	])
	return table
}

function appearanceTd(data) {
	if(data.name === 'custom image') {
		return h('td', [data.name, h('p.u-color--grey', data.customImg)])
	}
	if(data.name === 'custom text') {
		return h('td', [data.name, h('p.u-color--grey', data.customText)])
	}
	return h('td', data.name)
}

function singleOrMultipleRow(obj, text) {
	if(obj.name === 'single'){
		return h('tr', [h('td', text), h('td', obj.single+='')])
	}
	if(obj.name === 'multiple'){
		return h('tr', [h('td', text + 's'), h('td', arrayToList(obj.multiples))])
	}
	return h('tr', [h('td', text), h('td', h('span.u-color--grey', 'none'))])
}

function donateButton(settings) {
	return h('div.u-centered.u-margin--20', {id: 'js-donateButtonWrapper'},
		h('a.commitchange-donate', {attributes: buttonAttributes(settings)},
			[buttonContent(settings.appearance)]
		)
	)
}

function buttonAttributes(settings) {
	var appearance = settings.appearance.name
	var attrs = {}
	if(appearance === 'custom image' || appearance === 'custom text') {
		attrs['data-custom'] = ''
	}
	if (appearance === 'fixed') {
		attrs['data-fixed'] = ''
	}
	if (appearance === 'embedded'){
		attrs['data-embedded'] = ''
	}
	if (settings.designations.name === 'single' && settings.designations.single) {
		attrs['data-designation'] = settings.designations.single
	}
	if (settings.designations.name === 'multiple' && settings.designations.multiples.length) {
		attrs['data-multiple-designations'] = arrayToStringWithSeparator(settings.designations.multiples, '_')
	}
	if (settings.designations.name === 'multiple' && settings.designations.prompt) {
		attrs['data-designations-prompt'] = settings.designations.prompt
	}
	if (settings.amounts.name === 'single' && settings.amounts.single) {
		attrs['data-amount'] = settings.amounts.single
	}
	if (settings.amounts.name === 'multiple' && settings.amounts.multiples.length) {
		attrs['data-amounts'] = arrayToStringWithSeparator(settings.amounts.multiples, ',')
	}
	if (settings.thankYou.url) {
		attrs['data-redirect'] = settings.thankYou.url
	}
	if (settings.type.name === 'one time') {
		attrs['data-type'] = 'one-time'
	}
	if (settings.type.name === 'recurring') {
		attrs['data-type'] = 'recurring'
	}
  if (settings.hideDedication) {
    attrs['data-hide-dedication'] = ''
  }
	return attrs
}


function buttonContent(data) {
	if (data.name === 'custom image') {
		return h('img', {src: data.customImg})
	}
	if (data.name === 'custom text') {
		return h('span', data.customText)
	}
}

// todo: add to helpers or make global once we move away from view-script

function arrayToStringWithSeparator(array, separator) {
	return array.reduce(function(prev, current){
		return prev + separator + current
	})
}

function camelCase(string) {
	return string.split(" ").reduce(function(prev, current){
		return prev + current.charAt(0).toUpperCase() + current.slice(1)
	})
}

function ifAny(data) {
	if(data) {
		return data
	}
	return h('span.u-color--grey', 'none')
}

function objToArray(obj) {
	var array = []
	for(var key in obj) {
		if(obj[key]) { array.push(obj[key])}
	}
	return array
}

function arrayToList(array , cssClass) {
	var cssClass = cssClass ? cssClass : '.' + 'hasBullets--grey'
	var lis = []
	array.map(function(item){
		item+=''
		if(item && item.length) {lis.push(h('li', item))}
	})
	return h('ul' + cssClass, lis)
}
