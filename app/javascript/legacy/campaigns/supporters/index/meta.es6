// License: LGPL-3.0-or-later
// Table meta for the supporter listing under Campaigns
const h = require('virtual-dom/h')
const thunk = require('vdom-thunk')
const search = require('../../../components/tables/search.es6')

const root = state =>
	h('div.container', [
		thunk(search.root, state),
		h('a.table-meta-button.white', {
			href: `/nonprofits/${app.nonprofit_id}/campaigns/${ENV.campaignID}/admin/donations.csv`,
			target: '_blank',
		}, [ h('i.fa.fa-file-text'), ' Export ' ]),
		/*
		h('a.table-meta-button.green', {
			onclick: $.showEmailModal
		}, [ h('i.fa.fa-envelope'), ' Email ' ])
		*/
	])

module.exports = {
	root: root,
	$streams: {
		searches: search.$streams.searches
	}
}

