// License: LGPL-3.0-or-later
// based upon https://github.com/davidkalosi/js-money
import BigNumber from 'bignumber.js';

const assertSameCurrency = function (left: any, right: any) {
  if (left.currency !== right.currency)
    throw new Error('Different currencies');
};

const assertType = function (other: any) {
  if (!(other instanceof Money))
    throw new TypeError('Instance of Money required');
};

const assertOperand = function (operand: number|BigNumber) {
  if (
    (typeof operand === 'number' && (isNaN(operand)|| !isFinite(operand))) ||
    (operand instanceof BigNumber && (operand.isNaN() || !operand.isFinite())))

    throw new TypeError('Operand must be a valid number');
};

/**
 * Represents a monetary amount. For safety, all Money objects are immutable. All of the functions in this class create a new Money object.
 * 
 * To create a new Money object is to use the `fromCents` function.
 * @export
 * @class Money
 */
export class Money {

  readonly currency:string
  readonly amountInCents:BigNumber
  protected constructor(amountInCents: number|BigNumber, currency: string) {

    if (typeof amountInCents === 'number'){
      amountInCents = new BigNumber(amountInCents);
    }
    if (!amountInCents.isInteger()) {
      throw new TypeError("Money may only be in whole units");
    }
    this.amountInCents = amountInCents;
    this.currency = currency.toLowerCase();
    Object.bind(this.equals)
    Object.bind(this.add)
    Object.bind(this.subtract)
    Object.bind(this.multiply)
    Object.bind(this.divide)
    Object.bind(this.compare)
    Object.bind(this.greaterThan)
    Object.bind(this.greaterThanOrEqual)
    Object.bind(this.lessThan)
    Object.bind(this.lessThanOrEqual)
    Object.bind(this.isZero)
    Object.bind(this.isPositive)
    Object.bind(this.isNegative)
    Object.bind(this.toJSON)
    Object.bind(this.toString)

    Object.freeze(this);
  }

  /**
   * Create a `Money` object with the given number of cents and the ISO currency unit
   * @static
   * @param  {number} amountInCents 
   * @param  {string} currency 
   * @return Money 
   * @memberof Money
   */
  static fromCents(amountInCents: number|BigNumber, currency: string): Money {
    return new Money(amountInCents, currency)
  }

  /**
   * Create a `Money` object with the given number if smallest monetary units and the ISO currency. Another name for the `fromCents` function.
   * @static
   * @memberof Money
   */
  static fromSMU=Money.fromCents

  /**
  * Returns true if the two instances of Money are equal, false otherwise.
  *
  * @param {Money} other
  * @returns {Boolean}
  */
  equals(other: Money): boolean {
    assertType(other);

    return this.amountInCents.isEqualTo(other.amountInCents) &&
      this.currency === other.currency;
  };

  /**
   * Adds the two objects together creating a new Money instance that holds the result of the operation.
   *
   * @param {Money} other
   * @returns {Money}
   */
  add(other: Money|number): Money {
    if (typeof other === 'number') {
      other = Money.fromCents(other, this.currency);
    }
    assertType(other);
    assertSameCurrency(this, other);

    return new Money(this.amountInCents.plus(other.amountInCents), this.currency);
  };

  /**
   * Subtracts the two objects creating a new Money instance that holds the result of the operation.
   *
   * @param {Money} other
   * @returns {Money}
   */
  subtract(other: Money): Money {
    assertType(other);
    assertSameCurrency(this, other);

    return new Money(this.amountInCents.minus(other.amountInCents), this.currency);
  };

  /**
   * Multiplies the object by the multiplier returning a new Money instance that holds the result of the operation.
   *
   * @param {Number} multiplier
   * @returns {Money}
   */
  multiply(multiplier: number|BigNumber, roundingMode:BigNumber.RoundingMode=BigNumber.ROUND_CEIL): Money {

    assertOperand(multiplier);
    const amount = new BigNumber(this.amountInCents.multipliedBy(multiplier).toFixed(0, roundingMode));

    return new Money(amount, this.currency);
  };

  /**
   * Divides the object by the multiplier returning a new Money instance that holds the result of the operation.
   *
   * @param {Number} divisor
   * @returns {Money}
   */
  divide(divisor: number|BigNumber|Money, roundingMode: BigNumber.RoundingMode = BigNumber.ROUND_CEIL): Money {

    if (divisor instanceof Money) {
      assertSameCurrency(this, divisor)
      divisor = divisor.amountInCents
    }
    
    assertOperand(divisor);
    const oldRoundingMode = BigNumber.config({})
    BigNumber.config({ROUNDING_MODE: roundingMode, DECIMAL_PLACES: 0})
    const amount = this.amountInCents.div(divisor);
    BigNumber.config({...oldRoundingMode})

    return new Money(amount, this.currency);
  };

  /**
   * Allocates fund bases on the ratios provided returing an array of objects as a product of the allocation.
   *
   * @param {Array} other
   * @param {Money[]}
   */
  // allocate(ratios: number[]): Money[] {
  //   var self = this;
  //   var remainder = self.amountInCents;
  //   var results: Money[] = [];
  //   var total = 0;

  //   ratios.forEach(function (ratio) {
  //     total += ratio;
  //   });

  //   ratios.forEach(function (ratio) {
  //     var share = Math.floor(self.amountInCents * ratio / total)
  //     results.push(new Money(share, self.currency));
  //     remainder -= share;
  //   });

  //   for (var i = 0; remainder > 0; i++) {
  //     results[i] = new Money(results[i].amountInCents + 1, results[i].currency);
  //     remainder--;
  //   }

  //   return results;
  // };

  /**
   * Compares two instances of Money.
   *
   * @param {Money} other
   * @returns {Number}
   */
  compare(other: Money): number {

    assertType(other);
    assertSameCurrency(this, other);

    return this.amountInCents.comparedTo(other.amountInCents)
  };

  /**
   * Checks whether the value represented by this object is greater than the other.
   *
   * @param {Money} other
   * @returns {boolean}
   */
  greaterThan(other: Money): boolean {
    assertType(other);
    assertSameCurrency(this, other);
    return this.amountInCents.isGreaterThan(other.amountInCents)
  };

  /**
   * Checks whether the value represented by this object is greater or equal to the other.
   *
   * @param {Money} other
   * @returns {boolean}
   */
  greaterThanOrEqual(other: Money): boolean {
    assertType(other);
    assertSameCurrency(this, other);
    return this.amountInCents.isGreaterThanOrEqualTo(other.amountInCents)
  };

  /**
   * Checks whether the value represented by this object is less than the other.
   *
   * @param {Money} other
   * @returns {boolean}
   */
  lessThan(other: Money): boolean {
    assertType(other);
    assertSameCurrency(this, other);
    return this.amountInCents.isLessThan(other.amountInCents);
  };

  /**
   * Checks whether the value represented by this object is less than or equal to the other.
   *
   * @param {Money} other
   * @returns {boolean}
   */
  lessThanOrEqual(other: Money): boolean {
    return this.amountInCents.isLessThanOrEqualTo(other.amountInCents)
  };

  /**
   * Returns true if the amount is zero.
   *
   * @returns {boolean}
   */
  isZero(): boolean {
    return this.amountInCents.isZero();
  };

  /**
   * Returns true if the amount is positive.
   *
   * @returns {boolean}
   */
  isPositive(): boolean {
    return this.amountInCents.isPositive();
  };

  /**
   * Returns true if the amount is negative.
   *
   * @returns {boolean}
   */
  isNegative(): boolean {
    return this.amountInCents.isNegative();
  };

  /**
   * Returns a serialised version of the instance.
   *
   * @returns {{amount: number, currency: string}}
   */
  toJSON(): { amountInCents: number; currency: string; } {
    return {
      amountInCents: this.amountInCents.toNumber(),
      currency: this.currency
    };
  };

  toString(): string {
    return `${this.amountInCents.toNumber().toString()} ${this.currency}`;
  }
}

export default Money;