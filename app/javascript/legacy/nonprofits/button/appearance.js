// License: LGPL-3.0-or-later
const flyd = require("flyd")
const h = require("virtual-dom/h")

const footer = require('./footer')
const radioAndLabelWrapper = require('../../components/radio-and-label-wrapper')
const donateElephantPng = require('../../../../assets/images/graphics/donate-elephant.png')
const miniAmountStepPng = require('../../../../assets/images/graphics/mini-amount-step.png')

const appearanceStream = flyd.stream()

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

const color = app.nonprofit.brand_color ? app.nonprofit.brand_color : '#42B3DF'
const font = app.nonprofit.brand_font ? app.nonprofit.brand_font : 'inherit'
const buttonStyles = {background: color, 'font-family': font}

const namePrefix = 'settings.appearance.'

function defaultButton(){
	const title = 'Default button'
	const content = [ h('p.branded-donate-button', {style: buttonStyles}, 'Donate'),
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
	const title = 'Fixed position button'
	const content = [h('p.branded-donate-button.is-fixed', {style: buttonStyles}, 'Donate')]
	return h('td', [radioAndLabelWrapper('radio-fixed',  namePrefix + 'name', {'value': 'fixed'},
		contentWrapper(title, content), appearanceStream)])
}

function embeddedButton(){
	const title = 'Embed directly on page'
	const content = [ h('img', {src: miniAmountStepPng, title: title})]
	return h('td', [radioAndLabelWrapper('radio-embedded', namePrefix + 'name', {'value': 'embedded'},
		contentWrapper(title, content), appearanceStream)])
}

function imageButton(state){
	const title = 'Custom image'
	const defaultImg = donateElephantPng
	const imgUrl = state.settings.appearance.customImg ? state.settings.appearance.customImg : defaultImg
	const content = [ h('img', {src: imgUrl, title: title}),
		h('input', {type: 'text', name: namePrefix + 'customImg', placeholder: 'Add your image URL here', onkeyup: appearanceStream})]
	return h('td', [radioAndLabelWrapper('radio-custom-image', namePrefix + 'name', {'value': 'custom image'},
		contentWrapper(title, content), appearanceStream)])
}

function customText(state) {
	const text = state.settings.appearance.customText ? state.settings.appearance.customText : 'Donate'
	const title = 'Custom text'
	const content = [
		h('a.customText-text', text),
		h('input', {type: 'text', name: namePrefix + 'customText', placeholder: 'Type here to change text', onkeyup: appearanceStream})
	]
	return h('section.customText-wrapper', [radioAndLabelWrapper('radio-custom-text',  namePrefix + 'name', {'value': 'custom text'},
		contentWrapper(title, content), appearanceStream)])
}
