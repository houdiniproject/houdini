// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
const geography = require('../common/geography')
const addressAutocomplete = require('./address-autocomplete-fields')
flyd.mergeall = require('flyd/module/mergeall')

// This component is just the fields without any form wrapper or submit button, which allows you to handle those pieces outside of here.

function init(state, params$) {
//window.param$ = params$; //debug, make it global
  state = state || {}
  state = R.merge({
    selectCountry$: flyd.stream()
  , supporter: R.merge({
      email: app.user ? app.user.email : undefined
    }, R.pick(['first_name', 'last_name', 'phone', 'address', 'city', 'state_code', 'zip_code'], app.profile || {}) )
  , required: {}
  }, state)
  state.addressAutocomplete = addressAutocomplete.init({data$: flyd.stream(state.supporter)}, params$)
  state.notUSA$ = flyd.mergeall([
    flyd.stream(!app.show_state_field)
  , flyd.map(select => !geography.isUSA(select.value), state.selectCountry$)
  ])
  return state
}

// Into state, pass:
// - to_ship (whether to show a "shipping address" message)
// - disallow_anonymous (nonprofit table has the 'no_anon' column)
// - autocomplete_supporter_address (nonprofit table has a corresponding column)
// - anonymous (Boolean)
// - first name
// - last name
// - phone
// - address
// - city
// - state_code
// - zip_code
// - profile_id
// - required: { (which fields to make required
//     - name
//     - email
//     - address (will make address + city + state_code + zip_code all required)
//   }
function view(state) {
  const emailTitle = I18n.t('nonprofits.donate.info.supporter.email') + `${state.required.email ? `${I18n.t('nonprofits.donate.info.supporter.email_required')}` : ''}`
  return h('div.u-marginY--10', [
    h('input', { props: { type: 'hidden' , name: 'profile_id' , value: state.supporter.profile_id } })
  , h('input', { props: { type: 'hidden' , name: 'nonprofit_id' , value: state.supporter.nonprofit_id || app.nonprofit_id } })
  , h('fieldset', [
      h('input.u-marginBottom--0', {
        props: {
          type: 'email'
          , title: emailTitle
          , name: 'email'
          , pattern: "^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)+$"
          , required: state.required.email
          , value: state.supporter.email
          , placeholder: emailTitle
        }
      })
    ])
  , h('section.group', [
      h('fieldset.u-marginBottom--0.u-floatL.col-right-4', [
        h('input', {
          props: {
            type: 'text'
          , name: 'first_name'
          , placeholder: I18n.t('nonprofits.donate.info.supporter.first_name')
          , required: state.required.first_name
          , title: I18n.t('nonprofits.donate.info.supporter.first_name')
          , value: state.supporter.first_name
          }
        })
      ])
    , h('fieldset.u-marginBottom--0.u-floatL.col-right-4', [
        h('input', {
          props: {
            type: 'text'
          , name: 'last_name'
          , placeholder: I18n.t('nonprofits.donate.info.supporter.last_name')
          , required: state.required.last_name
          , title: I18n.t('nonprofits.donate.info.supporter.last_name')
          , value: state.supporter.last_name
          }
        })
      ])
    , h('fieldset.u-marginBottom--0.u-floatL.col-right-4', [
        h('input', {
          props: {
            type: 'text'
          , name: 'phone'
          , placeholder: I18n.t('nonprofits.donate.info.supporter.phone')
          , title: I18n.t('nonprofits.donate.info.supporter.phone')
          , required: state.required.phone
          , value: state.supporter.phone
          }
        })
      ])
    ])
  , addressAutocomplete.view(state.addressAutocomplete)
  ])
}

function manualAddressFields(state) {
  state.selectCountry$ = state.selectCountry$ || flyd.stream()
  var stateOptions = R.prepend(
    h('option', {props: {value: '', disabled: true, selected: true}}, I18n.t('nonprofits.donate.info.supporter.state'))
  , R.map(
      s => h('option', {props: {selected: state.supporter.state_code === s, value: s}}, s)
    , geography.stateCodes )
  )
  var countryOptions = R.prepend(
    h('option', {props: {value: '', disabled: true, selected: true}}, I18n.t('nonprofits.donate.info.supporter.country'))
  , R.map(
      c => h('option', {props: {value: c[0]}}, c[1])
    , app.countriesList )
)
  return h('section.group.pastelBox--grey.u-padding--5', [
    state.to_ship ? h('label.u-centered.u-marginBottom--5', I18n.t('nonprofits.donate.info.supporter.shipping_address')) : ''
  , h('fieldset.col-8.u-fontSize--14', [
      h('input.u-marginBottom--0', {
        props: {
          title: 'Address'
        , placeholder: I18n.t('nonprofits.donate.info.supporter.address')
        , type: 'text'
        , name: 'address'
        , value: state.supporter.address
        }
      })
    ])
  , h('fieldset.col-right-4.u-fontSize--14', [
      h('input.u-marginBottom--0', {
        props: {
          name: 'city'
        , type: 'text'
        , placeholder: I18n.t('nonprofits.donate.info.supporter.city')
        , title: 'City'
        , value: state.supporter.city
        }
      })
    ])
  , state.notUSA$()
    ? showRegionField()
    : h('fieldset.u-marginBottom--0.u-floatL.col-4', [
        h('select.select.u-fontSize--14.u-marginBottom--0', {props: {name: 'state_code'}}, stateOptions)
      ])
  , h('fieldset.u-marginBottom--0.u-floatL.col-right-4.u-fontSize--14', [
      h('input.u-marginBottom--0', {
        props: {type: 'text', title: 'Postal code', name: 'zip_code', placeholder: I18n.t('nonprofits.donate.info.supporter.postal_code'), value: state.supporter.zip_code}
      })
    ])
  , h('fieldset.u-marginBottom--0.u-floatL.col-right-8', [
      h('select.select.u-fontSize--14.u-marginBottom--0', {
        props: { name: 'country' }
      , on: {change: ev => state.selectCountry$(ev.currentTarget)}
    }, countryOptions )
    ])
  ])
}

function showRegionField() {
  if(app.show_state_field) {
    h('input.u-marginBottom--0.u-floatL.col-4', {props: {type: 'text', title: 'Region', name: 'region', placeholder: I18n.t('nonprofits.donate.info.supporter.region'), value: state.supporter.state_code}})
  } else {
    return ""
  }
}

module.exports = {view, init}
