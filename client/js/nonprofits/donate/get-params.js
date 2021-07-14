// License: LGPL-3.0-or-later
const R = require('ramda')

const splitParam = str =>
  R.split(/[_;,]/, str)

module.exports = params => {
  const defaultAmts = '10,25,50,100,250,500,1000'
  // Set defaults
  const merge = R.merge({
    custom_amounts: ''
  })
  // Preprocess data
  const evolve = R.evolve({
    multiple_designations: splitParam
  , custom_amounts: amts => R.compose(R.map(Number), splitParam)(amts || defaultAmts)
  , custom_fields: fields => R.map(f => {
      const [name, label] = R.map(R.trim, R.split(':', f))
      return {name, label: label ? label : name}
    }, R.split(',',  fields))
  , tags: tags => R.map(tag => {
      return tag.trim()
    }, R.split(',', tags))
  })
  return R.compose(evolve, merge)(params)
}
