// License: LGPL-3.0-or-later
/* eslint-disable @typescript-eslint/member-ordering */
/** based on app/views/app_data/_user_with_profile_as_child.jbuilder */

import Profile from "./Profile";

export default interface UserWithProfileAsChild {
	id: string;
	created_at: string;
	updated_at: string;
	email: string;
	unconfirmed_email?: string;
	confirmed: boolean;
	profile?:Profile;
}
