// License: LGPL-3.0-or-later
import 'jest';
import { Money } from '../money';
import {CommitchangeFeeCoverageCalculator} from './commitchange_fee_coverage_calculator';
describe('CommitchangeFeeCoverageCalculator', () => {

  const CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithoutFeeCovering = new CommitchangeFeeCoverageCalculator({
    percentageFee: .022,
    flatFee: 35,
    currency: 'usd',
    feeCovering: false,
  })

  const CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithFeeCovering = new CommitchangeFeeCoverageCalculator({
    percentageFee: .022,
    flatFee: 35,
    currency: 'usd',
    feeCovering: true,
  })

  const CalcWithPercentageFeeOf5PercentWithoutFeeCovering = new CommitchangeFeeCoverageCalculator({
    percentageFee: .05,
    flatFee: 0,
    currency: 'usd',
    feeCovering: false,
  })

  const CalcWithPercentageFeeOf5PercentWithFeeCovering = new CommitchangeFeeCoverageCalculator({
    percentageFee: .05,
    flatFee: 0,
    currency: 'usd',
    feeCovering: true,
  })

  describe('calc', () => {
    describe('when using CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithoutFeeCovering', () => {
      const subject = CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithoutFeeCovering;
      
      describe('and called with 343', () => {
        const result = subject.calc(343);
        it('returns expected result', () => {
          expect(result).toEqual({
            estimatedFees: {
              gross: Money.fromCents(343, 'usd'),
              grossAsNumber: 343,
              fee: Money.fromCents(43, 'usd'),
              feeAsNumber: 43,
              net: Money.fromCents(300, 'usd'),
              netAsNumber: 300
            }
          })
        });
      });
    });

    describe('when using CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithFeeCovering', () => {
      const subject = CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithFeeCovering;
      
      describe('and called with 343', () => {
        const result = subject.calc(343);
        it('returns expected result', () => {
          expect(result).toEqual({
            estimatedFees: {
              gross: Money.fromCents(343, 'usd'),
              grossAsNumber: 343,
              fee: Money.fromCents(43, 'usd'),
              feeAsNumber: 43,
              net: Money.fromCents(300, 'usd'),
              netAsNumber: 300
            }
          })
        });
      })
    });

    describe('when using CalcWithPercentageFeeOf5PercentWithoutFeeCovering', () => {
      const subject = CalcWithPercentageFeeOf5PercentWithoutFeeCovering;
      
      describe('and called with 316', () => {
        const result = subject.calc(316);
        it('returns expected result', () => {
          expect(result).toEqual({
            estimatedFees: {
              gross: Money.fromCents(316, 'usd'),
              grossAsNumber: 316,
              fee: Money.fromCents(16, 'usd'),
              feeAsNumber: 16,
              net: Money.fromCents(300, 'usd'),
              netAsNumber: 300
            }
          })
        });
      })
    });

    describe('when using CalcWithPercentageFeeOf5PercentWithFeeCovering', () => {
      const subject = CalcWithPercentageFeeOf5PercentWithFeeCovering;
      
      describe('and called with 316', () => {
        const result = subject.calc(316);
        it('returns expected result', () => {
          expect(result).toEqual({
            estimatedFees: {
              gross: Money.fromCents(316, 'usd'),
              grossAsNumber: 316,
              fee: Money.fromCents(16, 'usd'),
              feeAsNumber: 16,
              net: Money.fromCents(300, 'usd'),
              netAsNumber: 300
            }
          })
        });
      })
    });
  })

  describe('calcFromNet', () => {
    describe('when using CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithoutFeeCovering', () => {
      const subject = CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithoutFeeCovering;
      
      describe('and called with 300', () => {
        const result = subject.calcFromNet(300);
        it('returns expected result', () => {
          expect(result).toEqual({
            actualTotal: Money.fromCents(300, 'usd'),
            actualTotalAsNumber: 300,
            actualTotalAsString: "$3",
            estimatedFees: {
              gross: Money.fromCents(343, 'usd'),
              grossAsNumber: 343,
              fee: Money.fromCents(43, 'usd'),
              feeAsNumber: 43,
              feeAsString: "$0.43",
              net: Money.fromCents(300, 'usd'),
              netAsNumber: 300
            }
          })
        });

        
      });

      describe('and called with null', () => {
        const result = subject.calcFromNet(null);
        it('returns expected result', () => {
          expect(result).toMatchObject({
            actualTotal: Money.fromCents(0, 'usd'),
            actualTotalAsNumber: 0,
            actualTotalAsString: "$0",
          });
        });
      });

      describe('and called with undefined', () => {
        const result = subject.calcFromNet(undefined);
        it('returns expected result', () => {
          expect(result).toMatchObject({
            actualTotal: Money.fromCents(0, 'usd'),
            actualTotalAsNumber: 0,
            actualTotalAsString: "$0",
          });
        });
      });
    });

    describe('when using CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithFeeCovering', () => {
      const subject = CalcWithPercentageFeeOf4_8_percentAnd35CentsCalcWithFeeCovering;
      
      describe('and called with 300', () => {
        const result = subject.calcFromNet(300);
        it('returns expected result', () => {
          expect(result).toEqual({
            actualTotal: Money.fromCents(343, 'usd'),
            actualTotalAsNumber: 343,
            actualTotalAsString: "$3.43",
            estimatedFees: {
              gross: Money.fromCents(343, 'usd'),
              grossAsNumber: 343,
              fee: Money.fromCents(43, 'usd'),
              feeAsNumber: 43,
              feeAsString: "$0.43",
              net: Money.fromCents(300, 'usd'),
              netAsNumber: 300
            }
          })
        });
      });
    });

    describe('when using CalcWithPercentageFeeOf5PercentWithoutFeeCovering', () => {
      const subject = CalcWithPercentageFeeOf5PercentWithoutFeeCovering;
      
      describe('and called with 300', () => {
        const result = subject.calcFromNet(300);
        it('returns expected result', () => {
          expect(result).toEqual({
            actualTotal: Money.fromCents(300, 'usd'),
            actualTotalAsNumber: 300,
            actualTotalAsString: "$3",
            estimatedFees: {
              gross: Money.fromCents(316, 'usd'),
              grossAsNumber: 316,
              fee: Money.fromCents(16, 'usd'),
              feeAsNumber: 16,
              feeAsString: "$0.16",
              net: Money.fromCents(300, 'usd'),
              netAsNumber: 300
            }
          })
        });
      });
    });

    describe('when using CalcWithPercentageFeeOf5PercentWithFeeCovering', () => {
      const subject = CalcWithPercentageFeeOf5PercentWithFeeCovering;
      
      describe('and called with 300', () => {
        const result = subject.calcFromNet(300);
        it('returns expected result', () => {
          expect(result).toEqual({
            actualTotal: Money.fromCents(316, 'usd'),
            actualTotalAsNumber: 316,
            actualTotalAsString: "$3.16",
            estimatedFees: {
              gross: Money.fromCents(316, 'usd'),
              grossAsNumber: 316,
              fee: Money.fromCents(16, 'usd'),
              feeAsNumber: 16,
              feeAsString: "$0.16",
              net: Money.fromCents(300, 'usd'),
              netAsNumber: 300
            }
          })
        });
      });
    });
  });
  
})