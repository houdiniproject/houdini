

import React, { useEffect, useState } from 'react';
import { RailsContext } from "react-on-rails/node_package/lib/types";
import { Hoster, HosterContext } from "../../hooks/useHoster";

import ReactOnRails from "react-on-rails";
import { convert } from 'dotize'
import { IntlProvider } from '../intl';
import { useDeepCompareEffect } from 'react-use';

const I18n = require('../../i18n').default

export interface PageContextInput {
	currentUser?: number | null;
	hoster: Hoster;
	i18n: {
		defaultLocale: string;
		locale: string;
	};
	innerProps: Record<string, unknown>;
	railsContext: RailsContext;
}

export interface PageContext {
	authenticityToken: () => string | null;
	currentUser?: number | null;
	hoster: Hoster;
	i18n: {
		defaultLocale: string;
		locale: string;
	};
}


export default function PageWrapper(props: React.PropsWithChildren<PageContextInput>): JSX.Element {

	// eslint-disable-next-line @typescript-eslint/no-unused-vars
	const { railsContext, innerProps, children, ...other } = props;


	const [pageContext, setPageContext] = useState<PageContext | null>(null);

	useDeepCompareEffect(() => {
		setPageContext({
			...other,
			authenticityToken: ReactOnRails.authenticityToken,
		})
	}, [other])

	return (pageContext && <HosterContext.Provider value={pageContext.hoster}>
		<IntlProvider locale={pageContext.i18n.locale} messages={convert(I18n.translations[I18n.locale]) as any}>
			{props.children}
		</IntlProvider>
	</HosterContext.Provider>);
}