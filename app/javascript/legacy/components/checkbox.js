// License: LGPL-3.0-or-later
const h = require('flimflam/h')
const uuid = require('uuid')

// example:
// checkbox({name: 'anonymous', value: 'true', label: 'Donate anonymously?'})

module.exports = obj => {
  const id = uuid.v1()
  return h('div', [ 
      h('input', {props: {type: 'checkbox', id, value: obj.value, name: obj.name}})
    , h('label', {attrs: {for: id}}, [h('span.pl-1.sub.font-weight-1', obj.label ? obj.label : obj.value)])
  ])
}

