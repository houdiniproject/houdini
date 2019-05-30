// License: LGPL-3.0-or-later
// based on: https://github.com/stripe/jquery.payment/blob/master/lib/jquery.payment.js
import _ = require("lodash");
export const defaultFormat = /(\d{1,4})/g;

export function luhnCheck(num: string | number):boolean {
  var digit, digits, odd, sum, _i, _len;
  odd = true;
  sum = 0;
  digits = (num + '').split('').reverse();
  for (_i = 0, _len = digits.length; _i < _len; _i++) {
    digit = digits[_i];
    digit = parseInt(digit, 10);
    if ((odd = !odd)) {
      digit *= 2;
    }
    if (digit > 9) {
      digit -= 9;
    }
    sum += digit;
  }
  return sum % 10 === 0;
}

export function cardExpiryVal(value:any): {month:number, year: number} {
  var [month, year] = value.split(/[\s\/]+/, 2)

  // Allow for year shortcut
  if (year && year.length == 2 && /^\d+$/.test(year)){
    const prefix = (new Date()).getFullYear()
    const prefixStr = prefix.toString().substr(0,2)
    year   = prefixStr + year
  }

  month = parseInt(month, 10)
  year  = parseInt(year, 10)

  return {month: month, year: year}
}


export const validateCardExpiry = (month:any, year:any):boolean  => {
  if (typeof month === 'object' && 'month' in month ){
    var {month, year} = month
  }

  if (!(month && year)) {
    return false
  }
  

  month = _.trim(month)
  year  = _.trim(year)

  if (!/^\d+$/.test(month))
    return false
  
  if(!/^\d+$/.test(year))
    return false;
 
  if (!(1 <= month && month <= 12))
    return false;
  

  if (year.length == 2)
    if (year < 70)
      year = `20${year}`
    else
      year = `19${year}`

  if (!(year.length == 4))
    return false
  

  var expiry      = new Date(year, month)
  var currentTime = new Date()

  // Months start from 0 in JavaScript
  expiry.setMonth(expiry.getMonth() - 1)

  // # The cc expires at the end of the month,
  // # so we need to make the expiry the first day
  // # of the month after
  expiry.setMonth(expiry.getMonth() + 1, 1)

  return expiry > currentTime
}

interface Card {
  type: string,
  patterns: number[],
  format: RegExp,
  length: number[],
  cvcLength: number[],
  luhn: boolean
}

interface ValidateCardExpiry {
  (date: { month: string | number, year: string | number }): boolean
  (month: string | number, year: string | number): boolean
}


export class CreditCardTypeManager {
  cards: Card[] = [
    {
      type: 'maestro',
      patterns: [5018, 502, 503, 506, 56, 58, 639, 6220, 67],
      format: defaultFormat,
      length: [12, 13, 14, 15, 16, 17, 18, 19],
      cvcLength: [3],
      luhn: true
    }, {
      type: 'forbrugsforeningen',
      patterns: [600],
      format: defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    }, {
      type: 'dankort',
      patterns: [5019],
      format: defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    }, {
      type: 'visa',
      patterns: [4],
      format: defaultFormat,
      length: [13, 16],
      cvcLength: [3],
      luhn: true
    }, {
      type: 'mastercard',
      patterns: [51, 52, 53, 54, 55, 22, 23, 24, 25, 26, 27],
      format: defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    }, {
      type: 'amex',
      patterns: [34, 37],
      format: /(\d{1,4})(\d{1,6})?(\d{1,5})?/,
      length: [15],
      cvcLength: [3, 4],
      luhn: true
    }, {
      type: 'dinersclub',
      patterns: [30, 36, 38, 39],
      format: /(\d{1,4})(\d{1,6})?(\d{1,4})?/,
      length: [14],
      cvcLength: [3],
      luhn: true
    }, {
      type: 'discover',
      patterns: [60, 64, 65, 622],
      format: defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    }, {
      type: 'unionpay',
      patterns: [62, 88],
      format: defaultFormat,
      length: [16, 17, 18, 19],
      cvcLength: [3],
      luhn: false
    }, {
      type: 'jcb',
      patterns: [35],
      format: defaultFormat,
      length: [16],
      cvcLength: [3],
      luhn: true
    }
  ];

  cardFromType(type: string) {
    return _.find(this.cards, (card) => card.type === type)
  }

  cardFromNumber(num: string):Card {
    num = (num + '').replace(/\D/g, '')
    return _.find(this.cards, (card:Card) => {
      return card.patterns.some((pattern) => {
        const p = pattern + ''
        return num.substr(0, p.length) == p
      })
    })
  }
  
  validateCardNumber(num: any) {
    num = (num + '').replace(/\s+|-/g, '')
    if (!/^\d+$/.test(num)){
      return false 
    }
  
    const card = this.cardFromNumber(num)
    if (!card)
      return false
    
    if (card.length.some(i => i === num.length) && (card.luhn == false || luhnCheck(num))) {
      return card.type
    }
  }

  validateCardCVC(cvc: string, type?: string) {
    cvc = _.trim(cvc)
    if (!/^\d+$/.test(cvc))
      return false
  

    var card = this.cardFromType(type)
    if (card) {
      //check against specific card
      return card.cvcLength.some((i) => i === cvc.length)
    }
    else {
      // Check against all types
      return cvc.length >= 3 && cvc.length <= 4
    }
  }

  validateCardExpiry:ValidateCardExpiry = validateCardExpiry as any

  cardExpiryVal = cardExpiryVal

  cardType(num: string) {
    if (!num)
      return null;
    const card = this.cardFromNumber(num)
    if (card && card.type)
      return card.type
    else
      return null
  }
}