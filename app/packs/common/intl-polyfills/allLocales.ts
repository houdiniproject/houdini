// License: LGPL-3.0-or-later
let allLocales = ['en'];

export function setAllLocales(locales:string[]):string[]{
	allLocales = locales;
	return allLocales;
}

export default allLocales;