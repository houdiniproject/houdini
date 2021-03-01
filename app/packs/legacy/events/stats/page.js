// License: LGPL-3.0-or-later
// npm
const R = require('ramda')
const flyd = require('flyd')
const h = require('snabbdom/h')
const snabbdom = require('snabbdom')
const render = require('flimflam-render')
const filter = require('flyd/module/filter')
const flatMap = require('flyd/module/flatmap')
const every = require('flyd/module/every')

const format = require('../../common/format')
const request = require('../../common/request')

const eventsPath = `/nonprofits/${app.nonprofit_id}/events/${app.event_id}`

const makeStatsSquare = vnode => {
  const elm = vnode.elm
  const height = elm.offsetHeight
  const width = elm.offsetWidth
  height > width 
    ? elm.style.width = height + 'px' 
    : elm.style.height = width + 'px' 
}

const get = path => R.compose(
    flyd.map(x => x.body)
  , filter(x => x.status === 200) 
  )(request({method: 'get', path}).load)

// makes an ajax call on page load and then every minute
const getEveryMinute = path => flyd.merge( 
  flyd.stream({})
, flatMap(time => get(path), every(60 * 1000)))

const init = () => {
  return {
    metrics$: getEveryMinute(`${eventsPath}/metrics`)
  , activities$: getEveryMinute(`${eventsPath}/activities`)
  }
}

const activity = a => 
  h('p.stats-activity'
  , `${a.supporter_name} got ${a.quantity} ticket${a.quantity > 1 ? 's' : ''}`)

const statInner = (content, isCircle) => {
  const data = {
    hook: {postpatch: makeStatsSquare}
  , class: {'stat-inner--circular': isCircle}
  }
  return h('section.stat-inner'
  , app.nonprofit.brand_color
    ? R.merge(data, {style: {background: app.nonprofit.brand_color}})
    : data
  , content) 
}

const view = state =>
console.log('metrics', state.metrics$()) ||
  h('div', [
    h('section.stat-outer', [
      statInner([
        h('div.stat-text', [
          h('h3.stat-title', 'Raised')
        , h('h3.stat-number', ['$', format.centsToDollars(state.metrics$().total_paid || 0)])
        ])
      ])
    ])
  , h('section.stat-outer', [
      statInner([
        h('div.stat-text', [
          h('h3.stat-title', 'Attendees')
        , h('h3.stat-number', state.metrics$().total_attendees || '0')
        ])
      ], true)
    ])
  , !app.hide_activity_feed && state.activities$().length
    ? h('div.stats-activities', R.map(activity, R.take(3, state.activities$())))
    : ''
  , h('div.stats-backgroundScrim', '')
  , app.event_background_image
    ? h('div.stats-backgroundImage'
        , {style: {'background-image': `url('${app.event_background_image}')`}})
    : ''
  ])

const patch = snabbdom.init([
  require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
, require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/attributes')
])

const container = document.querySelector('#container')

render({patch, container, view, state: init()})

