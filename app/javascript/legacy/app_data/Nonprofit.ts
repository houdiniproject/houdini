// License: LGPL-3.0-or-later
/* eslint-disable @typescript-eslint/member-ordering */

/** based on app/views/app_data/_nonprofit.jbuilder */
export default interface Nonprofit {
	id: string;
	name: string;

	/** brand */
	brand_color?: string;
	brand_font?: string;
	tagline?: string;

	/** location */
	zip_code: string;
	state_code: string;
	city: string;
	slug: string;

	/** slugs */
	state_code_slug: string;
	city_slug: string;

	/** options */
	no_anon?: boolean;

	url: string;

	logo: {
		normal: string;
		small: string;
	};
}