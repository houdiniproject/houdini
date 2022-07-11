// License: LGPL-3.0-or-later
/* eslint-disable @typescript-eslint/member-ordering */

import Profile from "./profile";

/** based on app/views/app_data/_user.jbuilder */

export default interface User {
	id: string;
	created_at: string;
	updated_at: string;
	email: string;
	unconfirmed_email?: string;
	confirmed: boolean;
	profile?:Profile;
}
