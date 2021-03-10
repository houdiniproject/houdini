// License: LGPL-3.0-or-later
import {createContext, useContext} from "react";

/**
 * A context which provides information about the hoster
 */
export const HosterContext = createContext<{hoster?:Hoster|null}|null>(null);

/**
 * Information about the Houdini instance Hoster
 *
 * @export
 * @interface Hoster
 */
export interface Hoster {
	legalName:string;
}
/**
 * Information about the current user
 */
interface UseHoster {
	hoster?: Hoster;
}

/**
 * Get information about the hoster
 *
 * @export
 * @returns {UseHoster}
 */
export default function useHoster() : UseHoster {
	const {hoster} = useContext(HosterContext);

	return {hoster} as UseHoster;
}