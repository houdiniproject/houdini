// License: LGPL-3.0-or-later
import {UrlWithStringQuery as NodeUrl} from 'url';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const queryString = require('query-string');

/**
 * @deprecated
 */

export function getSidFromNodeUrlQS(url:NodeUrl| URL): string | undefined {
	return queryString.parse(url.search).sid as string | undefined;
}

/**
 *
 * @param url
 * @return The value if it exists or undefined (to be consistent with the previous implementation)
 */
export function getSidFromNodeUrl(url:NodeUrl | URL ): string | undefined {
	const result = new URLSearchParams(url.search).get("sid");
	return result === null ? undefined : result;
}

export default getSidFromNodeUrl;