// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const flyd = require('flyd')


function init(parentState) {
  var state = {
    submit$: flyd.stream()
  , supporter$: parentState.supporter$
  , saved$: flyd.stream()
  }
  

  return state
}


function view() {
  
  return h('div', {id$: 'offsite_donation_form_modal'})
}


module.exports = {init, view}
