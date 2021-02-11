// License: LGPL-3.0-or-later
import {shouldPolyfill} from '@formatjs/intl-displaynames/should-polyfill';

import getCanonicalLocales from './getCanonicalLocales';
import locale from './locale';
import type {Polyfilled} from './types';

type PolyfilledDisplayNames = Polyfilled<typeof Intl.DisplayNames>

export default async function displaynames(locales:string[]) :Promise<void> {
	await locale();
	await getCanonicalLocales();
	if (shouldPolyfill()) {
		// Load the polyfill 1st BEFORE loading data
		await import('@formatjs/intl-displaynames/polyfill');
	}

	if ((Intl.DisplayNames as PolyfilledDisplayNames).polyfilled) {
		await Promise.all(
			locales.map(l => import("@formatjs/intl-displaynames/locale-data/"+ l))
		);
	}
}