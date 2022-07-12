// License: LGPL-3.0-or-later
// superapi wrapper with our api defaults

import request, { Response, SuperAgentRequest } from 'superagent';
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type CallbackHandlerFromSuperAgent = (err: any, res: Response) => void;

declare const window: Window & { _csrf: string };
const wrapper = {

	post: function (...args: [string, CallbackHandlerFromSuperAgent?]): SuperAgentRequest {
		return (request.post.apply(this, args) as SuperAgentRequest).set('X-CSRF-Token', window._csrf).type('json');
	},

	put: function (...args: [string, CallbackHandlerFromSuperAgent?]): SuperAgentRequest {
		return (request.put.apply(this, args) as SuperAgentRequest).set('X-CSRF-Token', window._csrf).type('json');
	},

	del: function (...args: [string, CallbackHandlerFromSuperAgent?]): SuperAgentRequest {
		return (request.del.apply(this, args) as SuperAgentRequest).set('X-CSRF-Token', window._csrf).type('json');
	},

	get: function (path: string): SuperAgentRequest {
		return (request.get.call(this, path) as SuperAgentRequest).accept('json');
	},
};

export default wrapper;

