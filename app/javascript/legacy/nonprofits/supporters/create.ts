// License: LGPL-3.0-or-later
import request from '../../common/super-agent-promise';
import {
 nonprofitsSupportersPath
}  from '../../../routes';


export default function create_supporter(form_obj, ui) {
	ui.start()
	return request.post(nonprofitsSupportersPath(app.nonprofit_id))
		.send(form_obj).perform()
		.then(function(resp) {
			ui.success(resp)
			return resp
		})
		.catch(function(resp) {
			ui.fail(show_err(resp))
		})
}
