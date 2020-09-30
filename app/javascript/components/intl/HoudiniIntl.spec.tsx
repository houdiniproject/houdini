// License: LGPL-3.0-or-later
import { createHoudiniIntl, FormatMoneyOptions } from "./HoudiniIntl";
import { Money } from "../../common/money";
const NBSP = '\xa0';

let tests:Array<[Money,  FormatMoneyOptions, string]>;


describe('formatMoney', () => {
	describe('en', () => {
		const intl = createHoudiniIntl({locale: 'en'});
		const oneDollar = Money.fromCents(100, 'usd');
		const oneThousandDollars = Money.fromCents(100000, 'usd');
		const oneThousandDollarsTenCents = Money.fromCents(100010, 'usd');
		const oneEuro = Money.fromCents(100, 'eur');
		const oneHundredYen = Money.fromCents(100, 'jpy');

		tests = [
			[oneDollar,  {}, "$1.00"],
			[oneDollar,  {currencyDisplay: 'code'}, `USD${NBSP}1.00`],
			[oneDollar,  {currencyDisplay: "name"}, "1.00 US dollars"],
			[oneThousandDollars, {}, '$1,000.00'],
			[oneThousandDollars, {currencyDisplay: 'code'}, `USD${NBSP}1,000.00`],
			[oneThousandDollars, {currencyDisplay: "name"}, `1,000.00 US dollars`],
			[oneThousandDollars, {minimumFractionDigits: 0}, "$1,000"],
			[oneThousandDollarsTenCents, {minimumFractionDigits: 2}, "$1,000.10"],
			[oneEuro,  {}, "€1.00"],
			[oneEuro,  {currencyDisplay: 'code'}, `EUR${NBSP}1.00`],
			[oneEuro,  {currencyDisplay: "name"}, "1.00 euros"],
			[oneHundredYen,  {}, "¥100"],
			[oneHundredYen,  {currencyDisplay: 'code'}, `JPY${NBSP}100`],
			[oneHundredYen,  {currencyDisplay: "name"}, "100 Japanese yen"],
		];
		it.each(tests)('money representing %j with opts %j returns %s', (money, opts, expected ) => {
			expect.assertions(1);
			const output = intl.formatMoney(money, opts);
			expect(output).toBe(expected);
		});
	});
});
