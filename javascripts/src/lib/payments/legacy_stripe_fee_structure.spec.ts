// License: LGPL-3.0-or-later
import { LegacyStripeFeeStructure } from './legacy_stripe_fee_structure'
import 'jest';
import { Money } from '../money';

describe('LegacyStripeFeeStructure', () => {
  describe('constructor', () => {
    it('throws on missing arguments', () => {
      const sfs = LegacyStripeFeeStructure as any;
      expect(() => new sfs({})).toThrowError(Error)
    })

    it('throws when flatFee is less than zero', () => {
      expect(() => LegacyStripeFeeStructure.createWithPlatformFee({ flatFee: -1, percentageFee: 0, platformFee: 0 })).toThrowError()
    })

    it('throws when percentFee is less than zero', () => {
      expect(() => LegacyStripeFeeStructure.createWithPlatformFee({ percentageFee: -1, flatFee: 0, platformFee: 0 })).toThrowError()
    })

    it('throws when percentFee is greater than 1', () => {
      expect(() => LegacyStripeFeeStructure.createWithPlatformFee({ percentageFee: 1.1, flatFee: 0, platformFee: 0 })).toThrowError()
    })

    it('it throws when flatFee is not an integer', () => {
      expect(() => LegacyStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentageFee: 0, platformFee: 0 })).toThrowError()
    })

    it('throws when platform fee is not a number', () => {
      expect(() => LegacyStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentageFee: 0, platformFee: "sa" as any })).toThrowError
    })
    it('throws when platform fee is less than 0', () => {
      expect(() => LegacyStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentageFee: 0, platformFee: -.2 })).toThrowError()
    })

    it('throws when platform fee is greater than 1', () => {
      expect(() => LegacyStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentageFee: 0, platformFee: 1.1 })).toThrowError()
    })
    it('throws when platform fee  + percentfee is greater than 1', () => {
      expect(() => LegacyStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentageFee: .5, platformFee: .6 })).toThrowError()
    })

    it('returns the expected structure when passing both', () => {
      expect(LegacyStripeFeeStructure.createWithPlatformFee({ percentageFee: .01, flatFee: 30, platformFee: .01 })).toMatchSnapshot()
    })

    it('returns the expected structure when passing percentFee', () => {
      expect(LegacyStripeFeeStructure.createWithPlatformFee({ percentageFee: 0, flatFee: 0, platformFee: .02 })).toMatchSnapshot()
    })

    it('returns the expected structure when passing flatFee', () => {
      expect(LegacyStripeFeeStructure.createWithPlatformFee({ flatFee: 30, percentageFee: 0, platformFee: 0 })).toMatchSnapshot()
    })
  })

  describe('calculateFee', () => {
    const feeStructure = LegacyStripeFeeStructure.createWithPlatformFee({ percentageFee: .02, flatFee: 30, platformFee: .002 })
    it('entering 100 gets fee of 33', () => {
      expect(feeStructure.calc(Money.fromCents(100, 'USD')))
        .toEqual({
          gross: Money.fromCents(100, 'usd'),
          fee: Money.fromCents(33, 'usd'),
          net: Money.fromCents(67, 'usd')
        })
    })

    it('entering 10000 gets fee of 250', () => {
      expect(feeStructure.calc(Money.fromCents(10000, 'USD')))
        .toEqual({
          gross: Money.fromCents(10000, 'usd'),
          fee: Money.fromCents(250, 'usd'),
          net: Money.fromCents(9750, 'usd')
        })
    })
  })

  describe('calcFromNet', () => {
    const feeStructure = LegacyStripeFeeStructure.createWithPlatformFee({ percentageFee: .022, flatFee: 30, platformFee: 0 })
    it('entering 100 gets proper fee', () => {

      const oneHundred = Money.fromCents(100, 'USD')
      let calcFee = feeStructure.calcFromNet(oneHundred)

      expect(feeStructure.calc(calcFee.gross)).toEqual(calcFee)
    })

    it('entering 10000 gets proper fee', () => {
      const tenThousand = Money.fromCents(10000, 'USD')
      let calcFee = feeStructure.calcFromNet(tenThousand)
      expect(feeStructure.calc(calcFee.gross)).toEqual(calcFee)
    })
  })
})