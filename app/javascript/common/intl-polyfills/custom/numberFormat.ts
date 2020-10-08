// License: LGPL-3.0-or-later
import {shouldPolyfill} from '@formatjs/intl-numberformat/should-polyfill';

import pluralRules from './pluralRules';

import type {Polyfilled} from './types';

type PolyfilledNumberFormat = Polyfilled<typeof Intl.NumberFormat>

export default async function numberFormat(locales:string[]) :Promise<void> {
	await pluralRules(locales);
	if (shouldPolyfill()) {
		// Load the polyfill 1st BEFORE loading data
		await import('@formatjs/intl-numberformat/polyfill');
	}

	if ((Intl.NumberFormat as PolyfilledNumberFormat).polyfilled) {
		await Promise.all(
			locales.map(l => import("@formatjs/intl-numberformat/locale-data/"+ l))
		);
	}
}