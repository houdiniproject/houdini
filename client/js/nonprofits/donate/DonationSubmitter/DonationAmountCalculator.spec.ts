// License: LGPL-3.0-or-later

import DonationAmountCalculator from './DonationAmountCalculator';

describe('DonationAmountCalculator', () => {
  
  // from javascripts/src/lib/payments/commitchange_fee_coverage_calculator.spec.ts
  const feesStructure = {
    percentageFee: .022,
    flatFee: 35
  }

  describe('calcResult', () => {
    
    it('returns 0 when no inputAmount set', () => {
      const calc = new DonationAmountCalculator(feesStructure);

      expect(calc.calcResult).toEqual({
        donationTotal: 0,
        potentialFees: "$0.36"
      })


    })

    it('returns 300 and fees of $.43 when no fees matched', () => {
      const calc = new DonationAmountCalculator(feesStructure);

      calc.inputAmount = 300;

      expect(calc.calcResult).toEqual({
        donationTotal: 300,
        potentialFees: "$0.43",
      })


    })

    it('returns 300 and fees of $.43 when no fees matched', () => {
      const calc = new DonationAmountCalculator(feesStructure);

      calc.inputAmount = 300;
      calc.coverFees = true;

      expect(calc.calcResult).toEqual({
        donationTotal: 343,
        potentialFees: "$0.43",
      })


    })
  })

  describe('event dispatching', () => {
    it('fires an updated event when amount is set', () => {
      const calc = new DonationAmountCalculator(feesStructure)
      const updatedEventListener = jest.fn();
      calc.addEventListener('updated', updatedEventListener)
      calc.inputAmount = 300;
      expect(updatedEventListener).toHaveBeenCalled();
    })

    it('fires an updated event when coverFees is set', () => {
      const calc = new DonationAmountCalculator(feesStructure)
      const updatedEventListener = jest.fn();
      calc.addEventListener('updated', updatedEventListener)
      calc.coverFees = true;

      expect(updatedEventListener).toHaveBeenCalled();
    })
  })


})