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
      h('fieldset', [
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
    , h('fieldset', [
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
    , h('fieldset', [
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

module.exports = {view, init}
