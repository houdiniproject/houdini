// License: LGPL-3.0-or-later
const R = require('ramda')

// Reference: https://en.wikipedia.org/wiki/Luhn_algorithm

module.exports = val => {
  val = val.replace(/[-\s]/g, '')
  return val.match(/^[0-9-\s]+$/) && luhnCheck(val)
}

const luhnCheck =
  R.compose(
    R.equals(0)
  , R.modulo(R.__, 10)
  , R.sum
  , R.map(n => n > 9 ? n - 9 : n) // Subtract 9 from those digits greater than 9
  , R.addIndex(R.map)((n, i) => i % 2 === 0 ? n : n * 2) // Double the value of every second digit
  , R.map(ch => Number(ch))
  , R.reverse)

/*
Luhn check in haskell:
luhn = (0 ==) . (`mod` 10) . sum . map (uncurry (+) . (`divMod` 10)) .
       zipWith (*) (cycle [1,2]) . map digitToInt . reverse
*/
