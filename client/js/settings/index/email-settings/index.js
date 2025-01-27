// License: LGPL-3.0-or-later
// npm
const snabbdom = require('snabbdom')
const flyd = require('flyd')
const render = require('ff-core/render')
const notification = require('ff-core/notification')
const serializeForm = require('form-serialize')
flyd.flatMap  = require('flyd/module/flatmap')
flyd.mergeAll = require('flyd/module/mergeall')

// local
const request = require('../../../common/request')
const view = require('./view')

function init() {
  var state = { submit$: flyd.stream() }

  const formObj$ = state.submit$.map((ev) => {
    const formData = serializeForm(ev.currentTarget, { hash: true, empty: true });
    return Object.keys(formData).reduce((acc, key) => {
      acc[key] = formData[key] === 'on' ? true : false;
      return acc;
    }, {});
  });

  const path = `/nonprofits/${app.nonprofit_id}/users/${app.current_user_id}/email_settings`

  const updateResp$ = flyd.flatMap(
    obj => request({ path, method: 'post' , send: {email_settings: obj} }).load
  , formObj$ )

  state.email_settings$ = flyd.map((r) => r.body, request({ method: 'get', path }).load);

  state.loading$ = flyd.mergeAll([
    flyd.map(() => true, state.submit$)
  , flyd.map(() => false, updateResp$)
  ])

  const notify$ = flyd.map(()=> 'Email notification settings updated.', updateResp$)
  state.notification = notification.init({message$: notify$})

  return state
}

module.exports = {init, view}

