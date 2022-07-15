// License: LGPL-3.0-or-later
require('../../campaigns/new/wizard')
require('../../events/new/wizard')
require('./tour')
appl.verify_identity = require('../payouts/index/verify_identity')
appl.create_bank_account = require('../../bank_accounts/create.js')
var client = require('../../common/client').default

const {dashboardTodosNonprofitPath} = require('../../../routes')
require('../payments_chart')

appl.def('loading', true)

client.get('/nonprofits/' + app.nonprofit_id + '/dashboard_metrics')
  .end(function(err, resp) {
    appl.def('loading', false)
    appl.def('metrics.data', resp.body.data)
  })

const todos = require('../../components/todos').default
appl.def('todos_action', dashboardTodosNonprofitPath(app.nonprofit_id))

todos(function(data, url) {
	appl.def('todos.items', [
		{text: "Collect first donation", done: data['has_donation'], link: url + '/button/basic' },
		{text: "Create first campaign", done: data['has_campaign'], modal_id: 'newCampaign', confirmed: true },
		{text: "Connect bank account", done: data['has_bank'], modal_id: 'newBankModal' },
		{text: "Create first event", done: data['has_event'], modal_id: 'newEvent', confirmed: true },
		{text: "Add a custom Thank You note for receipts", done: data['has_thank_you'],  link: "/settings?p=receipts&s=settings-pane" },
		{text: "Import supporter data", done: data['has_imported'], link: url + '/supporters' },
		{text: "Brand fundraising tools", done: data['has_branding'], link: '/settings?p=branding&s=settings-pane' }
	])
	if(data['has_bank']){
		appl.todos.items.push({text: "Verify your identity", done: data['is_verified'],  modal_id:'identityVerificationModal', confirmed: true})
		appl.def('todos.items', appl.todos.items)
	}
})

// the only ff component so far on this page is events listings
const R = require('ramda')
const h = require('snabbdom/h')
const flyd = require('flyd')
const render = require('ff-core/render')

const request = require('../../common/request')
const listing = require('../../events/listing-item')

const init = _ => {
  var path = `/nonprofits/${app.nonprofit_id}/events/listings?active=t`
  return {resp$: request({path, method: 'get'}).load}
}

const view = state => {
  const mixin = content => h('section', content)
  if(!state.resp$()) 
    return mixin([h('p.u-padding--15.u-centered', 'Loading...')])
  if(!state.resp$().body.length) 
    return mixin([h('p.u-padding--15.u-centered', `None currently`)])
  return mixin(R.map(listing, state.resp$().body))
}

var container = document.querySelector('#js-eventsListing')

const patch = require('snabbdom').init([
  require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/style')
, require('snabbdom/modules/attributes')
])

render({ patch, container , view, state: init() })


// End-of-year report modal initialization and rendering
// XXX we should FLIMFLAMify the whole dashboard and make it a single tree with one render statement
const reportModal = require('../reports/modal')
const reportContainer = document.createElement('div')
document.body.appendChild(reportContainer)
render({state: reportModal.init(), view: reportModal.view, container: reportContainer, patch})
