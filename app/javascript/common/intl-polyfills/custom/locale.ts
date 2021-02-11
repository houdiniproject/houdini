import {shouldPolyfill} from '@formatjs/intl-locale/should-polyfill';

export default async function locale(): Promise<void> {
	// This platform already supports Intl.Locale
	if (shouldPolyfill()) {
		await import('@formatjs/intl-locale/polyfill');
	}
}