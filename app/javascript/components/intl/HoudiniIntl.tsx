// License: LGPL-3.0-or-later

import * as React from "react";
import { useIntl as useIntlParent,
	IntlShape as IntlShapeParent,
	IntlProvider as IntlProviderParent,
	createIntl as createIntlParent} from "react-intl";
import { Money } from "../../common/money";
import { IntlContext } from "../../hooks/useIntl";
import type {IntlShape, FormatMoneyOptions} from '../../hooks/useIntl';


function rawFormatMoney(intl:IntlShapeParent, amount:Money, opts?:FormatMoneyOptions) : string  {
	const formatter =  intl.formatters.getNumberFormat(intl.locale, {...opts,
		style: 'currency',
		currency: amount.currency.toUpperCase(),
	});

	const adjustedAmount = amount.toBigNumber().dividedBy(Math.pow(10, formatter.resolvedOptions().maximumFractionDigits || 0));
	return formatter.format(adjustedAmount.toNumber());
}

/**
 * Use this to scope a context to a tree of components.
 * Works like [IntlProvider}(https://formatjs.io/docs/react-intl/components#intlprovider)
 * But includes support for formatting money based on the current locale.
 *
 * @export
 * @param {ConstructorParameters<typeof IntlProviderParent>[0]} props
 * @returns {JSX.Element}
 */
export default function IntlProvider(props:ConstructorParameters<typeof IntlProviderParent>[0]) : JSX.Element {
	return <IntlProviderParent {...props}>
		<InnerProvider>
			{props.children}
		</InnerProvider>
	</IntlProviderParent>;
}

function InnerProvider({children}:{children:React.ReactNode}) : JSX.Element {
	const intl = useIntlParent();
	const formatMoney = React.useCallback((amount:Money, opts?:FormatMoneyOptions) => {
		return rawFormatMoney(intl, amount, opts);
	}, [intl]);

	const houdiniIntl = 	{ ...intl, formatMoney};
	return <IntlContext.Provider value={houdiniIntl}>
		{children}
	</IntlContext.Provider>;
}

export function createIntl(...props:Parameters<typeof createIntlParent>) : IntlShape {
	const intl = createIntlParent(...props);
	const formatMoney = (amount:Money, opts?:FormatMoneyOptions) => rawFormatMoney(intl, amount, opts);

	return {...intl, formatMoney};
}