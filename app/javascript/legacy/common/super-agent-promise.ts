// License: LGPL-3.0-or-later
// super-agent with default json and csrf wrappers
// Also has a Promise api ('.then' and '.catch') rather than the default '.end'

import request from './client';
import type { SuperAgent, SuperAgentRequest } from 'superagent';

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
	post: function (path:string, ...args:unknown[]): SuperAgentRequestWithPerform {
		return convert_to_promise(request.post(path, ...args));
	},

	put: function (path:string, ...args:unknown[]): SuperAgentRequestWithPerform {
		return convert_to_promise(request.put(path, ...args));
	},

	del: function (path:string, ...args:unknown[]): SuperAgentRequestWithPerform {
		return convert_to_promise(request.del(path, ...args));
	},

	get: function (path:string): SuperAgentRequestWithPerform {
		return convert_to_promise(request.get(path));
	},
};

export default wrapper;



