// License: LGPL-3.0-or-later
// super-agent with default json and csrf wrappers
// Also has a Promise api ('.then' and '.catch') rather than the default '.end'

import request from './client';
import type { SuperAgent, SuperAgentRequest } from 'superagent';
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type CallbackHandlerFromSuperAgent = (err: any, res: Response) => void;

type SuperAgentRequestWithPerform<Request extends SuperAgentRequest=SuperAgentRequest> = SuperAgent<Request> & { perform: () => Promise<any> };

function convert_to_promise<Request extends SuperAgentRequest=SuperAgentRequest>(req: Request): SuperAgentRequestWithPerform<Request> {
	const anyReq = req as unknown as SuperAgentRequestWithPerform<Request>;
	anyReq.perform = function () {
		return new Promise(function (resolve, reject) {
			req.end(function (_err, resp) {
				if (resp && resp.ok) { resolve(resp); }
				else { reject(resp); }
			});
		});
	};
	return anyReq;
}


const wrapper = {
	post: function (...args: [string, CallbackHandlerFromSuperAgent?]): SuperAgentRequestWithPerform {
		return convert_to_promise(request.post(...args));
	},

	put: function (...args: [string, CallbackHandlerFromSuperAgent?]): SuperAgentRequestWithPerform {
		return convert_to_promise(request.put(...args));
	},

	del: function (...args: [string, CallbackHandlerFromSuperAgent?]): SuperAgentRequestWithPerform {
		return convert_to_promise(request.del(...args));
	},

	get: function (path:string): SuperAgentRequestWithPerform {
		return convert_to_promise(request.get(path));
	},
};

export default wrapper;



