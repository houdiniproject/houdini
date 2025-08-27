// License: LGPL-3.0-or-later
const flyd = require('flyd')
const h = require('snabbdom/h')

const request = require('../common/request')
const {formatResp} = require('./public-activities-base');

// type can be 'campaign' or 'event'
const init = (type, path) => {
  const resp$ = request({method: 'get', path}).load 
  const formattedResp$ = flyd.map(formatResp[type], resp$)
  return {formattedResp$}
}


/**
 * 
 * @param {{name: string, action?:string, date:string}} data 
 * @returns 
 */
const activities = data => {
    return h('tr', [
        h('td.u-padding--10.u-fontSize--13', [h('strong', data.name),  data.action? h('div.u-marginTop--3', data.action) : ''])
      , h('td.u-textAlign--right.u-fontSize--12.strong.u-paddingRight--10', [h('small', data.date)])
    ])
}

const view = state => {
  if(app.hide_activities) return ''
  const recentActivitiesSection = content =>
    h('section.pastelBox--grey', [h('header', 'Recent Activity'), content])
  if (!state.formattedResp$())
    return recentActivitiesSection(h('div.u-padding--15.u-centered.u-color--grey', 'Loading...'))
  if (!state.formattedResp$().length)
    return recentActivitiesSection(h('div.u-padding--15.u-centered.u-color--grey', 'None yet'))
  return recentActivitiesSection(h('table.u-margin--0.table--striped', [
      h('tbody', state.formattedResp$().map(activities))
    ]))
}

module.exports = {init, view}

