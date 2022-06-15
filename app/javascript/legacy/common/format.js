// License: LGPL-3.0-or-later
const moment = require('moment')
const {pluralize} = require('../../legacy_react/src/lib/deprecated_format')
const {camelToWords, numberWithCommas} = require('../../legacy_react/src/lib/format');
var format = {}

module.exports = format

// Convert a snake-case phrase (eg. 'requested_by_customer') to a readable phrase (eg. 'Requested by customer')
format.snake_to_words = function(snake, options) {
	if(!snake) return snake
	return snake.replace(/_/g, ' ').replace(/^./, function(m) {return m.toUpperCase()})
}

format.camelToWords = camelToWords

format.dollarsToCents = function(dollars) {
	dollars = dollars.toString().replace(/[$,]/g, '')
    if(!isNaN(dollars) && dollars.match(/^-?\d+\.\d$/)) {
        // could we use toFixed instead? Probably but this is straightforward.
        dollars = dollars + "0"
    }
	if(isNaN(dollars) || !dollars.match(/^-?\d+(\.\d\d)?$/)) throw "Invalid dollar amount: " + dollars
  return Math.round(Number(dollars) * 100)
}

format.centsToDollars = function(cents, options={}) {
	if(cents === undefined) return '0'
	return format.numberWithCommas((Number(cents) / 100.0).toFixed(options.noCents ? 0 : 2).toString()).replace(/\.00$/,'')
}

format.weeklyToMonthly = function(amount) {
  if (amount === undefined) return 0;
  return Math.round(4.3 * amount);
}



format.numberWithCommas = numberWithCommas

format.percent = function(x, y) {
  if(!x || !y) return 0
  return Math.round(y / x * 100)
}

format.pluralize = pluralize

format.capitalize = function (string) {
  return string.split(' ')
    .map(function(s) { return s.charAt(0).toUpperCase() + s.slice(1) })
    .join(' ')
}

format.toSentence = function(arr) {
	if(arr.length < 2) return arr
	if(arr.length === 2) return arr[0] + ' and ' + arr[1]
	var last = arr.length - 1
	return arr.slice(0, last).join(', ') + ', and ' + arr[last]
}

function zeroPad(num, size) {
	return (num + "").padStart(size, "0")
}

format.date = {}

format.date.readableWithTime = function(str) {
  return moment(str).format("YYYY-MM-DD h:MMa")
}

format.date.toStandard = function(str) {
  return moment(str).format("YYYY-MM-DD")
}

format.date.toSimple = function(str) {
	if(!str || !str.length) return ''
	var d = new Date(str)
	return zeroPad(d.getMonth() + 1, 2) + '/' +
		zeroPad(d.getDate(), 2) + '/' +
		zeroPad(d.getFullYear(), 2)
}

format.geography = {}

format.geography.isUS = function(str) {
  return Boolean(str.match(/(^united states( of america)?$)|(^u\.?s\.?a?\.?$)/i))
}
