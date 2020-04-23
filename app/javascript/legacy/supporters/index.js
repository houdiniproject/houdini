// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('snabbdom/h')
const flyd = require('flyd')
const render = require('ff-core/render')
const request = require('../common/request')
const snabbdom = require('snabbdom')
const flyd_lift = require('flyd/module/lift')
const flyd_mergeAll = require('flyd/module/mergeall')
const url = require('url')

// TODO move this into sub-component in the future
const mailchimpModal = require('./settings/mailchimp-integration-settings')

// This is the root component for the supporters dashboard/CRM, found on /nonprofits/:nonprofit_id/supporters

function init() {
  var state = { }
  var thisUrl = url.parse(location.href, true)
  const mailchimpSyncClick$ = getMailchimpClickSync()
  const mailchimpKeyResp$ = request({method: 'get', path: `/nonprofits/${app.nonprofit_id}/nonprofit_keys`, query: {select: 'mailchimp_token'}}).load
  const hasKey$ = flyd.filter(resp => resp.status === 200, mailchimpKeyResp$)
  const modalID$ = flyd_mergeAll([
    flyd_lift(openModalOrAuth, mailchimpSyncClick$, mailchimpKeyResp$)
  , flyd.map(()=> thisUrl.query['show-modal'], hasKey$)
  ])
  state.mailchimpModal = mailchimpModal.init(modalID$)
  return state
}

// Either return the modal ID to open, or redirect the page to the mailchimp oauth screen
const openModalOrAuth = (ev, resp) => {
  if(resp.status === 200) {
    return 'mailchimpSettingsModal'
  } else {
    window.location.href = `/nonprofits/${app.nonprofit_id}/nonprofit_keys/mailchimp_login`
    return null
  }
}

const getMailchimpClickSync = () => {
  const s = flyd.stream()
  document.querySelector('.js-openMailchimpModal')
    .addEventListener('click', ev => {appl.close_modal(); s(ev)})
  return s
}


function view(state) {
  return h('div', [
    mailchimpModal.view(state.mailchimpModal)
  ])
}


// -- Render to the page

var container = document.querySelector('#js-main')
const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
var state = init()
render({patch, view, state, container})

