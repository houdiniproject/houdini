// License: LGPL-3.0-or-later
const flyd = require('flyd')
const h = require('snabbdom/h')
const pick = require('lodash/pick')
const autocomplete = require('./address-autocomplete')
flyd.filter = require('flyd/module/filter')
flyd.lift = require('flyd/module/lift')

autocomplete.initScript()

function init(state, params$) {
  state = state||{}
  state = {
    isManual$: flyd.stream(!app.autocomplete)
  , data$: flyd.stream(app.profile ? pick(app.profile, ['address', 'city', 'state_code', 'zip_code']) : {})
  , autocompleteInputInserted$: flyd.stream()
  , ...state
  }

  const loaded$ = flyd.filter(
    i => i
  , flyd.lift((x, input) => input, autocomplete.loaded$, state.autocompleteInputInserted$) )
  
  state.autoData$ = flyd.flatMap(
    input => autocomplete.initInput(input)
  , loaded$ )

  state.data$ = flyd.merge(state.data$, state.autoData$)
  state.isManual$ = flyd.merge(state.isManual$, flyd.map(()=> true, state.autoData$))
  state.params$ = params$
  return state
}

function calculateToShip(state)
{
    return state.params$().gift_option && state.params$().gift_option.to_ship
}

function view(state) {
  return h('section.address', [
    calculateToShip(state)
    ? h('label.u-centered.u-marginBottom--5', [
        'Shipping address (required)'
      ])
    : ''
  , state.isManual$() ? manualFields(state) : autoField(state)
  ])
}

const autoField = state => {
  return h('div', [
    h('fieldset.u-marginBottom--5', [
      h('input.u-margin--0.js-autocompleteAddress', {
        props: {type: 'text', placeholder: 'Search for your address'}
      , hook: {insert: vnode => state.autocompleteInputInserted$(vnode.elm)}
      })
    ])
  , h('p.u-margin--0.u-centered', [
      h('a', {on: {click: [state.isManual$, true]}}, [h('small', 'Enter your address manually')])
    ])
  ])
}

const manualFields = state => {
  return h('div.manual-address-fields', [
    h('fieldset.u-fontSize--14', [
      h('input.u-marginBottom--0', {props: {
        type: 'text'
      , title: 'Street Addresss'
      , name: 'address'
      , placeholder: 'Street Address'
      , value: state.data$().address
          , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ])
  , h('fieldset.u-fontSize--15', [
      h('input.u-marginBottom--0', {props: {
        type: 'text'
      , name: 'city'
      , title: 'City'
      , placeholder: 'City'
      , value: state.data$().city
          , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ])
  , h('fieldset.u-marginBottom--0', [
      h('input.u-marginBottom--0', {props: {
        type: 'text'
      , name: 'state_code'
      , title: 'State/Region'
      , placeholder: 'State/Region'
      , value: state.data$().state_code
          , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ])
  , h('fieldset.u-marginBottom--0.u-fontSize--14', [
      h('input.u-marginBottom--0', {props: {
        type: 'text'
      , title: 'Zip/Postal'
      , name: 'zip_code'
      , placeholder: 'Zip/Postal'
      , value: state.data$().zip_code
      , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ])
  , h('fieldset.u-marginBottom--0', [
      h('input.u-marginBottom--0', {props: {
        type: 'text'
      , title: 'Country'
      , name: 'country'
      , placeholder: 'Country'
      , value: state.data$().country
      , required: calculateToShip(state) ? state.params$().gift_option.to_ship : undefined
      }})
    ]), h('p.u-margin--0.search-link', { style: { display: !!app.autocomplete ? 'block' : 'none' } }, [
      h('a', {on: {click: [state.isManual$, false]}}, [h('small', 'Search for your address')])
    ])
  ])
}


module.exports = {init, view}


