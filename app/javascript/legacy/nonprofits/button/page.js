// License: LGPL-3.0-or-later
const view = require("vvvview")
const flyd = require("flyd")
flyd.scanmerge = require("flyd/module/scanmerge")
const h = require("virtual-dom/h")

const setStateFromValue = require('../../components/set-state-from-value')

const appearance = require('./appearance')
const designations = require('./designations')
const amounts = require('./amounts')
const type = require('./type')
const hideDedication = require('./hide-dedication')
const thankYou = require('./thank-you')
const preview = require('./preview')
const utils = require('../../common/utilities').default

const {
	nonprofitsButtonSendCodePath
} = require('../../../routes')

const $footer = require('./footer').stream

const state = {
	page: window.location.hash.replace('#', '')
	? window.location.hash.replace('#', '')
	: 'appearance',
	settings: {
		appearance: {
			name: 'default',
			customText: 'Donate'
		},
		designations: {count: 1, multiples: {}},
		amounts: {
			name: 'multiple',
			single: 30,
			multiples: {0: 10, 1: 20, 2: 30, 3: 70, 4: 100, 5: 200, 6: 1000 }
		},
		type: { name: 'both'},
		thankYou: {}
	}
}

function root(state) {
	return h('div', [
		menu(state),
		pages(state)
	])
}

const $page = flyd.stream()

const $pageClick = flyd.stream()

flyd.map(function(ev){
	if(ev.target.data.page === 'preview') {
		appendScript()
	} else {
		removeScript()
	}
}, $pageClick)

$page = flyd.merge($page,
	flyd.map(function(ev) {
		return ev.target.data.page
	}, $pageClick))

function appendScript(){
	const script = document.createElement('script')
	script.id = 'commitchange-donation-script'
	script.setAttribute('data-npo-id', app.nonprofit_id)
	script.setAttribute('src', app.host_with_port + '/js/donate-button.v2.js')
	document.body.appendChild(script)
}

function removeScript(){
	if(document.getElementById('commitchange-donation-script')){
		document.getElementById('commitchange-donation-script').remove()
	}
	removeButtonContent()
}

function removeButtonContent(){
	const donateButton = document.querySelector('.commitchange-donate')
	while(donateButton.lastChild){
		donateButton.removeChild(donateButton.lastChild)
	}
}

function appendButtonCode(){
  document.getElementById('choose-role-modal').classList.add('inView')
  document.body.classList.add('is-showingModal')
	const buttonWrapper = document.getElementById('js-donateButtonWrapper').cloneNode(true)
	while(buttonWrapper.querySelector('iframe')) {
		buttonWrapper.querySelector('iframe').remove()
	}
	while(buttonWrapper.querySelector('div')){
		buttonWrapper.querySelector('div').remove()
	}
	const code = buttonWrapper.innerHTML.replace(/"/g, "'")
	document.getElementById('js-donateButtonAnchor').value = code
	document.querySelector('#send-code-modal input[name="code"]').value = code
}

function menu(state){
	const menuItems = [
	{name: 'appearance', text: 'Appearance'},
	{name: 'designations', text: 'Designations'},
	{name: 'amounts', text: 'Preset amounts'},
	{name: 'type', text: 'Preset recurring or one-time'},
  {name: 'hideDedication', text: 'Hide dedication' },
	{name: 'thankYou', text: 'Thank-you page'},
	{name: 'preview', text: 'Live preview'}]

	const lis =[]
	const button = h('div.u-paddingX-10',
  h('a.button--large.orange.u-width--full',  {onclick: appendButtonCode}, 'Finish'))

	menuItems.map(function(item) {
		const liClass = state.page === item.name ? '.active' : ''
		lis.push(h('li' + liClass, {data: {page: item.name}, onclick: $pageClick}, item.text))
	})
	return h('aside.stepsMenu', [h('ul', lis), button])
}



function pageWrapper(state, pageName, content){
	return h('section.step.' + pageName, {
		style: {display: state.page === pageName ? 'block' : 'none'}
	}, content)
}

function pages(state){
	return [
		pageWrapper(state, 'appearance', appearance.root(state)),
		pageWrapper(state, 'designations', designations.root(state)),
		pageWrapper(state, 'amounts', amounts.root(state)),
		pageWrapper(state, 'type', type.root(state)),
    pageWrapper(state, 'hideDedication', hideDedication.root(state)),
		pageWrapper(state, 'thankYou', thankYou.root(state)),
		pageWrapper(state, 'preview', preview.root(state))
	]
}

const donateFormBuilder = view(root, document.getElementById('js-donateFormBuilder'), state)

const nameStreams = [appearance.stream, designations.streams.name, amounts.stream, type.stream, hideDedication.stream, thankYou.stream]
  .map(function(stream) { return [stream, setStateFromValue]})

window.state = state

const scanPairs = [
	[$page, setPage],
	[$footer, advancePage],
	[designations.streams.count, addDesignation]
].concat(nameStreams)

const $state = flyd.immediate(flyd.scanmerge(scanPairs, state))

// rerenders the view based on state changes
// takes the view and state stream
flyd.map(donateFormBuilder, $state)

function setPage(state, pageName){
	state.page = window.location.hash = pageName
	return state
}

function addDesignation(state, ev) {
	if(state.settings.designations.count < 20) {
		state.settings.designations.count++
	}
	return state
}

function advancePage(state, ev) {
	state.page = ev.target.data.next
	return state
}


// // Send email to webmaster
$('#send-code-modal form').on('submit', function(e) {
	const self = this
	e.preventDefault()
	const data = $(this).serializeObject()
	$(this).find('button').loading('Sending...')
	$.post(nonprofitsButtonSendCodePath(app.nonprofit_id, {format: 'json'}), data)
		.done(function() {
			notification('Email sent!')
			appl.close_modal()
		})
		.complete(function() {
			$(self).find('button').disableLoading()
		})
		.fail(function(d) {
			notification('Error: ' + utils.print_error(d))
		})
})

