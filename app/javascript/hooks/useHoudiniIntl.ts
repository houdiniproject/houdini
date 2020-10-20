// License: LGPL-3.0-or-later
import * as React from "react";
import type { FormatNumberOptions, IntlShape } from "react-intl";
import { Money } from "../common/money";

export declare type FormatMoneyOptions = Omit<FormatNumberOptions,'style'|'unit'|'unitDisplay'|'currency'>;

export declare type HoudiniIntlShape = IntlShape & {
	/**
	 * Format a monetary value as a string given the locale
	 *
	 * @param {Money} amount the monetary value to convert to a string
	 * @param {FormatMoneyOptions} [opts] options for controlling how the string should be formatted
	 * @returns {string}
	 */
	formatMoney(amount: Money, opts?: FormatMoneyOptions): string;
};

export const HoudiniIntlContext = React.createContext<HoudiniIntlShape>(null as HoudiniIntlShape);

/**
 * Use just like `useIntl` for getting strings for the current locale.
 *
 * @export
 * @returns {HoudiniIntlShape}
 */
export default function useHoudiniIntl() : HoudiniIntlShape {
	const context = React.useContext(HoudiniIntlContext);
	return context;
}