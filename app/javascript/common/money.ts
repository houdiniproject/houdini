// License: LGPL-3.0-or-later
// based upon https://github.com/davidkalosi/js-money
import isFunction from 'lodash/isFunction'

const assertSameCurrency = function (left: any, right: any) {
  if (left.currency !== right.currency)
    throw new Error('Different currencies');
};

const assertType = function (other: any) {
  if (!(other instanceof Money))
    throw new TypeError('Instance of Money required');
};

const assertOperand = function (operand: any) {
  if (isNaN(parseFloat(operand)) && !isFinite(operand))
    throw new TypeError('Operand must be a number');
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

  protected constructor(readonly amountInCents: number, currency: string) {
    this.currency = currency.toLowerCase()
    [this.equals, this.add, this.subtract, this.multiply, this.divide, this.allocate,
      this.compare, this.greaterThan, this.greaterThanOrEqual, this.lessThan,
      this.lessThanOrEqual, this.isZero, this.isPositive, this.isNegative,
      this.toJSON].forEach((func) => Object.bind(func))
    
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
  static fromCents(amountInCents: number, currency: string): Money {
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
    var self = this;
    assertType(other);

    return self.amountInCents === other.amountInCents &&
      self.currency === other.currency;
  };

  /**
   * Adds the two objects together creating a new Money instance that holds the result of the operation.
   *
   * @param {Money} other
   * @returns {Money}
   */
  add(other: Money): Money {
    var self = this;
    assertType(other);
    assertSameCurrency(self, other);

    return new Money(self.amountInCents + other.amountInCents, self.currency);
  };

  /**
   * Subtracts the two objects creating a new Money instance that holds the result of the operation.
   *
   * @param {Money} other
   * @returns {Money}
   */
  subtract(other: Money): Money {
    var self = this;
    assertType(other);
    assertSameCurrency(self, other);

    return new Money(self.amountInCents - other.amountInCents, self.currency);
  };

  /**
   * Multiplies the object by the multiplier returning a new Money instance that holds the result of the operation.
   *
   * @param {Number} multiplier
   * @param {(x:number) => number} [fn=Math.round]
   * @returns {Money}
   */
  multiply(multiplier: number, fn?: Function): Money {
    if (!lodash.isFunction(fn))
      fn = Math.round;

    assertOperand(multiplier);
    var amount = fn(this.amountInCents * multiplier);

    return new Money(amount, this.currency);
  };

  /**
   * Divides the object by the multiplier returning a new Money instance that holds the result of the operation.
   *
   * @param {Number} divisor
   * @param {(x:number) => number} [fn=Math.round]
   * @returns {Money}
   */
  divide(divisor: number, fn?: (x: number) => number): Money {
    if (!lodash.isFunction(fn))
      fn = Math.round;

    assertOperand(divisor);
    var amount = fn(this.amountInCents / divisor);

    return new Money(amount, this.currency);
  };

  /**
   * Allocates fund bases on the ratios provided returing an array of objects as a product of the allocation.
   *
   * @param {Array} other
   * @param {Money[]}
   */
  allocate(ratios: number[]): Money[] {
    var self = this;
    var remainder = self.amountInCents;
    var results: Money[] = [];
    var total = 0;

    ratios.forEach(function (ratio) {
      total += ratio;
    });

    ratios.forEach(function (ratio) {
      var share = Math.floor(self.amountInCents * ratio / total)
      results.push(new Money(share, self.currency));
      remainder -= share;
    });

    for (var i = 0; remainder > 0; i++) {
      results[i] = new Money(results[i].amountInCents + 1, results[i].currency);
      remainder--;
    }

    return results;
  };

  /**
   * Compares two instances of Money.
   *
   * @param {Money} other
   * @returns {Number}
   */
  compare(other: Money): number {
    var self = this;

    assertType(other);
    assertSameCurrency(self, other);

    if (self.amountInCents === other.amountInCents)
      return 0;

    return self.amountInCents > other.amountInCents ? 1 : -1;
  };

  /**
   * Checks whether the value represented by this object is greater than the other.
   *
   * @param {Money} other
   * @returns {boolean}
   */
  greaterThan(other: Money): boolean {
    return 1 === this.compare(other);
  };

  /**
   * Checks whether the value represented by this object is greater or equal to the other.
   *
   * @param {Money} other
   * @returns {boolean}
   */
  greaterThanOrEqual(other: Money): boolean {
    return 0 <= this.compare(other);
  };

  /**
   * Checks whether the value represented by this object is less than the other.
   *
   * @param {Money} other
   * @returns {boolean}
   */
  lessThan(other: Money): boolean {
    return -1 === this.compare(other);
  };

  /**
   * Checks whether the value represented by this object is less than or equal to the other.
   *
   * @param {Money} other
   * @returns {boolean}
   */
  lessThanOrEqual(other: Money): boolean {
    return 0 >= this.compare(other);
  };

  /**
   * Returns true if the amount is zero.
   *
   * @returns {boolean}
   */
  isZero(): boolean {
    return this.amountInCents === 0;
  };

  /**
   * Returns true if the amount is positive.
   *
   * @returns {boolean}
   */
  isPositive(): boolean {
    return this.amountInCents > 0;
  };

  /**
   * Returns true if the amount is negative.
   *
   * @returns {boolean}
   */
  isNegative(): boolean {
    return this.amountInCents < 0;
  };

  /**
   * Returns a serialised version of the instance.
   *
   * @returns {{amount: number, currency: string}}
   */
  toJSON(): { amountInCents: number; currency: string; } {
    return {
      amountInCents: this.amountInCents,
      currency: this.currency
    };
  };


}