// License: LGPL-3.0-or-later
import { StripeFeeStructure } from './stripe_fee_structure'
import 'jest';
import { Money } from '../money';

describe('StripeFeeStructure', () => {
  describe('constructor', () => {
    it('throws on missing arguments', () => {
      const sfs = StripeFeeStructure;
      expect(() => new sfs({})).toThrowError(Error)
    })

    it('throws when flatFee is less than zero', () => {
      expect(() => new StripeFeeStructure({flatFee: -1})).toThrowError()
    })

    it('throws when percentFee is less than zero', () => {
      expect(() => new StripeFeeStructure({percentFee: -1})).toThrowError()
    })

    it('throws when percentFee is greater than 1', () => {
      expect(() => new StripeFeeStructure({percentFee: 1.1})).toThrowError()
    })

    it('it throws when flatFee is not an integer', () => {
      expect(() => new StripeFeeStructure({flatFee: 2.2})).toThrowError()
    })

    it('returns the expected structure when passing both', () => {
      expect(new StripeFeeStructure({percentFee: .02, flatFee: 30})).toMatchSnapshot()
    })

    it('returns the expected structure when passing percentFee', () => {
      expect(new StripeFeeStructure({percentFee: .02})).toMatchSnapshot()
    })

    it('returns the expected structure when passing flatFee', () => {
      expect(new StripeFeeStructure({flatFee: 30})).toMatchSnapshot()
    })
  })

  describe('calculateFee', () => {
    const feeStructure = new StripeFeeStructure({percentFee: .022, flatFee: 30})
    it('entering 100 gets fee of 32', () => {
      expect(feeStructure.calculateFee(Money.fromCents(100, 'USD'))).toEqual(Money.fromCents(32, 'usd'));
    })

    it('entering 10000 gets fee of 250', () => {
      expect(feeStructure.calculateFee(Money.fromCents(10000, 'USD'))).toEqual(Money.fromCents(250, 'usd'))
    })
  })

  describe('reverseCalculateFee', () => {
    const feeStructure = new StripeFeeStructure({percentFee: .022, flatFee: 30})
    it('entering 100 gets proper fee', () => {

      const oneHundred = Money.fromCents(100, 'USD')
      let calcFee = feeStructure.reverseCalculateFee(oneHundred)

      expect(feeStructure.calculateFee(calcFee.add(oneHundred))).toEqual(calcFee)
    })

    it('entering 10000 gets proper fee', () => {
      const tenThousand = Money.fromCents(10000, 'USD')
      let calcFee = feeStructure.reverseCalculateFee(tenThousand)

      expect(feeStructure.calculateFee(calcFee.add(tenThousand))).toEqual(calcFee)
    })
  })
})