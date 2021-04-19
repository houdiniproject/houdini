// License: LGPL-3.0-or-later

/**
 * Describes the hoster of this instance of Houdini
 */
export interface Hoster {
	casual_name: string;
	legal_name: string;
	main_admin_email: string;
	support_email: string;
	terms_and_privacy:{
		about_url?: string;
		help_url?: string;
		privacy_url?: string;
	};
}