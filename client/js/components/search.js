// License: LGPL-3.0-or-later
const h = require('flimflam/h')
const input = require('./text-input')

module.exports = (loading, placeholder='Search') =>
  h('div.table', [
    h('div.middle-cell', [ input('', placeholder) ])
  , h('div.middle-cell.pl-1', [ h('button', {attrs: {disabled: loading}},'Search') ])
  ])

