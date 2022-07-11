// License: LGPL-3.0-or-later
/* eslint-disable @typescript-eslint/member-ordering */

/** based on app/views/app_data/_profile.jbuilder */

export default interface Profile {
	id: string;
	name: string;
	country?: string;
	picture: unknown;
	url: string;
	pic_tiny?: string;
}