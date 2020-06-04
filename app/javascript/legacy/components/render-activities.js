// License: LGPL-3.0-or-later
const snabbdom = require('snabbdom')
const render = require('ff-core/render')
const activities = require('./public-activities')

module.exports = (type, path) => {
  const init = _ => activities.init(type, path)

  const view = state => activities.view(state)

  const patch = snabbdom.init([
    require('snabbdom/modules/class')
  , require('snabbdom/modules/props')
  , require('snabbdom/modules/style')
  ])
  render({state: init(), view, patch, container: document.querySelector('#js-activities')})
}

