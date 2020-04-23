// License: LGPL-3.0-or-later
const h = require('flimflam/h')
const classObject = require('../common/class-object')

module.exports  = (name, placeholder, value, classes) => {
return h('input.max-width-2', {
    props: {
      type: 'text'
    , name
    , placeholder
    , value
    }
  , class: classObject(classes)
  })
}
