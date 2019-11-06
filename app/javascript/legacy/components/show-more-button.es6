// License: LGPL-3.0-or-later
/*
A 'Show More' button component, useful for placing at the bottom of a listing of ajax'd data.

the showMore button's state uses the following properties:

moreLoading: boolean (you might want general "loading" and a separate "moreLoading" states)
remaining: integer (count of how many results are not shown and still left. If 0, the show more button hides)
*/


const view = require('vvvview')
const h = require("virtual-dom/h")
const flyd = require('flyd')

var $ = {
	nextPageClicks: flyd.stream()
}

const root = (moreLoading, remaining) => {
	var buttonContent = moreLoading
		? h('span', [h('i.fa.fa-spin.fa-spinner'), ' Loading... '])
		: h('span', ' Show More ')

	return h('div.moreResults.group', {style: {display: remaining ? 'block' : 'none'}}, [
		h('button.button--micro.details', {disabled: moreLoading, onclick: $.nextPageClicks}, [
			buttonContent,
		]),
		' ',
		h('a.button--micro.details', {href: '#'}, 'Back to Top')
	])
}

module.exports = {root: root, $streams: $}

