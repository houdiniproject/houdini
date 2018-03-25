// License: LGPL-3.0-or-later
const R = require('ramda')

module.exports = (classes='') => R.reduce(
  (a, b) => {a[b] = true; return a}
  , {}
  , R.drop(1, classes.split('.')))

