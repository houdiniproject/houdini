// License: LGPL-3.0-or-later
const flyd = require('flyd')
const h = require('snabbdom/h')
const R = require('ramda')
flyd.lift = require('flyd/module/lift')



function init(state, params$) {
  state = state||{}
  state = R.merge({
    isManual$: flyd.stream(false)
  , data$: flyd.stream(app.profile ? R.pick(['address', 'city', 'state_code', 'zip_code'], app.profile) : {})
  , autocompleteInputInserted$: flyd.stream()
  }, state)

  state.isManual$ = flyd.stream(true)
  state.params$ = params$
  return state
}

function calculateToShip(state)
{
    return state.params$().gift_option && state.params$().gift_option.to_ship
}

function view(state) {
  return h('section.pastelBox--grey clearfix', [
    calculateToShip(state)
    ? h('label.u-centered.u-marginBottom--5', [
        'Shipping address (required)'
      ])
    : ''
  , manualFields(state)
  ])
}

const manualFields = state => {
  return h('div', [
    h('fieldset.col-8.u-fontSize--14', [
      h('input.u-marginBottom--10', {props: {
        type: 'text'
      , title: 'Street Addresss'
      , name: 'address'
      , placeholder: 'Street Address'
      , value: state.data$().address
          , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ])
  , h('fieldset.col-right-4.u-fontSize--15', [
      h('input.u-marginBottom--10', {props: {
        type: 'text'
      , name: 'city'
      , title: 'City'
      , placeholder: 'City'
      , value: state.data$().city
          , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ])
  , h('fieldset.u-marginBottom--0.u-floatL.col-4', [
      h('input.u-marginBottom--0', {props: {
        type: 'text'
      , name: 'state_code'
      , title: 'State/Region'
      , placeholder: 'State/Region'
      , value: state.data$().state_code
          , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ])
  , h('fieldset.u-marginBottom--0.u-floatL.col-right-4.u-fontSize--14', [
      h('input.u-marginBottom--0', {props: {
        type: 'text'
      , title: 'Zip/Postal'
      , name: 'zip_code'
      , placeholder: 'Zip/Postal'
      , value: state.data$().zip_code
      , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ])
  , h('fieldset.u-marginBottom--0.u-floatL.col-right-4', [
      h('input.u-marginBottom--0', {props: {
        type: 'text'
      , title: 'Country'
      , name: 'country'
      , placeholder: 'Country'
      , value: state.data$().country
      , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ])
  ])
}


module.exports = {init, view}


