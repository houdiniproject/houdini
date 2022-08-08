// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const snabbdom = require('snabbdom')
const R = require('ramda')
const flyd = require('flyd')
const render = require('ff-core/render')
flyd.flatMap = require('flyd/module/flatmap')
const validatedForm = require('ff-core/validated-form')
const modal = require('ff-core/modal')
const button = require('ff-core/button')
const notification = require('ff-core/notification')
// local
const request = require('../../../common/request')
const geography = require('../../../common/geography').default
const stateSelect = require('../../../components/state-selector')


// Form validation config for the normal info form
var messages = {
  address: {state: 'Please enter a US state.'}
, business_tax_id: 'This should be 9 digits.'
}
var constraints = {
  dob: {
    day: { required: true , isNumber: true , min: 1 , max: 31 }
  , month: { required: true , isNumber: true , min: 1 , max: 12 }
  , day: { required: true , isNumber: true , min: 1900 , max: 2000 }
  }
, first_name: {required: true}
, last_name: {required: true}
, address: {
    city: {required: true}
  , state: {required: true, includedIn: geography.stateCodes}
  , line1:        {required: true}
  , postal_code:  {required: true}
  }
, business_tax_id: {required: true, format: /\d\d[- ]?\d\d\d\d\d\d\d/}
, ssn_last_4: {required: true, lenghtEquals: 4}
, phone_number: {required: true, format: /^\(?\d\d\d\)?[- ]*\d\d\d[- ]*\d\d\d\d$/}
}

// Form validation config for the escalated form
var constraints_escalated = {
  personal_id_number: {required: true, format: /\d\d\d[- ]?\d\d[- ]?\d\d\d\d/}
}
var messages_escalated = {
  personal_id_number: {format: 'This should be 9 digits'}
}


function init() {
  var state = {
    regularForm: validatedForm.init({constraints, messages})
  , escalatedForm: validatedForm.init({constraints: constraints_escalated, messages: messages_escalated})
  , nonprofit: app.nonprofit
  , modalID$: flyd.stream()
  , error$: flyd.stream()
  }

  const submitSuccess$ = flyd.merge(state.regularForm.validData$, state.escalatedForm.validData$)
  const submitPath = `/nonprofits/${app.nonprofit_id}/verify_identity`
  const resp$ = flyd.flatMap(
    data => flyd.map(R.prop('body'), request({method: 'put', path: submitPath, send: {legal_entity: data}}).load)
  , submitSuccess$ )
  flyd.map(()=> location.reload(), resp$)
  const message$ = flyd.map(() => 'Successfully submitted! Reloading...', resp$)
  state.notification = notification.init({message$})

  state.loading$ = flyd.mergeAll([
    flyd.map(()=> true, submitSuccess$)
  , flyd.map(()=> false, resp$)
  ])

  const status = app.nonprofit.verification_status
  var n = document.querySelector('.js-openVerificationModal')
  if(n) n.addEventListener('click', ev => status === 'escalated' ? state.modalID$('escalatedDialogModal') : state.modalID$('identityVerificationModal'))

  return state
}


const view = state => {
  return h('div.verification', [
    normalDialog(state)
  , escalatedDialog(state)
  , formModal(state)
  , escalatedForm(state)
  , notification.view(state.notification)
  ])
}


const normalDialog = state => {
  var body = h('div.modal-body', [
    h('p', 'Please complete this form to verify your identity. This information serves as an extra security measure to prevent fraud and is required by our payment processor to comply with KYC ("Know Your Customer") laws in the US.')
  , h('p', 'All information submitted through this form is 256-bit SSL encrypted and is kept completely private.')
  , h('p', "This information can be entered by any 'account representative' at your organization; someone from your organization who is an administrator of your CommitChange account.")
  , h('hr')
  , h('button.button--large', { on: {click: [state.modalID$, 'verificationFormModal']} }, ["Let's do it ", h('i.fa.fa-arrow-right')])
  ])

  return modal({
    thisID: 'identityVerificationModal'
  , id$: state.modalID$
  , title: h('h4', 'Account Identity Verification')
  , body
  })
}


const formModal = state => {
  return modal({
    thisID: 'verificationFormModal'
  , id$: state.modalID$
  , title: 'Account Verification Form'
  , body: formView(state)
  })
}


const escalatedDialog = state => {
  var body = h('div', [
    h('p', `Our payment processor has requested the full social security number for the account holder. This usually happens when the given name or DOB does not exactly match the record in the social security database.`)
  , h('p', `Entering the full social security number will almost always get your account verified.`)
  , h('p', `Alternatively, you can re-enter the information on the basic form to either fix your information or use a different person at your org.`)
  , h('hr')
  , h('div.u-centered', [
      h('div', [ h('a.button', {on: {click: [state.modalID$, 'escalatedFormModal']}}, 'Enter full SSN') ])
    , h('p', 'or...')
    , h('div', [ h('a.button', {on: {click: [state.modalID$, 'verificationFormModal']}}, 'Retry the basic form to correct any mistakes')])
    ])
  ])

  return modal({
    thisID: 'escalatedDialogModal'
  , id$: state.modalID$
  , title: 'Further Verification Needed'
  , body
  })
}


const escalatedForm = state => {
  var valForm = validatedForm.form(state.escalatedForm)
  var field = validatedForm.field(state.escalatedForm)
  
  var body = valForm(h('form', {on: {submit: state.submit$}}, [
    h('label', [h('i.fa.fa-lock'), ' Full Social Security Number'])
  , field(h('input', {props: {name: 'personal_id_number', type: 'text', placeholder: '9-digit number'}}))
  , button({loading$: state.loading$, error$: state.error$})
  ]))

  return modal({
    thisID: 'escalatedFormModal'
  , id$: state.modalID$
  , className: 'modal--flush'
  , title: 'Identity Verification'
  , body
  })
}


const formView = state => {
  var field = validatedForm.field(state.regularForm)
  var np = state.nonprofit
  var formEl = h('form', {on: {submit: state.submit$}}, [
    h('p', [h('strong', 'Org Name: '), np.name])
  , h('div', [
      h('fieldset', {style: {display: 'inline-block', width: '48%', marginRight: '10px'}}, [
        h('label', 'Org Address')
      , field(h('input', { style: {width: '95%'}, props: { type: 'text', name: 'address[line1]', value: np.address } }))
      ])
    , h('fieldset', {style: {display: 'inline-block', width: '48%', marginRight: '10px'}}, [
        h('label', 'City')
      , field(h('input', { props: { type: 'text', name: 'address[city]', value: np.city } }))
      ])
    ])

  , h('div', [
      h('fieldset', {style: {display: 'inline-block', width: '48%', marginRight: '10px'}}, [
        h('label', 'State')
      , field(stateSelect({default: np.state_code, name: 'address[state]', value: np.state_code}))
      ])
    , h('fieldset', {style: {display: 'inline-block', width: '48%', marginRight: '10px'}}, [
        h('label', 'Postal Code')
      , field(h('input', { props: { type: 'text', name: 'address[postal_code]', value: np.zip_code } }))
      ])
    ])

  , h('div', [
      h('fieldset', {style: {display: 'inline-block', width: '48%', marginRight: '10px'}}, [
        h('label', 'Org Phone')
      , field(h('input', {props: {type: 'text', name: 'phone_number', value: np.phone}}))
      ])
    , h('fieldset', {style: {display: 'inline-block', width: '48%'}}, [
        h('label', 'Organization EIN')
      , field(h('input', { props: { name: 'business_tax_id', value: np.ein } }))
      ])
    ])

  , h('hr')
  , h('h6', 'Account Holder Info')

  , h('div', [
      h('fieldset.col-6', [
        h('label', 'First Name')
      , field(h('input', {style: {width: '95%'}, props: {type: 'text', name: 'first_name'}}))
      ])
    , h('fieldset.col-right-6', [
        h('label', 'Last Name')
      , field(h('input', {props: {type: 'text', name: 'last_name'}}))
      ])
    ])

  , h('div', [
      dobField(state)
    , h('fieldset.col-right-6', [
        h('label', 'Last 4 of Social Security Number')
      , field(h('input', {props: {type: 'text', name: 'ssn_last_4'}}))
      ])
    ])

  , h('hr')
  , h('p.finePrint.u-centered', [
      'CommitChange processes payments using Stripe. By clicking "Submit" below, you agree to '
    , h('a', {props: {target: '_blank', href: 'https://stripe.com/connect/account-terms'}}, "Stripe's  Connected Account Agreement.")
    ])

  , h('hr')
  , h('div.u-centered', [ button({loading$: state.loading$, error$: state.error$}) ])
  ])

  return validatedForm.form(state.regularForm, formEl)
}


// Generate a select element with a set of vals for options, a name attr, and a default option that has a null val
const selector = R.curry((name, vals, defaultOption) => 
  h('select', {props: {name: name}},
    R.prepend(
      h('option', {props: {value: null, selected: true}}, defaultOption)
    , R.map(n => h('option', {props: {value: n}}, n), vals)
    )
  )
)


const dobField = R.curry(state => {
  var field = validatedForm.field(state.regularForm)
  var fieldStyle = {width: '30%', display: 'inline-block'} 
  return h('fieldset.col-6', [
    h('label', 'Date of Birth')
  , h('div', {style: R.merge(fieldStyle, {width: '28%'})}, [
      field(selector('dob[day]', R.range(1,32), 'Day'))
    ])
  , h('strong', '/')
  , h('div', {style: R.merge(fieldStyle, {width: '32%'})}, [
      field(selector('dob[month]', R.range(1, 13), 'Month'))
    ])
  , h('strong', '/')
  , h('div', {style: fieldStyle}, [
      field(selector('dob[year]', R.range(1900, 2000), 'Year'))
    ])
  ])
})


// -- Render
var container = document.querySelector('.js-flimflam-verification')
const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
render({state: init(), container, view, patch})

