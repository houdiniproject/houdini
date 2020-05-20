// License: LGPL-3.0-or-later
const h = require('virtual-dom/h')
const thunk = require('vdom-thunk')
const formToObj = require('../../common/form-to-object')
const flyd = require('flyd')
const filterStream = require('flyd/module/filter')

// Uses an immutable state object with 'page' and 'search' keys
// Will also use a 'loading' key for loading animations
// Optionally pass in a 'placeholder' key for the placeholder text

// Searches are streams of objects like {page: 1, search: 'xxyy'}

// Whenever they blank out the search field, immediately re-request
var $searchKeyups = flyd.stream()
var $clearOuts = flyd.map(
	() => ({page: 1, search: ''}),
	filterStream(
		ev => !ev.target.value.length, // all blank values
		$searchKeyups))

// Search form submissions
var $searchSubmits = flyd.stream()
flyd.on(ev => ev.preventDefault(), $searchSubmits)
var $searches = flyd.merge(
	$clearOuts,
	flyd.map(
		ev => formToObj(ev.target),
		$searchSubmits))


const root = state =>
	h('form.table-meta-search', {
		onsubmit: $searchSubmits
	}, [
		h('input', {type: 'hidden', name: 'page', value: 1}),
		h('input', {
			type: 'text',
			name: 'search',
			placeholder: state.get('placeholder') || 'Search',
			value: state.get('search'),
			onkeyup: $searchKeyups,
		}),
		h('button.button--input', {type: 'submit', disabled: state.get('loading')}, [
			h('i.fa.fa-search', {style: {display: state.get('loading') ? 'none' : ''}}),
			h('i.fa.fa-spin.fa-spinner', {style: {display: state.get('loading') ? '' : 'none'}})
		])
	])

module.exports = {root: root, $streams: {searches: $searches}}

