// License: LGPL-3.0-or-later
const h = require('flimflam/h')

module.exports  = (name, placeholder, value) => {
return h('input.max-width-2', {
    props: {
      type: 'text'
    , name
    , placeholder
    , value
    }
  })
}
