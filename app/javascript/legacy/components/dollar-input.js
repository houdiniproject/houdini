// License: LGPL-3.0-or-later
const h = require('flimflam/h')

module.exports  = (name, placeholder, value) => {
return h('input.dollar-input.max-width-2', {
    props: {
      type: 'number'
    , step: 'any'
    , min: 0
    , name
    , placeholder
    , value
    }
  })
}
