// License: LGPL-3.0-or-later
const R = require('ramda')
const { parseCustomFields, parseCustomAmounts, splitParam }  = require('./parseFields');

module.exports = params => {
  // Set defaults
  const merge = R.merge({ custom_amounts: '' })
  // Preprocess data
  const evolve = R.evolve({
    multiple_designations: splitParam
  , custom_amounts: parseCustomAmounts
  , custom_fields: parseCustomFields
  , tags: tags => R.map(tag => {
      return tag.trim()
    }, R.split(',', tags))
  })

  const outputParams = R.compose(evolve, merge)(params)
  if (window.app && window.app.widget && window.app.widget.custom_amounts) {
    outputParams.custom_amounts = window.app.widget.custom_amounts
  }
  return outputParams;
}
