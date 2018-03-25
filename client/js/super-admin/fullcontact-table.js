// License: LGPL-3.0-or-later
const h = require('flimflam/h')
const searchTable = require('../components/search-table')

const row = (data) => {
  const results = JSON.stringify(data, null, 2) 
  return  h('pre', results) 
}

module.exports = state => searchTable(state, [], row, 'Search by email')

