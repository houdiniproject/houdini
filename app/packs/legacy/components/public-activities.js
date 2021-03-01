// License: LGPL-3.0-or-later
const flyd = require('flyd')
const h = require('snabbdom/h')
const R = require('ramda')
const moment = require('moment')
const request = require('../common/request')

// type can be 'campaign' or 'event'
const init = (type, path) => {
  const resp$ = request({method: 'get', path}).load 
  const formattedResp$ = flyd.map(formatResp[type], resp$)
  return {formattedResp$}
}

const ago = date => moment(date).fromNow()
const formatRecurring = o => o.recurring 
      ? `made a recurring contribution of`
      : `contributed`

const formatCampaign = r => 
  R.map(o => {
    return {
      name: o.supporter_name 
    , action: formatRecurring(o) + ' ' + o.amount
    , date: ago(o.date)
    }
  }, r.body)

const formatEvent = r => 
  R.map(o => {
    return {
      name: o.supporter_name 
    , action: `got ${o.quantity} ticket${o.quantity > 1 ? 's' : ''}` 
    , date: ago(o.created_at)
    }
  }, r.body)

const formatResp = {
  campaign: formatCampaign 
, event: formatEvent
}

const activities = data => {
    return h('tr', [
        h('td.u-padding--10.u-fontSize--13', [h('strong', data.name),  data.action? h('div.u-marginTop--3', data.action) : ''])
      , h('td.u-textAlign--right.u-fontSize--12.strong.u-paddingRight--10', [h('small', data.date)])
    ])
}

const view = state => {
  if(app.hide_activities) return ''
  const mixin = content =>
    h('section.pastelBox--grey', [h('header', 'Recent Activity'), content])
  if (!state.formattedResp$())
    return mixin(h('div.u-padding--15.u-centered.u-color--grey', 'Loading...'))
  if (!state.formattedResp$().length)
    return mixin(h('div.u-padding--15.u-centered.u-color--grey', 'None yet'))
  return mixin(h('table.u-margin--0.table--striped', [
      h('tbody', R.map(activities, state.formattedResp$()))
    ]))
}

module.exports = {init, view}

