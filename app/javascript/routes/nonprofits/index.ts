// License: LGPL-3.0-or-later
// this will be generated by some route generator in future but for now, we'll handcode it.

export default {
	dashboard_nonprofit_path: (props:{id:string}):string => {
		return `/nonprofits/${props.id}/dashboard`;
	},
	/** not correct but good enough for testing */
	dashboard_nonprofit_url: (props:{id:string}):string => {
		return `/nonprofits/${props.id}/dashboard`;
	},
};