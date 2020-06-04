// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
const button = require('ff-core/button')
const serializeForm = require('form-serialize')
flyd.scanMerge = require('flyd/module/scanmerge')
flyd.flatMap = require('flyd/module/flatmap')
flyd.filter = require('flyd/module/filter')
flyd.mergeAll = require('flyd/module/mergeall')
const request = require('../common/request')

// pass in your existing supporter data to prefill the form
// pass in your url endpoint for supporter updates
// pass in some default data for your update payload
function init(state) {
  state = state || {}
  state = R.merge({
    submit$: flyd.stream()
  , supporter$: flyd.stream(state.supporter || {})
  , error$: flyd.stream()
  }, state)

  state.updated$ = flyd.map(
    ev => {
      ev.preventDefault()
      return serializeForm(ev.target, {hash: true})
    }
  , state.submit$ )

  state.supporter$ = flyd.merge(state.updated$, flyd.stream(state.supporter))

  state.response$ = flyd.flatMap(
    supporter => flyd.map(R.prop('body'), request({
      method: 'put'
    , path: state.path || `/nonprofits/${app.nonprofit_id}/supporters`
    , send: R.merge({supporter}, state.payload || {})
    }).load)
  , state.updated$ )

  state.loading$ = flyd.mergeAll([
    flyd.map(R.always(true), state.submit$)
  , flyd.map(R.always(false), state.response$)
  ])

  return state
}

// things you need in state:
// - a supporter object with name, address, city, state_code, country, zip_code
// - the $submitAddressUpdate stream
function view(state) {
  var supporter = state.supporter
  return h('form', { on: {submit: state.submit$}}, [
    h('div.layout--three.u-marginBottom--10', [
      h('span', [
        h('label', 'Name')
      , h('input', {props: {name: 'name', placeholder: 'name', value: supporter.name}})
      ])
    , h('span', [
        h('label', 'Street Address')
      , h('input', {props: {name: 'address', placeholder: 'address', value: supporter.address}})
      ])
    , h('span', [
        h('label', 'City')
      , h('input', {props: {name: 'city', placeholder: 'city', value:  supporter.city}})
      ])
  , ])
  , h('div.layout--three.u-marginBottom--15', [
      h('span', [
        h('label', 'State/Region')
      , h('input', {props: {name: 'state_code', placeholder: 'state/region', value: supporter.state_code}})
      ])
    , h('span', [
        h('label', 'Postal Code')
      , h('input', {props: {name: 'zip_code', placeholder: 'postal code', value: supporter.zip_code}})
      ])
    , h('span', [
        h('label', 'Country')
      , h('input', {props: {name: 'country', placeholder: 'country', value: supporter.country}})
      ])
    ])
  , h('input', {props: {type: 'hidden', name: 'id', value: supporter.id}})
  , button(R.pick(['loading$', 'error$'], state))
  ])
}

module.exports = {view, init}
