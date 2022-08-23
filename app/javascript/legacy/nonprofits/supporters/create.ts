// License: LGPL-3.0-or-later
import show_err from '../../common/format_response_error';
import request from '../../common/super-agent-promise';
import {
	nonprofitsSupportersPath,
}  from '../../../routes';
import type { UI } from '../../types/UI';
import type { Response } from 'superagent';

declare const app: {nonprofit_id:number};

export default function create_supporter(form_obj:Record<string, unknown>, ui:UI): Promise<Response|void> {
	ui.start();
	return request.post(nonprofitsSupportersPath(app.nonprofit_id))
		.send(form_obj).perform()
		.then((resp:Response) => {
			ui.success(resp);
			return resp;
		})
		.catch(function(resp) {
			ui.fail(show_err(resp)||"");
		});
}
