// License: LGPL-3.0-or-later

import {shouldPolyfill} from '@formatjs/intl-pluralrules/should-polyfill';
import type {Polyfilled} from './types';

import getCanonicalLocales from './getCanonicalLocales';

type PolyfilledPluralRules = Polyfilled<typeof Intl.PluralRules>

export default async function pluralRules(locales:string[]):Promise<void> {
	await getCanonicalLocales();
	if (shouldPolyfill()) {
		// Load the polyfill 1st BEFORE loading data
		await import('@formatjs/intl-pluralrules/polyfill');
	}

	if ((Intl.PluralRules as PolyfilledPluralRules).polyfilled) {
		await Promise.all(
			locales.map(l => import("@formatjs/intl-pluralrules/locale-data/"+ l))
		);
	}
}