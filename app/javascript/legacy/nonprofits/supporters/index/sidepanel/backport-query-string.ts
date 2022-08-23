// License: LGPL-3.0-or-later

/**
 *
 * @param url
 * @return The value if it exists or undefined (to be consistent with the previous implementation)
 */
export function getSidFromNodeUrl(url: URL ): string | undefined {
	const result = new URLSearchParams(url.search).get("sid");
	return result === null ? undefined : result;
}

export default getSidFromNodeUrl;