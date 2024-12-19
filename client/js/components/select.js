// License: LGPL-3.0-or-later
const h = require('flimflam/h')

// example:
//  select({
//     name: 'contact'
//   , options: ['email', 'SMS', 'phone']
//   , placeholder: 'How would you like to be contacted'
//   , selected:  'email' 
//   })

const option = selected => o => 
  h('option', {props: {value: o, selected: selected && selected === o}}, o)

module.exports = obj => 
  h('select', {props: {name: obj.name}}
  , [
      ...[h('option', {props: {disabled: 'true', selected: obj.selected === undefined}}, obj.placeholder || 'Select One')]
    , ...obj.options.map(option(obj.selected))
  ] 
  )

