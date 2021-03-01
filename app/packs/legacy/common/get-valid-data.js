// License: LGPL-3.0-or-later
const flyd = require('flimflam/flyd')
const request = require("../common/request")

module.exports = (path, query) => {
  const url = '/'
  const response$ = request({method: 'GET', url, path, query}).load
  const valid$ = flyd.filter(x => x.status === 200, response$)
  return flyd.map(x => x.body, valid$)
}

