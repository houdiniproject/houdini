// License: LGPL-3.0-or-later
const promises = Promise.all([
	import('./getCanonicalLocales'),
	import('./pluralRules'),
	import('./numberFormat'),
	import('./locale'),
	import('./displayNames'),
]) as unknown as Promise<void>;

export default promises;
