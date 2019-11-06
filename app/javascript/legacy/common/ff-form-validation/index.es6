// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
const serializeForm = require('form-serialize')
flyd.filter = require('flyd/module/filter')
flyd.mergeAll = require('flyd/module/mergeall')
flyd.keepWhen = require('flyd/module/keepwhen')
flyd.sampleOn = require('flyd/module/sampleon')
const readableProp = require('./lib/readable-prop.es6')
const emailRegex = require('./lib/email-regex.es6')
const currencyRegex = require('./lib/currency-regex.es6')

// constraints: a hash of key/vals where each key is the name of an input
// and each value is an object of validator names and arguments
//
// validators: a hash of validation names mapped to boolean functions
//
// messages: a hash of validator names and field names mapped to error messages 
//
// messages match on the most specific thing in the messages hash
// - first checks if there is an exact match on field name
// - then checks for match on validator name
//
// Given a constraint like:
// {name: {required: true}}
//
// All of the following will set an error for above, starting with most specific first:
// {name: {required: 'Please enter a valid name'}
// {name: 'Please enter your name'}
// {required: 'This is required'}


function init(state) {
  state = R.merge({
    validators: R.merge(defaultValidators, state.validators || {})
  , messages: R.merge(defaultMessages, state.messages || {})
  , focus$:  flyd.stream()
  , change$: flyd.stream()
  , submit$: flyd.stream()
  }, state || {})
  const valField = validateField(state)
  const valForm  = validateForm(state)

  const fieldErr$ = flyd.map(valField, state.change$)
  const formErr$ = flyd.map(valForm, state.submit$)
  const clearErr$ = flyd.map(ev => [ev.target.name, null], state.focus$)
  const allErrs$ = flyd.mergeAll([fieldErr$, formErr$, clearErr$])

  // Stream of all errors combined into one object
  state.errors$ = flyd.scan(R.assoc, {}, allErrs$)

  // Stream of field names and new values and whole form data
  state.nameVal$ = flyd.map(node => [node.name, node.value], state.change$)
  state.data$ = flyd.scan(R.assoc, {}, state.nameVal$)

  // Streams of errors and data on form submit
  const errorsOnSubmit$ = flyd.sampleOn(state.submit$, state.errors$)
  state.validSubmit$ = flyd.filter(R.compose(R.none, R.values), errorsOnSubmit$)
  state.validData$ = flyd.keepWhen(state.validSubmit$, state.data$)
  
  return state
}


// Pass in an array of validation functions and the event object
// Will return a pair of [name, errorMsg] (errorMsg will be null if no errors present)
const validateField = R.curry((state, node) => {
  const value = node.value
  const name = node.name
  if(!state.constraints[name]) return [name, null] // no validators for this field present

  // Find the first constraint that fails its validator 
  for(var valName in state.constraints[name]) {
    const arg = state.constraints[name][valName]
    if(!state.validators[valName]) {
      console.warn("Form validation constraint does not exist:", valName)
    } else if(!validators[valName](value, arg)) {
      const msg = getErr(messages, name, valName, arg)
      return [name, String(msg)]
    }
  }
  return [name, null] // no error found
})


// Given the messages object, the validator argument, the field name, and the validator name
// Retrieve and apply the error message function
const getErr = (messages, name, valName, arg) => {
  const err = messages[name] 
    ? messages[name][valName] || messages[name]
    : messages[valName]
  if(typeof err === 'function') return err(arg)
  else return err
}


// Retrieve errors for the entire set of form data, used on form submit events,
// using the form data saved into the state
const validateForm = R.curry((state, node) => {
  const formData = serializeForm(node, {hash: true})
  for(var fieldName in constraints) { // not using higher order .map or reduce so we can break and return early
    for(var valName in constraints[fieldName]) {
      const arg = constraints[fieldName][valName]
      if(!validators[valName]) {
        console.warn("Form validation constraint does not exist:", valName)
      } else if(!validators[valName](value, arg)) {
        const msg = getErr(messages, name, valName, arg)
        return [name, String(msg)]
      }
    }
  }
}


// -- Views

const validatedForm = R.curry((state, elm) => {
  elm.data = R.merge(elm.data, {
    on: {submit: ev => {ev.preventDefault(); state.submit$(ev.currentTarget)}}
  })
  return elm
})


// A single form field
// Data takes normal snabbdom data for the input/select/textarea (eg props, style, on)
const validatedField = R.curry((state, elm) => {
  if(!elm.data.props || !elm.data.props.name) throw new Error(`You need to provide a field name for validation (using the 'props.name' property)`)
  var err = state.errors$()[elm.data.props.name]
  var invalid = err && err.length

  elm.data = R.merge(elm.data, {
    on: {
      focus: state.focus$
    , change: ev => state.change$([ev.currentTarget, state])
    }
  , class: { invalid }
  })

  return h('div', {
    props: {className: 'ff-field' + (invalid ? ' ff-field--invalid' : ' ff-field--valid')}
  }, [
    invalid ? h('p.ff-field-errorMessage', err) : ''
  , elm
  ])
})

var defaultMessages = {
  email: 'Please enter a valid email address'
, required: 'This field is required'
, currency: 'Please enter valid currency'
, format: "This doesn't look like the right format"
, isNumber: 'This should be a number'
, max: n => `This should be less than ${n}`
, min: n => `This should be at least ${n}`
, equalTo: n => `This should be equal to ${n}`
, maxLength: n => `This should be no longer than ${n}`
, minLength: n => `This should be longer than ${n}`
, lengthEquals: n => `This should have a length of ${n}`
, includedIn: arr => `This should be one of: ${arr.join(', ')}`
}

var defaultValidators = {
  email: val => val.match(emailRegex)
, present: val => Boolean(val)
, currency: val => String(val).match(currencyRegex)
, format: (val, arg) => String(val).match(arg)
, isNumber: val => !isNaN(val)
, max: (val, n) => val <= n
, min: (val, n) => val >= n
, equalTo:  (val, n) => n === val
, maxLength: (val, n) => val.length <= n
, minLength: (val, n) => val.length >= n
, lengthEquals: (val, n) => val.length === n
, includedIn: (val, arr) => arr.indexOf(val) !== -1
}

module.exports = {init, validatedField, validatedForm}

