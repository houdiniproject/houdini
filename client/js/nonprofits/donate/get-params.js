// License: LGPL-3.0-or-later
const R = require('ramda')
const { parseCustomFields, parseCustomAmounts, splitParam }  = require('./parseFields');

module.exports = params => {
  // Set defaults
  const merge = (params) => ({ custom_amounts: '', ...params })
  // Preprocess data
  const evolve = R.evolve({
    multiple_designations: splitParam
  , custom_amounts: parseCustomAmounts
  , custom_fields: parseCustomFields
  , tags: tags => tags.split(',').map(tag => tag.trim())
  })

  const outputParams = evolve(merge(params))
  if (window.app && window.app.widget && window.app.widget.custom_amounts) {
    outputParams.custom_amounts = window.app.widget.custom_amounts
  }
  return outputParams;
}
