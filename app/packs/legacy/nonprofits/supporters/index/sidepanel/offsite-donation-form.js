// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('snabbdom/h')
const flyd = require('flyd')
const modal = require('ff-core/modal')
const button = require('ff-core/button')
const format = require('../../../../common/format')
const moment = require('moment')
const request = require('../../../../common/request')
const serialize = require('form-serialize')

const flyd_flatMap = require('flyd/module/flatmap')
const flyd_mergeAll = require('flyd/module/mergeall')

function init(parentState) {
  var state = {
    submit$: flyd.stream()
  , supporter$: parentState.supporter$
  , saved$: flyd.stream()
  }
  

  return state
}


function view(state) {
  
  return h('div', {id$: 'offsite_donation_form_modal'})
}


module.exports = {init, view}
