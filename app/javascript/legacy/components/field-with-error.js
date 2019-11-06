// License: LGPL-3.0-or-later
const h = require('flimflam/h')
const R = require('ramda')
const validatedForm = require('flimflam/ui/validated-form')

module.exports = R.curryN(2, (formState, field) => {
  const key = R.path(['data','props','name'], field)
  const validatedField = validatedForm.field(formState, field)
  const err = formState.errors$()[key]
  return h('div', {
    attrs: {'data-ff-field': err ? 'invalid' : 'valid', 'data-ff-field-error': err || ''}
  }, [ validatedField ])
})

