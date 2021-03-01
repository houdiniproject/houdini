// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
const request = require('../../../common/request')
const flyd_lift = require('flyd/module/lift')
const colors = require('../../../common/colors')

function init() {
  var state = {
    clickSync$: flyd.stream()
  , mailchimpKeyResp$: request({method: 'get', path: `/nonprofits/${app.nonprofit_id}/nonprofit_keys`, query: {select: 'mailchimp_token'}}).load
  }
  state.mailchimpKey$ = flyd.map(R.prop('response'), flyd.filter(resp => resp.status === 200, state.mailchimpKeyResp$))
  return state
}


function view(state) {
  return h('section.integrations.settings-pane.nonprofit-settings', {
    style: {display: 'none'}
  }, [
    h('header.pane-header', [h('h3', 'Integrations')])
  , h('p', 'Connect your CommitChange account with other apps to take advantage of integration features.')
  , integrationSection(state, state.mailchimpKey$(), 'MailChimp', mailchimpConnectedMessage, mailchimpNotConnectedMessage)
  , h('br')
  ])
}

// A section fo each integration; pass in the API key for the integration, the
// name, and two functions for bodies: the first body function for when the API
// key is defined, the second body function for when the API key is undefined
const integrationSection = (state, key, name, bodyConnected, bodyNotConnected) => {
  return h('div.pane-inner.integrations', [
    h('h6', {
      style: {color: key ? colors['$bluegrass'] : colors['$grey']}
    }, [
      key ? h('i.fa.fa-check') : h('i.fa.fa-question-circle')
    , ' ' + name
    ])
  , key ? bodyConnected(state) : bodyNotConnected(state)
  ])
}

const mailchimpNotConnectedMessage = state => {
  return h('p', [
    'Connect with MailChimp to automatically sync supporter emails to your MailChimp Email Lists.'
  , h('br')
  , h('a', {props: {href: `/nonprofits/${app.nonprofit_id}/nonprofit_keys/mailchimp_login`}}, 'Click here to connect your Mailchimp account.')
  ])
}
const mailchimpConnectedMessage = state => {
  return h('p', [
    'Congrats! You Mailchimp account has been connected successfully.'
  , h('br')
  , h('a', {props: {href: `/nonprofits/${app.nonprofit_id}/supporters?show-modal=mailchimpSettingsModal`}}, 'Click here to manage your email list sync settings.')
  ])
}

module.exports = {view, init}
