// License: LGPL-3.0-or-later
// custom decorators we use for APIs
import {addResponse}  from  '../../app/javascript/legacy_react/src/lib/api/sign_in';

const decorators = {
	"users/sign_in": function (story, {parameters}) {
		if (parameters && parameters.api && parameters.api.users && parameters.api.users.sign_in) {
			const sign_in = parameters.api.users.sign_in
			if (sign_in.status) {
				const nextResponse = {
					status:  parameters.api.users.sign_in.status, 
					data: parameters.api.users.sign_in.data
				}
				addResponse(nextResponse);
			}
		}
		return story();
	}
}

export default decorators;