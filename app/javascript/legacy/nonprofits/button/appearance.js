// License: LGPL-3.0-or-later
var flyd = require("flyd")
var h = require("virtual-dom/h")

var footer = require('./footer')
var radioAndLabelWrapper = require('../../components/radio-and-label-wrapper')

var appearanceStream = flyd.stream()

module.exports = {
	root: root,
	stream: appearanceStream
}

function root(state) {
	return [
		h('header.step-header', [
			h('h4.step-title', 'Appearance'),
			h('p', 'How would you like to accept donations?')
		]),
		h('div.step-inner', [
				table(state),
				customText(state),
				footer.root('Next', 'designations')
		])
	]
}

function table(state) {
	return h('table', [
		h('tr', [defaultButton(), fixedButton()]),
		h('tr', [embeddedButton(), imageButton(state)])
	])
}

function contentWrapper(title, content) {
	return [title, h('div.u-paddingTop--15', content)]
}

var color = app.nonprofit.brand_color ? app.nonprofit.brand_color : '#42B3DF'
var font = app.nonprofit.brand_font ? app.nonprofit.brand_font : 'inherit'
var buttonStyles = {background: color, 'font-family': font}

var namePrefix = 'settings.appearance.'

function defaultButton(){
	var title = 'Default button'
	var content = [ h('p.branded-donate-button', {style: buttonStyles}, 'Donate'),
			brandedButtonMessage()]
	function brandedButtonMessage(){
		if(app.nonprofit.brand_color){return}
		return h('p.u-paddingTop--15',
			h('small', "To customize the color and font of your button, \
				head over to your settings page and click on 'branding'")
		)
	}
	return h('td', [radioAndLabelWrapper('radio-default', namePrefix + 'name', {'value': 'default', 'checked': 'checked'},
		contentWrapper(title, content), appearanceStream)])
}

function fixedButton(){
	var title = 'Fixed position button'
	var content = [h('p.branded-donate-button.is-fixed', {style: buttonStyles}, 'Donate')]
	return h('td', [radioAndLabelWrapper('radio-fixed',  namePrefix + 'name', {'value': 'fixed'},
		contentWrapper(title, content), appearanceStream)])
}

function embeddedButton(){
	var title = 'Embed directly on page'
	var content = [ h('img', {src: app.asset_path + "/graphics/mini-amount-step.png", title: title})]
	return h('td', [radioAndLabelWrapper('radio-embedded', namePrefix + 'name', {'value': 'embedded'},
		contentWrapper(title, content), appearanceStream)])
}

function imageButton(state){
	var title = 'Custom image'
	var defaultImg = app.asset_path + "/graphics/donate-elephant.png"
	var imgUrl = state.settings.appearance.customImg ? state.settings.appearance.customImg : defaultImg
	var content = [ h('img', {src: imgUrl, title: title}),
		h('input', {type: 'text', name: namePrefix + 'customImg', placeholder: 'Add your image URL here', onkeyup: appearanceStream})]
	return h('td', [radioAndLabelWrapper('radio-custom-image', namePrefix + 'name', {'value': 'custom image'},
		contentWrapper(title, content), appearanceStream)])
}

function customText(state) {
	var text = state.settings.appearance.customText ? state.settings.appearance.customText : 'Donate'
	var title = 'Custom text'
	var content = [
		h('a.customText-text', text),
		h('input', {type: 'text', name: namePrefix + 'customText', placeholder: 'Type here to change text', onkeyup: appearanceStream})
	]
	return h('section.customText-wrapper', [radioAndLabelWrapper('radio-custom-text',  namePrefix + 'name', {'value': 'custom text'},
		contentWrapper(title, content), appearanceStream)])
}
