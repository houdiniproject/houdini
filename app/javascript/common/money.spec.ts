// License: LGPL-3.0-or-later
import BigNumber from 'bignumber.js';
import { Money, Operand, RoundingMode } from './money';

describe("Money", () => {
	describe('Money.fromCents', () => {
		it('succeeds from a old Money object', () => {
			expect.assertions(2);
			const old = Money.fromCents(333, 'eur');

			const result = Money.fromCents(old);
			expect(result).toStrictEqual(old);

			expect(result).not.toBe(old);
		});
		it('succeeds from a json', () => {
			expect.hasAssertions();
			const old = { amount: 333, currency: 'eur' };

			const result = Money.fromCents(old);
			// eslint-disable-next-line jest/prefer-strict-equal
			expect(result).toEqual(old);

			expect(result).toBeInstanceOf(Money);
		});

		it('succeeds from a stringy json', () => {
			expect.hasAssertions();
			const old = Money.fromCents(333, 'eur');

			const result = Money.fromCents({ amount: '333', currency: 'eur' });
			// eslint-disable-next-line jest/prefer-strict-equal
			expect(result).toEqual(old);

			expect(result).toBeInstanceOf(Money);
		});

		it('succeeds from function parameters', () => {
			expect.hasAssertions();
			const result = Money.fromCents(333, 'eur');
			// eslint-disable-next-line jest/prefer-strict-equal
			expect(result).toEqual({ amount: 333, currency: 'eur' });

			expect(result).toBeInstanceOf(Money);
		});

		it('succeeds from BigNumber', () => {
			expect.hasAssertions();
			const result = Money.fromCents(new BigNumber(333), 'eur');
			// eslint-disable-next-line jest/prefer-strict-equal
			expect(result).toEqual({ amount: 333, currency: 'eur' });
		});

		it('rejects if string is not an integer', () => {
			expect.hasAssertions();
			expect(() => {
				Money.fromCents('3344.4', 'usd');
			}).toThrow(TypeError);
		});

		it('rejects if BigNumber is not an integer', () => {
			expect.hasAssertions();
			expect(() => {
				Money.fromCents(new BigNumber('3344.4'), 'usd');
			}).toThrow(TypeError);
		});

		it('rejects if number is not an integer', () => {
			expect.hasAssertions();
			expect(() => {
				Money.fromCents(444.333, 'usd');
			}).toThrow(TypeError);
		});
	});
	const cents1000 = Money.fromCents(1000, 'usd');
	const cents500 = Money.fromCents(500, 'usd');

	const euCents1000 = Money.fromCents(1000, 'eur');

	const negative1000  = Money.fromCents(-1000, 'usd');

	function verifyCurrency(func:(m:Money, other:Money) => unknown){
		expect.assertions(1);
		expect(() => func(cents1000, euCents1000)).toThrow(TypeError);
	}

	describe.each([
		['add', (m:Money, other:Money) => m.add(other)],
		['compare', (m:Money, other:Money) => m.compare(other)],
		['divide', (m:Money, other:Money) => m.divide(other)],
		['greaterThan', (m:Money, other:Money) => m.greaterThan(other)],
		['greaterThanOrEqual', (m:Money, other:Money) => m.greaterThanOrEqual(other)],
		['lessThan', (m:Money, other:Money) => m.lessThan(other)],
		['lessThanOrEqual', (m:Money, other:Money) => m.lessThanOrEqual(other)],
		['multiply', (m:Money, other:Money) => m.multiply(other)],
		['subtract', (m:Money, other:Money) => m.subtract(other)],

	])('.%s with %s', (_name, func) => {

		it(`throw when currency doesn't match`, () => {
			expect.assertions(1);
			expect(() => func(cents1000, euCents1000)).toThrow(TypeError);
		});
	});


	describe.each([
		['add', (m:Money, other:Operand) => m.add(other)],
		['subtract', (m:Money, other:Operand) => m.subtract(other)],
	])('.%s with %s', (_name, func) => {

		it(`throw when other is a decimal number`, () => {
			expect.assertions(1);
			expect(() => func(cents1000, 4.5)).toThrow(TypeError);
		});

		it(`throw when other is a decimal BigNumber`, () => {
			expect.assertions(1);
			expect(() => func(cents1000, new BigNumber('4.5'))).toThrow(TypeError);
		});
	});

	it('.isZero', () => {
		expect.assertions(1);
		expect(cents1000.isZero()).toStrictEqual(false);
	});

	it('.isPositive', () => {
		expect.assertions(1);
		expect(cents1000.isPositive()).toStrictEqual(true);
	});

	it('.isNegative', () => {
		expect.assertions(1);
		expect(negative1000.isNegative()).toStrictEqual(true);
	});

	describe('.compare', () => {
		describe('greater', () => {
			describe('Money', () => {
				it('same currency', () => {
					expect.assertions(1);
					expect(cents1000.compare(cents500)).toStrictEqual(1);
				});

				it('different currency', () => {
					expect.assertions(1);
					expect(() => {
						cents1000.compare(euCents1000);
					}).toThrow(TypeError);
				});
			});

			describe('BigNumber', () => {
				it('same currency', () => {
					expect.assertions(1);
					expect(cents1000.compare(cents500)).toStrictEqual(1);
				});

				it('different currency', () => {
					expect.assertions(1);
					expect(() => {
						cents1000.compare(euCents1000);
					}).toThrow(TypeError);
				});
			});
		});
	});

	describe('.divide', () => {
		it('divides 36 into 9', () => {
			expect.assertions(1);
			expect(Money.fromCents(36, 'usd').divide(9).toJSON()).toStrictEqual({amount: 4, currency: 'usd'});
		});

		it('throws if the currencies do not match', () => {
			expect.assertions(1);
			verifyCurrency((m, other) => m.divide(other));
		});

		it('defaults to rounding to HalfUp', () => {
			expect.assertions(3);
			expect(Money.fromCents(40, 'usd').divide(Money.fromCents(9, 'usd')).toJSON()).toStrictEqual({amount: 4, currency: 'usd'});

			expect(Money.fromCents(41, 'usd').divide(Money.fromCents(9, 'usd')).toJSON()).toStrictEqual({amount: 5, currency: 'usd'});

			expect(Money.fromCents(7, 'usd').divide(Money.fromCents(2, 'usd')).toJSON()).toStrictEqual({amount: 4, currency: 'usd'});
		});
		it('rounds to floor if requested', () => {
			expect.assertions(1);
			expect(Money.fromCents(41, 'usd').divide(Money.fromCents(9, 'usd'), RoundingMode.Floor).toJSON()).toStrictEqual({amount: 4, currency: 'usd'});
		});

		it('rounds to ceil if requested', () => {
			expect.assertions(1);
			expect(Money.fromCents(40, 'usd').divide(Money.fromCents(9, 'usd'), RoundingMode.Ceil).toJSON()).toStrictEqual({amount: 5, currency: 'usd'});
		});
	});

	describe('.multiply', () => {
		it('multiply 9 x 4', () => {
			expect.assertions(1);
			expect(Money.fromCents(9, 'usd').multiply(4).toJSON()).toStrictEqual({amount: 36, currency: 'usd'});
		});

		it('throws if the currencies do not match', () => {
			expect.assertions(1);
			verifyCurrency((m, other) => m.multiply(other));
		});

		it('handles multiplying by a decimal properly', () => {
			expect.assertions(1);
			expect(Money.fromCents('3', 'usd').multiply(new BigNumber('1.263')).toJSON()).toStrictEqual({amount: 4, currency: 'usd'});
		});

		it('defaults to rounding to HalfUp', () => {
			expect.assertions(1);
			expect(Money.fromCents(7, 'usd').multiply(new BigNumber('.5')).toJSON()).toStrictEqual({amount: 4, currency: 'usd'});
		});

		it('rounds to floor if requested', () => {
			expect.assertions(1);
			expect(Money.fromCents('3', 'usd').multiply('1.263', RoundingMode.Floor).toJSON()).toStrictEqual({amount: 3, currency: 'usd'});
		});

		it('rounds to ceil if requested', () => {
			expect.assertions(1);
			expect(Money.fromCents('3', 'usd').multiply('1.263', RoundingMode.Ceil).toJSON()).toStrictEqual({amount: 4, currency: 'usd'});
		});
	});

	describe('.toBigNumber', () => {
		it('doesnt round to nearest integer', () => {
			expect.assertions(1);
			expect(cents1000.toBigNumber().plus('1.2').toString()).toStrictEqual('1001.2');
		});
	});

});
