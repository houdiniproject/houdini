// License: LGPL-3.0-or-later

export function appendAll(base:URLSearchParams, toAdd:URLSearchParams):URLSearchParams;
export function appendAll(base:URLSearchParams, toAdd:Record<string, string>):URLSearchParams;
export function appendAll(base:URLSearchParams, toAdd:Record<string, string> | URLSearchParams):URLSearchParams
{
	if (toAdd instanceof URLSearchParams) {
		toAdd.forEach((value, key) => {
			base.append(key, value);
		});
	}
	else {
		for (const key in toAdd) {
			base.append(key, toAdd[key]);
		}
	}

	return base;
}
