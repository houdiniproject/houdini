// License: LGPL-3.0-or-later
// superapi wrapper with our api defaults

import request, { SuperAgentRequest } from 'superagent';

declare const window: Window & { _csrf: string };

// from 'superagent' because it's not exported
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type CallbackHandler = (err: any, res: request.Response) => void;

const wrapper = {

	post: function (path:string, callback?:CallbackHandler): SuperAgentRequest {
		return (request.post.apply(this, [path, callback]) as SuperAgentRequest).set('X-CSRF-Token', window._csrf).type('json');
	},

	put: function (path:string, callback?:CallbackHandler): SuperAgentRequest {
		return (request.put.apply(this, [path, callback]) as SuperAgentRequest).set('X-CSRF-Token', window._csrf).type('json');
	},

	del: function (path:string, callback?:CallbackHandler): SuperAgentRequest {
		return (request.del.apply(this, [path, callback]) as SuperAgentRequest).set('X-CSRF-Token', window._csrf).type('json');
	},

	get: function (path: string): SuperAgentRequest {
		return (request.get.call(this, path) as SuperAgentRequest).accept('json');
	},
};

export default wrapper;

