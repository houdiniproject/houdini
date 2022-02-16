// License: LGPL-3.0-or-later
import * as React from "react";
import type { FormatNumberOptions, IntlShape as ParentIntlShape } from "react-intl";
import { Money } from "../common/money";

export type FormatMoneyOptions = Omit<FormatNumberOptions,'style'|'unit'|'unitDisplay'|'currency'>;

export type IntlShape = ParentIntlShape & {
	/**
	 * Format a monetary value as a string given the locale
	 *
	 * @param {Money} amount the monetary value to convert to a string
	 * @param {FormatMoneyOptions} [opts] options for controlling how the string should be formatted
	 * @returns {string}
	 */
	formatMoney(amount: Money, opts?: FormatMoneyOptions): string;
};

export const IntlContext = React.createContext<IntlShape>(null as unknown as IntlShape);

/**
 * Use just like `useIntl` for getting strings for the current locale.
 *
 * @export
 * @returns {IntlShape}
 */
export default function useIntl() : IntlShape {
	const context = React.useContext(IntlContext);
	return context;
}