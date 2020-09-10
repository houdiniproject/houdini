// License: LGPL-3.0-or-later
import { ModernStripeFeeStructure } from './modern_stripe_fee_structure'
import 'jest';
import { Money } from '../money';

describe('ModernStripeFeeStructure', () => {
  describe('constructor', () => {
    it('throws on missing arguments', () => {
      const sfs = ModernStripeFeeStructure as any;
      expect(() => new sfs({})).toThrowError(Error)
    })

    it('throws when flatFee is less than zero', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ flatFee: -1, percentFee: 0, platformFee: 0, flatFeeCoveragePercent: 0 })).toThrowError()
    })

    it('throws when percentFee is less than zero', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ percentFee: -1, flatFee: 0, platformFee: 0, flatFeeCoveragePercent: 0 })).toThrowError()
    })

    it('throws when percentFee is greater than 1', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ percentFee: 1.1, flatFee: 0, platformFee: 0, flatFeeCoveragePercent: 0 })).toThrowError()
    })

    it('it throws when flatFee is not an integer', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentFee: 0, platformFee: 0, flatFeeCoveragePercent: 0 })).toThrowError()
    })

    it('throws when platform fee is not a number', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentFee: 0, platformFee: "sa" as any, flatFeeCoveragePercent: 0 })).toThrowError
    })
    it('throws when platform fee is less than 0', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentFee: 0, platformFee: -.2, flatFeeCoveragePercent: 0 })).toThrowError()
    })

    it('throws when platform fee is greater than 1', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentFee: 0, platformFee: 1.1, flatFeeCoveragePercent: 0 })).toThrowError()
    })
    
    it('throws when flatFeeCoveragePercent is less than zero', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ flatFeeCoveragePercent: -1, flatFee: 0, platformFee: 0, percentFee: 0 })).toThrowError()
    })

    it('throws when flatFeeCoveragePercent is greater than one', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ flatFeeCoveragePercent: 2, flatFee: 0, platformFee: 0, percentFee: 0 })).toThrowError()
    })


    it('throws when platform fee  + percentfee is greater than 1', () => {
      expect(() => ModernStripeFeeStructure.createWithPlatformFee({ flatFee: 2.2, percentFee: .5, platformFee: .6, flatFeeCoveragePercent: 0 })).toThrowError()
    })

    it('returns the expected structure when passing both', () => {
      expect(ModernStripeFeeStructure.createWithPlatformFee({ percentFee: .01, flatFee: 30, platformFee: .01, flatFeeCoveragePercent: 0 })).toMatchSnapshot()
    })

    it('returns the expected structure when passing percentFee', () => {
      expect(ModernStripeFeeStructure.createWithPlatformFee({ percentFee: 0, flatFee: 0, platformFee: .02, flatFeeCoveragePercent: 0 })).toMatchSnapshot()
    })

    it('returns the expected structure when passing flatFee', () => {
      expect(ModernStripeFeeStructure.createWithPlatformFee({ flatFee: 30, percentFee: 0, platformFee: 0, flatFeeCoveragePercent: 0 })).toMatchSnapshot()
    })
  })

  describe('calculateFee', () => {
    const feeStructure = ModernStripeFeeStructure.createWithPlatformFee({ percentFee: .02, flatFee: 30, platformFee: .002, flatFeeCoveragePercent: 0 })
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
    const feeStructure = ModernStripeFeeStructure.createWithPlatformFee({ percentFee: .022, flatFee: 30, platformFee: 0, flatFeeCoveragePercent: 0.05 })
    it('entering 100 gets proper fee', () => {

      const oneHundred = Money.fromCents(100, 'USD')
      let calcFee = feeStructure.calcFromNet(oneHundred)

      expect(calcFee.gross).toEqual(Money.fromCents(105, 'USD'))
    })

    it('entering 10000 gets proper fee', () => {
      const tenThousand = Money.fromCents(10000, 'USD')
      let calcFee = feeStructure.calcFromNet(tenThousand)
      expect(calcFee.gross).toEqual(Money.fromCents(10500, 'USD'))
    })
  })
})