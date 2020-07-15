// License: LGPL-3.0-or-later
import { Money } from './money';

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

		it('succeeds from function parameters', () => {
			expect.hasAssertions();
			const result = Money.fromCents(333, 'eur');
			// eslint-disable-next-line jest/prefer-strict-equal
			expect(result).toEqual({ amount: 333, currency: 'eur' });

			expect(result).toBeInstanceOf(Money);
		});
	});
});
