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

type MoneyAsJson = {amount: number, currency: string}

/**
 * Represents a monetary amount. For safety, all Money objects are immutable. All of the functions in this class create a new Money object.
 * 
 * To create a new Money object is to use the `fromCents` function.
 * @export
 * @class Money
 */
export class Money {

  readonly currency:string

  protected constructor(readonly amount: number, currency: string) {
    this.currency = currency.toLowerCase()
    const methodsToBind = [this.equals, this.add, this.subtract, this.multiply, this.divide, this.allocate,
      this.compare, this.greaterThan, this.greaterThanOrEqual, this.lessThan,
      this.lessThanOrEqual, this.isZero, this.isPositive, this.isNegative,
      this.toJSON]
      methodsToBind.forEach((func:Function) => Object.bind(func))
    
    Object.freeze(this);
  }

  /**
   * Create a `Money` object with the given number of cents and the ISO currency unit
   * @static
   * @param  {number} amount 
   * @param  {string} currency 
   * @return Money 
   * @memberof Money
   */
 
  static fromCents(amount:MoneyAsJson): Money;
  static fromCents(amount:Money): Money;
  static fromCents(amount: number, currency: string) : Money;
  static fromCents(amount: number|Money|MoneyAsJson, currency?: string): Money {

    if (typeof amount === 'number')
      return new Money(amount, currency);
    if (amount instanceof Money)
      return new Money(amount.amount, amount.currency);
    else 
      return new Money(amount.amount, amount.currency)
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

    return self.amount === other.amount &&
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

    return new Money(self.amount + other.amount, self.currency);
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

    return new Money(self.amount - other.amount, self.currency);
  };

  /**
   * Multiplies the object by the multiplier returning a new Money instance that holds the result of the operation.
   *
   * @param {Number} multiplier
   * @param {(x:number) => number} [fn=Math.round]
   * @returns {Money}
   */
  multiply(multiplier: number, fn?: Function): Money {
    if (!isFunction(fn))
      fn = Math.round;

    assertOperand(multiplier);
    var amount = fn(this.amount * multiplier);

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
    if (!isFunction(fn))
      fn = Math.round;

    assertOperand(divisor);
    var amount = fn(this.amount / divisor);

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
    var remainder = self.amount;
    var results: Money[] = [];
    var total = 0;

    ratios.forEach(function (ratio) {
      total += ratio;
    });

    ratios.forEach(function (ratio) {
      var share = Math.floor(self.amount * ratio / total)
      results.push(new Money(share, self.currency));
      remainder -= share;
    });

    for (var i = 0; remainder > 0; i++) {
      results[i] = new Money(results[i].amount + 1, results[i].currency);
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

    if (self.amount === other.amount)
      return 0;

    return self.amount > other.amount ? 1 : -1;
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
    return this.amount === 0;
  };

  /**
   * Returns true if the amount is positive.
   *
   * @returns {boolean}
   */
  isPositive(): boolean {
    return this.amount > 0;
  };

  /**
   * Returns true if the amount is negative.
   *
   * @returns {boolean}
   */
  isNegative(): boolean {
    return this.amount < 0;
  };

  /**
   * Returns a serialised version of the instance.
   *
   * @returns {{amount: number, currency: string}}
   */
  toJSON(): MoneyAsJson {
    return {
      amount: this.amount,
      currency: this.currency
    };
  };
}