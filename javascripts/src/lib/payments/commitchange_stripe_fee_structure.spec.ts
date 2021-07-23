import { CommitchangeStripeFeeStructure } from './commitchange_stripe_fee_structure'
import 'jest';
import { Money } from '../money';
import {advanceTo, clear} from 'jest-date-mock';

describe('CommitchangeStripeFeeStructure', () => {
  describe('constructor', () => {

    const SWITCHOVER_TIME = new Date(2020,10,1);
    describe('before switchover time', () => {
      const GOTO_DATE = new Date(2020,9,1);
      beforeEach(() => {
        advanceTo(GOTO_DATE);
      })

      afterEach(() => {
        clear();
      })

      it('uses the modern fee structure', () => {
        const feeStructure = new CommitchangeStripeFeeStructure({flatFee:30, percentFee:.022, feeSwitchoverTime:SWITCHOVER_TIME, flatFeeCoveragePercent: 0.05})
        const tenThousand = Money.fromCents(10000, 'USD')
        let calcFee = feeStructure.calcFromNet(tenThousand)
        expect(calcFee.gross).toEqual(Money.fromCents(10500, 'USD'));
      });
    });

    describe('after switchover time', () => {
      const GOTO_DATE = new Date(2020,10,1, 1);
      beforeEach(() => {
        advanceTo(GOTO_DATE);
      })

      afterEach(() => {
        clear();
      })

      it('uses the modern fee structure', () => {
        const feeStructure = new CommitchangeStripeFeeStructure({flatFee:30, percentFee:.022, feeSwitchoverTime:SWITCHOVER_TIME, flatFeeCoveragePercent: 0.05})
        const tenThousand = Money.fromCents(10000, 'USD')
        let calcFee = feeStructure.calcFromNet(tenThousand)
        expect(calcFee.gross).toEqual(Money.fromCents(10500, 'USD'));
      });
    })
  })
})