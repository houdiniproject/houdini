// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('flimflam/h')
const uuid = require('uuid')

// example: 
//   radios('frequency', [
//     {label: 'Monthly', checked: true} 
//   , {label: 'Quarterly'}
//   , {label: 'Yearly'}
//   ])
  
const radios = name => label => {
  if(typeof label === 'string') label = {label: label}
  const id = uuid.v1()
  return h('div', [
      h('input', {props: {type: 'radio', id, name: name, value: label.label, checked: label.checked}})
    , h('label', {attrs: {for: id}},[h('span.sub.pl-1.font-weight-1', label.label)])
  ])
}

module.exports = (name, labels) => 
  h('div.no-padding-last-child', R.map(radios(name), labels))

