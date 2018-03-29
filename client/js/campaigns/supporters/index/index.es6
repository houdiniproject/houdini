// License: LGPL-3.0-or-later
const request = require('../../../common/super-agent-frp')
const view = require('vvvview')
const flyd = require('flyd')
const scanMerge = require('flyd/module/scanmerge')
const flatMap = require('flyd/module/flatmap')
const Im = require('immutable')
const Map = Im.Map
const fromJS = Im.fromJS

const list = require('./supporter-list.es6')

var el = document.querySelector('.js-view-supporters')
var state = Map({loading: true})
var listView = view(list.root, el, state)

// Given a query object, return an ajax stream
const request_index = query =>
	request
		.get(`/nonprofits/${app.nonprofit_id}/campaigns/${ENV.campaignID}/admin/supporters`)
		.query(query)
		.perform()

var $searchResponses = flatMap(request_index, list.$streams.searches)

const appendPage = (state, resp) => {
	var oldSupporters = state.getIn(['supporters', 'data'])
	var newData = fromJS(resp.body)
	if(oldSupporters) newData = newData.set('data', oldSupporters.concat(newData.get('data')))
	return state
		.set('supporters', newData)
		.set('moreLoading', false)
		.set('loading', false)
}

const $showMorePages = flyd.scan(
	count => count + 1
	, 1
	, list.$streams.showMore)

const $newPages = flatMap(
	  page => request_index({page: page})
	, $showMorePages)

const setResults = (state, resp) =>
	state.set('supporters', fromJS(resp.body)).set('loading', false)

var $giftLevelResponses =
	request.get(`/nonprofits/${app.nonprofit_id}/campaigns/${ENV.campaignID}/admin/campaign_gift_options`).perform()

var $state = flyd.immediate(scanMerge([
	[list.$streams.searches, state => state.set('loading', true).set('isSearching', true)],
	[list.$streams.showMore, state => state.set('moreLoading', true).set('page', state.get('page') + 1)],
	[$newPages, appendPage],
	[$searchResponses, setResults],
	[$giftLevelResponses, (state, resp) => state.set('gift_levels', fromJS(resp.body))],
], state))

window.$state =$state
window.$giftLevelResponses= $giftLevelResponses

flyd.map(listView, $state)

