// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const soldOut = require('./is-sold-out')

module.exports = gift => {
  if(gift.hide_contributions || !gift.quantity) return ''
  
  if(soldOut(gift)) {
    return h('p', [
      h('small.strong.highlight--white--small', 'SOLD OUT')
    ])
  } else {
    return h('p', [
      h('small.strong.highlight--white--small', [ `${gift.quantity - gift.total_gifts} Left` ])
    ])
  }
}

