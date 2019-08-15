// License: LGPL-3.0-or-later
import { CommitchangeStripeFeeStructure } from './commitchange_stripe_fee_structure'
import 'jest';
import { Money } from '../money';

describe('StripeFeeStructure', () => {
  describe('constructor', () => {
    it('throws on missing arguments', () => {
      const sfs = CommitchangeStripeFeeStructure as any;
      expect(() => new sfs({})).toThrowError(Error)
    })

    it('throws when flatFee is less than zero', () => {
      expect(() => CommitchangeStripeFeeStructure.createWithPlatformFee({flatFee: -1, percentFee: 0, platformFee: 0})).toThrowError()
    })

    it('throws when percentFee is less than zero', () => {
      expect(() => CommitchangeStripeFeeStructure.createWithPlatformFee({percentFee: -1, flatFee: 0, platformFee: 0})).toThrowError()
    })

    it('throws when percentFee is greater than 1', () => {
      expect(() => CommitchangeStripeFeeStructure.createWithPlatformFee({percentFee: 1.1, flatFee: 0, platformFee: 0})).toThrowError()
    })

    it('it throws when flatFee is not an integer', () => {
      expect(() => CommitchangeStripeFeeStructure.createWithPlatformFee({flatFee: 2.2, percentFee: 0, platformFee: 0})).toThrowError()
    })

    it('throws when platform fee is not a number', () => {
      expect(() => CommitchangeStripeFeeStructure.createWithPlatformFee({flatFee: 2.2, percentFee: 0, platformFee: "sa" as any})).toThrowError
    })
    it('throws when platform fee is less than 0', () => {
      expect(() => CommitchangeStripeFeeStructure.createWithPlatformFee({flatFee: 2.2, percentFee: 0, platformFee: -.2})).toThrowError()
    })
    
    it('throws when platform fee is greater than 1', () => {
      expect(() => CommitchangeStripeFeeStructure.createWithPlatformFee({flatFee: 2.2, percentFee: 0, platformFee: 1.1})).toThrowError()
    })
    it('throws when platform fee  + percentfee is greater than 1', () => {
      expect(() => CommitchangeStripeFeeStructure.createWithPlatformFee({flatFee: 2.2, percentFee: .5, platformFee: .6})).toThrowError()
    })

    it('returns the expected structure when passing both', () => {
      expect(CommitchangeStripeFeeStructure.createWithPlatformFee({percentFee: .01, flatFee: 30, platformFee: .01})).toMatchSnapshot()
    })

    it('returns the expected structure when passing percentFee', () => {
      expect(CommitchangeStripeFeeStructure.createWithPlatformFee({percentFee: 0, flatFee: 0, platformFee: .02})).toMatchSnapshot()
    })

    it('returns the expected structure when passing flatFee', () => {
      expect(CommitchangeStripeFeeStructure.createWithPlatformFee({flatFee: 30, percentFee: 0, platformFee: 0})).toMatchSnapshot()
    })
  })

  describe('calculateFee', () => {
    const feeStructure = CommitchangeStripeFeeStructure.createWithPlatformFee({percentFee: .02, flatFee: 30, platformFee: .002})
    it('entering 100 gets fee of 32', () => {
      expect(feeStructure.calculateFee(Money.fromCents(100, 'USD'))).toEqual(Money.fromCents(33, 'usd'));
    })

    it('entering 10000 gets fee of 250', () => {
      expect(feeStructure.calculateFee(Money.fromCents(10000, 'USD'))).toEqual(Money.fromCents(250, 'usd'))
    })
  })

  describe('reverseCalculateFee', () => {
    const feeStructure = CommitchangeStripeFeeStructure.createWithPlatformFee({percentFee: .022, flatFee: 30, platformFee: 0})
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