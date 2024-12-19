// License: LGPL-3.0-or-later
const h = require('snabbdom/h')

const geo = require('../common/geography')
const stateCodes = geo.stateCodes


// Generate a drop
//
// options are
// {
//   default: val // default value to be selected among the options
// , name: str // name attribute of the select
// }

function view(options) {
  var stateOptions = stateCodes.map((s) => h('option', { props: { value: s, selected: options.default === s } }, s));
  return h('select', {props: {name: options.name }}, stateOptions)
}

module.exports = view
