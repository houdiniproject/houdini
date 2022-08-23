// License: LGPL-3.0-or-later
import {createContext, useContext} from "react";

/**
 * A context which provides information about the hoster
 */
export const HosterContext = createContext<Hoster|undefined>(undefined);

/**
 * Information about the Houdini instance Hoster
 *
 * @export
 * @interface Hoster
 */
export interface Hoster {
	casual_name: string;
	legal_name?: string;
	main_admin_email?: string;
	support_email?: string;
	terms_and_privacy?:{
		about_url?: string;
		help_url?: string;
		privacy_url?: string;
	};
}


/**
 * Get information about the hoster
 *
 * @export
 * @returns {Hoster} or null
 */
export default function useHoster() : Hoster|undefined {
	const hoster = useContext(HosterContext);

	return hoster;
}