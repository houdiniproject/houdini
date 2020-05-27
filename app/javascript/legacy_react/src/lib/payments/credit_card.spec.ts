// License: LGPL-3.0-or-later
// based on https://github.com/stripe/jquery.payment/blob/master/test/specs.coffee
import { CreditCardTypeManager, defaultFormat } from './credit_card'
import 'jest';
import _ = require('lodash');

describe('CreditCardTypeManager', () => {
  let cc: CreditCardTypeManager
  beforeEach(() => {
    cc = new CreditCardTypeManager()
  })

  describe('Validating a card number', () => {
    it('should fail if empty', () => {
      const topic = cc.validateCardNumber('')
      expect(topic).toBeFalsy()

    })
    it('should fail if is a bunch of spaces', () => {
      const topic = cc.validateCardNumber('                 ')
      expect(topic).toBeFalsy()

    })
    it('should success if is valid', () => {
      const topic = cc.validateCardNumber('4242424242424242')
      expect(topic).toBeTruthy()

    })
    it('that has dashes in it but is valid', () => {
      const topic = cc.validateCardNumber('4242-4242-4242-4242')
      expect(topic).toBeTruthy()

    })
    it('should succeed if it has spaces in it but is valid', () => {
      const topic = cc.validateCardNumber('4242 4242 4242 4242')
      expect(topic).toBeTruthy()

    })
    it('that does not pass the luhn checker', () => {
      const topic = cc.validateCardNumber('4242424242424241')
      expect(topic).toBeFalsy()

    })
    it('should fail if is more than 16 digits', () => {
      const topic = cc.validateCardNumber('42424242424242424')
      expect(topic).toBeFalsy()

    })
    it('should fail if is less than 10 digits', () => {
      const topic = cc.validateCardNumber('424242424')
      expect(topic).toBeFalsy()

    })
    it('should fail with non-digits', () => {
      const topic = cc.validateCardNumber('4242424e42424241')
      expect(topic).toBeFalsy()

    })
    it('should validate for all card types', () => {
      expect(cc.validateCardNumber('6759649826438453')).toBe('maestro')

      expect(cc.validateCardNumber('6007220000000004')).toBe('forbrugsforeningen')

      expect(cc.validateCardNumber('5019717010103742')).toBe('dankort')

      expect(cc.validateCardNumber('4111111111111111')).toBe('visa')
      expect(cc.validateCardNumber('4012888888881881')).toBe('visa')
      expect(cc.validateCardNumber('4222222222222')).toBe('visa')
      expect(cc.validateCardNumber('4462030000000000')).toBe('visa')
      expect(cc.validateCardNumber('4484070000000000')).toBe('visa')

      expect(cc.validateCardNumber('5555555555554444')).toBe('mastercard')
      expect(cc.validateCardNumber('5454545454545454')).toBe('mastercard')
      expect(cc.validateCardNumber('2221000002222221')).toBe('mastercard')

      expect(cc.validateCardNumber('378282246310005')).toBe('amex')
      expect(cc.validateCardNumber('371449635398431')).toBe('amex')
      expect(cc.validateCardNumber('378734493671000')).toBe('amex')

      expect(cc.validateCardNumber('30569309025904')).toBe('dinersclub')
      expect(cc.validateCardNumber('38520000023237')).toBe('dinersclub')
      expect(cc.validateCardNumber('36700102000000')).toBe('dinersclub')
      expect(cc.validateCardNumber('36148900647913')).toBe('dinersclub')

      expect(cc.validateCardNumber('6011111111111117')).toBe('discover')
      expect(cc.validateCardNumber('6011000990139424')).toBe('discover')

      expect(cc.validateCardNumber('6271136264806203568')).toBe('unionpay')
      expect(cc.validateCardNumber('6236265930072952775')).toBe('unionpay')
      expect(cc.validateCardNumber('6204679475679144515')).toBe('unionpay')
      expect(cc.validateCardNumber('6216657720782466507')).toBe('unionpay')

      expect(cc.validateCardNumber('3530111333300000')).toBe('jcb')
      expect(cc.validateCardNumber('3566002020360505')).toBe('jcb')
    })
  })
  describe('Validating a CVC', () => {

    it('should fail if is empty', () => {
      const topic = cc.validateCardCVC('')
      expect(topic).toBeFalsy()

    })
    it('should pass if is valid', () => {
      const topic = cc.validateCardCVC('123')
      expect(topic).toBeTruthy()

    })
    it('should fail with non-digits', () => {
      const topic = cc.validateCardNumber('12e')
      expect(topic).toBeFalsy()

    })
    it('should fail with less than 3 digits', () => {
      const topic = cc.validateCardNumber('12')
      expect(topic).toBeFalsy()

    })
    it('should fail with more than 4 digits', () => {
      const topic = cc.validateCardNumber('12345')
      expect(topic).toBeFalsy()
    })
  })
  describe('Validating an expiration date', () => {

    it('should fail expires is before the current year', () => {
      const currentTime = new Date()
      const topic = cc.validateCardExpiry(currentTime.getMonth() + 1, currentTime.getFullYear() - 1)
      expect(topic).toBeFalsy()

    })
    it('that expires in the current year but before current month', () => {
      const currentTime = new Date()
      const topic = cc.validateCardExpiry(currentTime.getMonth(), currentTime.getFullYear())
      expect(topic).toBeFalsy()

    })
    it('that has an invalid month', () => {
      const currentTime = new Date()
      const topic = cc.validateCardExpiry(13, currentTime.getFullYear())
      expect(topic).toBeFalsy()

    })
    it('that is this year and month', () => {
      const currentTime = new Date()
      const topic = cc.validateCardExpiry(currentTime.getMonth() + 1, currentTime.getFullYear())
      expect(topic).toBeTruthy()

    })
    it('that is just after this month', () => {
      // Remember - months start with 0 in JavaScript!
      const currentTime = new Date()
      const topic = cc.validateCardExpiry(currentTime.getMonth() + 1, currentTime.getFullYear())
      expect(topic).toBeTruthy()

    })
    it('that is after this year', () => {
      const currentTime = new Date()
      const topic = cc.validateCardExpiry(currentTime.getMonth() + 1, currentTime.getFullYear() + 1)
      expect(topic).toBeTruthy()

    })
    it('that is a two-digit year', () => {
      const currentTime = new Date()
      const topic = cc.validateCardExpiry(currentTime.getMonth() + 1,
        ('' + currentTime.getFullYear()).substr(0, 2))
      expect(topic).toBeTruthy()

    })
    it('that is a two-digit year in the past (i.e. 1990s)', () => {
      const currentTime = new Date()
      const topic = cc.validateCardExpiry(currentTime.getMonth() + 1, 99)
      expect(topic).toBeFalsy()

    })
    it('that has string numbers', () => {
      const currentTime = new Date()
      currentTime.setFullYear(currentTime.getFullYear() + 1, currentTime.getMonth() + 2)
      const topic = cc.validateCardExpiry(currentTime.getMonth() + 1 + '', currentTime.getFullYear() + '')
      expect(topic).toBeTruthy()

    })
    it('that has non-numbers', () => {
      const topic = cc.validateCardExpiry('h12', '3300')
      expect(topic).toBeFalsy()

    })
    it('should fail if year or month is NaN', () => {
      const topic = cc.validateCardExpiry('12', NaN)
      expect(topic).toBeFalsy()

    })
    it('should support year shorthand', () => {
      expect(cc.validateCardExpiry('05', '20')).toBeTruthy()
    })
  })
  describe('Validating a CVC number', () => {

    it('should validate a three digit number with no card type', () => {
      const topic = cc.validateCardCVC('123')
      expect(topic).toBeTruthy()

    })
    it('should validate a three digit number with card type amex', () => {
      const topic = cc.validateCardCVC('123', 'amex')
      expect(topic).toBeTruthy()

    })
    it('should validate a three digit number with card type other than amex', () => {
      const topic = cc.validateCardCVC('123', 'visa')
      expect(topic).toBeTruthy()

    })
    it('should not validate a four digit number with a card type other than amex', () => {
      const topic = cc.validateCardCVC('1234', 'visa')
      expect(topic).toBeFalsy()

    })
    it('should validate a four digit number with card type amex', () => {
      const topic = cc.validateCardCVC('1234', 'amex')
      expect(topic).toBeTruthy()

    })
    it('should not validate a number larger than 4 digits', () => {
      const topic = cc.validateCardCVC('12344')
      expect(topic).toBeFalsy()
    })
  })
  describe('Parsing an expiry value', () => {

    it('should parse string expiry', () => {
      const topic = cc.cardExpiryVal('03 / 2025')
      expect(topic).toEqual({ month: 3, year: 2025 })

    })
    it('should support shorthand year', () => {
      const topic = cc.cardExpiryVal('05/04')
      expect(topic).toEqual({ month: 5, year: 2004 })

    })
    it('should return NaN when it cannot parse', () => {
      const topic = cc.cardExpiryVal('05/dd')
      expect(isNaN(topic.year)).toBeTruthy()
    })
  })

  describe('Getting a card type', () => {

    it('should return Visa that begins with 40', () => {
      const topic = cc.cardType('4012121212121212')
      expect(topic).toBe('visa')

    })
    it('that begins with 2 should return MasterCard', () => {
      const topic = cc.cardType('2221000002222221')
      expect(topic).toBe('mastercard')

    })
    it('that begins with 5 should return MasterCard', () => {
      const topic = cc.cardType('5555555555554444')
      expect(topic).toBe('mastercard')

    })
    it('that begins with 34 should return American Express', () => {
      const topic = cc.cardType('3412121212121212')
      expect(topic).toBe('amex')

    })
    it('that is not numbers should return null', () => {
      const topic = cc.cardType('aoeu')
      expect(topic).toBe(null)

    })
    it('that has unrecognized beginning numbers should return null', () => {
      const topic = cc.cardType('aoeu')
      expect(topic).toBe(null)

    })
    it('should return correct type for all test numbers', () => {
      expect(cc.cardType('6759649826438453')).toBe('maestro')
      expect(cc.cardType('6220180012340012345')).toBe('maestro')

      expect(cc.cardType('6007220000000004')).toBe('forbrugsforeningen')

      expect(cc.cardType('5019717010103742')).toBe('dankort')

      expect(cc.cardType('4111111111111111')).toBe('visa')
      expect(cc.cardType('4012888888881881')).toBe('visa')
      expect(cc.cardType('4222222222222')).toBe('visa')
      expect(cc.cardType('4462030000000000')).toBe('visa')
      expect(cc.cardType('4484070000000000')).toBe('visa')

      expect(cc.cardType('5555555555554444')).toBe('mastercard')
      expect(cc.cardType('5454545454545454')).toBe('mastercard')
      expect(cc.cardType('2221000002222221')).toBe('mastercard')

      expect(cc.cardType('378282246310005')).toBe('amex')
      expect(cc.cardType('371449635398431')).toBe('amex')
      expect(cc.cardType('378734493671000')).toBe('amex')

      expect(cc.cardType('30569309025904')).toBe('dinersclub')
      expect(cc.cardType('38520000023237')).toBe('dinersclub')
      expect(cc.cardType('36700102000000')).toBe('dinersclub')
      expect(cc.cardType('36148900647913')).toBe('dinersclub')

      expect(cc.cardType('6011111111111117')).toBe('discover')
      expect(cc.cardType('6011000990139424')).toBe('discover')

      expect(cc.cardType('6271136264806203568')).toBe('unionpay')
      expect(cc.cardType('6236265930072952775')).toBe('unionpay')
      expect(cc.cardType('6204679475679144515')).toBe('unionpay')
      expect(cc.cardType('6216657720782466507')).toBe('unionpay')

      expect(cc.cardType('3530111333300000')).toBe('jcb')
      expect(cc.cardType('3566002020360505')).toBe('jcb')
    })
  })
  describe('Extending the card collection', () => {

    it('should expose an array of standard card types', () => {
      const cards = cc.cards
      expect(Array.isArray(cards))
      const visa = _.find(cards, (card) => card.type === 'visa')
      expect(visa).toBeTruthy()

    })
    it('should support new card types', () => {
      const wing = {
        type: 'wing',
        patterns: [501818],
        length: [16],
        luhn: false,
        format: defaultFormat,
        cvcLength: [2]
      }
      cc.cards.unshift(wing)

      const wingCard = '5018 1818 1818 1818'
      expect(cc.cardType(wingCard)).toBe('wing')
      expect(cc.validateCardNumber(wingCard)).toBeTruthy()
    })
  })
})