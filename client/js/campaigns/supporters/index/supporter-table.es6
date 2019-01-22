// License: LGPL-3.0-or-later
const thunk = require('vdom-thunk')
const h = require('virtual-dom/h')
const flyd = require('flyd')
const showMoreBtn = require('../../../components/show-more-button.es6')
const format = require("../../../common/format")
const date = format.date
const sql = format.sql

const root = state => {
  console.log({state})
	var supporters = state.get('supporters')
	if(state.get('loading')) {
		return h('p.noResults', ' Loading...')
	} else if(supporters.get('data').count()) {
		return h('div', [
			h('table.table--plaid', [
				h('thead', [
					h('th', 'Name'),
					h('th', 'Total'),
					h('th', 'Gift options'),
					h('th', 'Latest gift'),
					h('th', 'Campaign creator')
				]),
				thunk(trs, supporters.get('data')),
			]),
			thunk(showMoreBtn.root, state.get('moreLoading'), supporters.get('remaining'))
		])
	} else if (state.get('isSearching')) {
		return h('p.noResults', ["Supporter not found."])
	} else {
		return h('p.noResults', ["No donors yet. ", h('a', {href: './'}, 'Return to the campaign page.')])
	}
}

const trs = supporters =>
	h('tbody', supporters.map(supp => thunk(supporterRow, supp)).toJS())

const supporterRow = supporter =>
	h('tr', [
		h('td', 
      h('a'
        , {
          href: `/nonprofits/${app.nonprofit_id}/supporters?sid=${supporter.get('id')}`
        , target: '_blank' 
        }
        , [supporter.get('name')
          , h('br')
          , h('small', supporter.get('email'))
          ]
      )
    )
	, h('td', '$' + utils.cents_to_dollars(supporter.get('total_raised'))),
		h('td', supporter.get('campaign_gift_names').toJS().join(', ')),
		h('td', supporter.get('latest_gift')),
		h('td', {}, supporter.get('campaign_creator_emails').toJS().map(
		  function(i, index, array) {
		    return h('a', {href: `mailto:${i}`},
          i + ((i < (array.length - 1)) ? ", " : ""))
		  })),
	])

module.exports = {
	root: root,
	$streams: {
		showMore: showMoreBtn.$streams.nextPageClicks,
	}
}

