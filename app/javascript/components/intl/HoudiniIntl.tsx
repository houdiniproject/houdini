// License: LGPL-3.0-or-later

import * as React from "react";
import { useIntl, IntlShape, IntlProvider, createIntl} from "react-intl";
import { Money } from "../../common/money";
import { HoudiniIntlContext } from "../../hooks/useHoudiniIntl";
import type {HoudiniIntlShape, FormatMoneyOptions} from '../../hooks/useHoudiniIntl';

function rawFormatMoney(intl:IntlShape, amount:Money, opts?:FormatMoneyOptions) : string  {
	const formatter =  intl.formatters.getNumberFormat(intl.locale, {...opts,
		style: 'currency',
		currency: amount.currency.toUpperCase(),
	});

	const adjustedAmount = amount.amount / Math.pow(10, formatter.resolvedOptions().maximumFractionDigits);
	return formatter.format(adjustedAmount);
}

/**
 * Use this to scope a context to a tree of components.
 * Works like [IntlProvider}(https://formatjs.io/docs/react-intl/components#intlprovider)
 * But includes support for formatting money based on the current locale.
 *
 * @export
 * @param {ConstructorParameters<typeof IntlProvider>[0]} props
 * @returns {JSX.Element}
 */
export default function HoudiniIntlProvider(props:ConstructorParameters<typeof IntlProvider>[0]) : JSX.Element {
	return <IntlProvider {...props}>
		<InnerProvider>
			{props.children}
		</InnerProvider>
	</IntlProvider>;
}

function InnerProvider({children}:{children:React.ReactNode}) : JSX.Element {
	const intl = useIntl();
	const formatMoney = React.useCallback((amount:Money, opts?:FormatMoneyOptions) => {
		return rawFormatMoney(intl, amount, opts);
	}, [intl]);

	const houdiniIntl = 	{ ...intl, formatMoney};
	return <HoudiniIntlContext.Provider value={houdiniIntl}>
		{children}
	</HoudiniIntlContext.Provider>;
}

export function createHoudiniIntl(...props:Parameters<typeof createIntl>) : HoudiniIntlShape {
	const intl = createIntl(...props);
	const formatMoney = (amount:Money, opts?:FormatMoneyOptions) => rawFormatMoney(intl, amount, opts);

	return {...intl, formatMoney};
}