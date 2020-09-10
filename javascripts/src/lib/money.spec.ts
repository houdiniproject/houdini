// License: LGPL-3.0-or-later
// based upon https://github.com/davidkalosi/js-money

import {Money} from './money';
import BigNumber from 'bignumber.js';

describe('Money', function () {
  it('should create a new instance from integer', function () {
      var money = Money.fromCents(1000, 'EUR');

      expect(money.amountInCents).toEqual(new BigNumber(1000));
      expect(money.currency).toEqual('eur');
  });

  it('should create a new instance from string currency', function () {
      var money = Money.fromCents(1042, 'EUR');

      expect(money.amountInCents).toEqual(new BigNumber(1042));
      expect(money.currency).toEqual('eur');
  });

  it('should create a new instance from smallest monetary unit', function () {
      var money = Money.fromSMU(1151, 'EUR');

      expect(money.amountInCents).toEqual(new BigNumber(1151));
      expect(money.currency).toEqual('eur');
  });

  it('should create a new instance from zero integer', function () {
      var money = Money.fromCents(0,'EUR');

      expect(money.amountInCents.isZero()).toEqual(true)
      expect(money.currency).toEqual('eur');
  });

  it('should create a new instance from BigNumber with currency ', function () {
      var money = Money.fromCents(new BigNumber(1151),  'EUR');

      expect(money.amountInCents).toEqual(new BigNumber(1151));
      expect(money.currency).toEqual('eur');
  });

  it('should detect invalid amount', function () {
      expect(function () {
          Money.fromCents(10.2, 'XYZ')
      }).toThrow(TypeError)
  });

  it('should serialize correctly', function() {
      var money = Money.fromCents(1042, 'EUR');

      expect(money.amountInCents).toBeInstanceOf(BigNumber);
      expect(typeof money.currency === 'string').toBe(true)
  });


  it('should add same currencies', function () {
      var first = Money.fromCents(1000, 'EUR');
      var second = Money.fromCents(500, 'EUR');

      var result = first.add(second);
      expect(result.amountInCents).toEqual(new BigNumber(1500));
      expect(result.currency).toEqual('eur');

      expect(first.amountInCents).toEqual(new BigNumber(1000));
      expect(second.amountInCents).toEqual(new BigNumber(500));
  });

  it('should not add different currencies', function () {
      var first = Money.fromCents(1000, 'EUR');
      var second = Money.fromCents(500, 'USD');

      expect(first.add.bind(first, second)).toThrow(Error);
  });

  it('should check for same type', function () {
      var first = Money.fromCents(1000, 'EUR');

      expect(first.add.bind(first, {})).toThrow(TypeError);
  });

  it('should check if equal', function () {
      var first = Money.fromCents(1000, 'EUR');
      var second = Money.fromCents(1000, 'EUR');
      var third = Money.fromCents(1000, 'USD');
      var fourth = Money.fromCents(100, 'EUR');

      expect(first.equals(second)).toEqual(true);
      expect(first.equals(third)).toEqual(false);
      expect(first.equals(fourth)).toEqual(false);
  });

  it('should compare correctly', function () {
      var subject = Money.fromCents(1000, 'EUR');

      expect(subject.compare(Money.fromCents(1500, 'EUR'))).toEqual(-1);
      expect(subject.compare(Money.fromCents(500, 'EUR'))).toEqual(1);
      expect(subject.compare(Money.fromCents(1000, 'EUR'))).toEqual(0);

      expect(function () {
          subject.compare(Money.fromCents(1500, 'USD'));
      }).toThrow('Different currencies');

      expect(subject.greaterThan(Money.fromCents(1500, 'EUR'))).toEqual(false);
      expect(subject.greaterThan(Money.fromCents(500, 'EUR'))).toEqual(true);
      expect(subject.greaterThan(Money.fromCents(1000, 'EUR'))).toEqual(false);

      expect(subject.greaterThanOrEqual(Money.fromCents(1500, 'EUR'))).toEqual(false);
      expect(subject.greaterThanOrEqual(Money.fromCents(500, 'EUR'))).toEqual(true);
      expect(subject.greaterThanOrEqual(Money.fromCents(1000, 'EUR'))).toEqual(true);

      expect(subject.lessThan(Money.fromCents(1500, 'EUR'))).toEqual(true);
      expect(subject.lessThan(Money.fromCents(500, 'EUR'))).toEqual(false);
      expect(subject.lessThan(Money.fromCents(1000, 'EUR'))).toEqual(false);

      expect(subject.lessThanOrEqual(Money.fromCents(1500, 'EUR'))).toEqual(true);
      expect(subject.lessThanOrEqual(Money.fromCents(500, 'EUR'))).toEqual(false);
      expect(subject.lessThanOrEqual(Money.fromCents(1000, 'EUR'))).toEqual(true);
  });

  it('should subtract same currencies correctly', function() {
      var subject = Money.fromCents(1000, 'EUR');
      var result = subject.subtract(Money.fromCents(250, 'EUR'));

      expect(result.amountInCents).toEqual(new BigNumber(750));
      expect(result.currency).toEqual('eur');
  });

  it('should multiply correctly', function() {
      var subject = Money.fromCents(1000, 'EUR');

      expect(subject.multiply(1.2234).amountInCents).toEqual(new BigNumber(1224));
      expect(subject.multiply(1.2234).amountInCents).toEqual(new BigNumber(1224));
      expect(subject.multiply(1.2234, BigNumber.ROUND_FLOOR).amountInCents).toEqual(new BigNumber(1223));
  });

  it('should divide correctly', function() {
      var subject = Money.fromCents(1000, 'EUR');

      expect(subject.divide(2.234).amountInCents).toEqual(new BigNumber(448));
      expect(subject.divide(2.234, BigNumber.ROUND_CEIL).amountInCents).toEqual(new BigNumber(448));
      expect(subject.divide(2.234, BigNumber.ROUND_FLOOR).amountInCents).toEqual(new BigNumber(447));
  });

  // it('should allocate correctly', function() {
  //    var subject = Money.fromCents(1000, 'EUR');
  //    var results = subject.allocate([1,1,1]);

  //    expect(results.length).to.equal(3);
  //    expect(results[0].amountInCents).to.equal(334);
  //    expect(results[0].currency).to.equal('EUR');
  //    expect(results[1].amountInCents).to.equal(333);
  //    expect(results[1].currency).to.equal('EUR');
  //    expect(results[2].amountInCents).to.equal(333);
  //    expect(results[2].currency).to.equal('EUR');
  // });

  it('zero check works correctly', function() {
      var subject = Money.fromCents(1000, 'EUR');
      var subject1 = Money.fromCents(0, 'EUR');

      expect(subject.isZero()).toEqual(false);
      expect(subject1.isZero()).toEqual(true);
  });

  it('positive check works correctly', function() {
      var subject = Money.fromCents(1000, 'EUR');
      var subject1 = Money.fromCents(-1000, 'EUR');

      expect(subject.isPositive()).toEqual(true);
      expect(subject1.isPositive()).toEqual(false);
  });

  it('negative check works correctly', function() {
      var subject = Money.fromCents(1000, 'EUR');
      var subject1 = Money.fromCents(-1000, 'EUR');

      expect(subject.isNegative()).toEqual(false);
      expect(subject1.isNegative()).toEqual(true);
  })

  it('should allow to be stringified as JSON', function () {
      var subject = Money.fromCents(1000, 'EUR');

      expect(JSON.stringify({ foo: subject })).toEqual('{"foo":{"amountInCents":1000,"currency":"eur"}}');
  });
});