/* eslint-disable @typescript-eslint/ban-types */
/// <reference no-default-lib="true"/>

declare namespace Intl {
	import type { DisplayNamesOptions, DisplayNamesResolvedOptions} from '@formatjs/intl-displaynames';

	declare class DisplayNames {
		constructor(locales: string | string[] | undefined, options: DisplayNamesOptions);
		static supportedLocalesOf(locales?: string | string[], options?: Pick<DisplayNamesOptions, 'localeMatcher'>): string[];
		of(code: string | number | object): string | undefined;
		resolvedOptions(): DisplayNamesResolvedOptions;
	}
}
