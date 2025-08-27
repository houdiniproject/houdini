// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const render = require('ff-core/render')
const snabbdom = require('snabbdom')

const request = require('../../common/request')
const listing = require('../listing-item')
const upperFirst = require('lodash/upperFirst');

module.exports = pathPrefix => {
  const get = param => {
    const path = `${pathPrefix}?${param}=t`
    return request({path, method: 'get'}).load
  }

  const init = _ => {
    return {
      active:      get('active')
    , past:        get('past') 
    , unpublished: get('unpublished') 
    , deleted:     get('deleted') 
    }
  }

  const listings = (key, state) => {
    const resp$ = state[key]
    const sectionForEventType = content =>
      h('section.u-marginBottom--30', [
        h('h5.u-centered.u-marginBottom--20', upperFirst(key) + ' Events')
      , h(`div.fundraiser--${key}`, content)
      ])
    if(!resp$()) 
      return sectionForEventType([h('p.u-padding--15', 'Loading...')])
    if(!resp$().body.length) 
      return sectionForEventType([h('p.u-padding--15', `No ${key} events`)])
    return sectionForEventType(resp$().body.map(listing));
  }

  const view = state => 
    h('div', [
      listings('active', state)
    , listings('past', state)
    , listings('unpublished', state)
    , listings('deleted', state)
    ])

  const container = document.querySelector('#js-eventsListing')

  const patch = snabbdom.init([
    require('snabbdom/modules/class')
  , require('snabbdom/modules/props')
  ])

  render({ patch, container , view, state: init() })
}

