// License: LGPL-3.0-or-later
const snabbdom = require('snabbdom')
const flyd = require('flyd')
const h = require('snabbdom/h')
const R = require('ramda')
const modal = require('ff-core/modal')
const render = require('ff-core/render')
const request = require('../../../common/request')

function init() {
  var state = {}
  state.modalID$ = flyd.stream()
  state.data$ = flyd.map(R.prop('body'), request({
    path: `/nonprofits/${app.nonprofit_id}/recurring_donation_stats`
  , method: 'get'
  }).load)

  document
    .querySelector('.js-openStatsModal')
    .addEventListener('click', ev => state.modalID$('statsModal'))

  return state
}

function view(state) {
  if(!state.data$()) return h('div')

  var body = h('table.table', [
    h('tbody', [
      h('tr', [
        h('td', [h('strong', 'Active')])
      , h('td', `${state.data$().active_count} Donations`)
      , h('td', `${state.data$().active_sum} Total`)
      ])
    , h('tr', [
        h('td', [h('strong', 'Average Amount')])
      , h('td', `${state.data$().average} per month`)
      , h('td', '')
      ])
    , h('tr', [
        h('td', [h('strong', 'Cancelled')])
      , h('td', `${state.data$().cancelled_count} Donations`)
      , h('td', `${state.data$().cancelled_sum} Total`)
      ])
    , h('tr', [
        h('td', [h('strong', 'Charge Failures')])
      , h('td', `${state.data$().failed_count} Donations`)
      , h('td', `${state.data$().failed_sum} Total`)
      ])
    ])
  ])

  return h('div', [
    modal({
      title: h('h4', 'Recurring Donations')
    , id$: state.modalID$
    , thisID: 'statsModal'
    , body
    })
  ])
}


// -- Render
const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
var container = document.querySelector('.js-flimflamContainer')
var state = init()
render({patch, view, container, state})

