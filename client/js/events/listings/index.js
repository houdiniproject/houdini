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
    const sectionForEventType = (content, count) =>
      h('section.u-marginBottom--20.u-marginTop--30', [
        h('h4.u-marginBottom--0.u-paddingX--20', `${count} ${upperFirst(key)} Events`)
      , h(`div`, content)
      ])

    if(!resp$())
      return sectionForEventType([h(`p.u-padding--15.fundraiser--${key}`, 'Loading...')], 0)

    const numberElems = resp$().body.length
    if(!numberElems)
      return sectionForEventType([h(`p.u-padding--15.fundraiser--${key}`, `No ${key} events`)], 0)

    return sectionForEventType(resp$().body.map(item => listing(item, key)), numberElems);
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

