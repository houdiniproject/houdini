// License: LGPL-3.0-or-later
import {shouldPolyfill} from '@formatjs/intl-getcanonicallocales/should-polyfill';
export default async function getCanonicalLocales(): Promise<void> {
	if (shouldPolyfill()) {
		await import('@formatjs/intl-getcanonicallocales/polyfill');
	}
}