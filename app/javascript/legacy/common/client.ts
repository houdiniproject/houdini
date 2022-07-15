// License: LGPL-3.0-or-later
// superapi wrapper with our api defaults

import request, { SuperAgentRequest } from 'superagent';

declare const window: Window & { _csrf: string };

const wrapper = {

	post: function (path:string, ...args:unknown[]): SuperAgentRequest {
		return (request.post.apply(this, [path, ...args]) as SuperAgentRequest).set('X-CSRF-Token', window._csrf).type('json');
	},

	put: function (path:string, ...args:unknown[]): SuperAgentRequest {
		return (request.put.apply(this, [path, ...args]) as SuperAgentRequest).set('X-CSRF-Token', window._csrf).type('json');
	},

	del: function (path:string, ...args:unknown[]): SuperAgentRequest {
		return (request.del.apply(this, [path, ...args]) as SuperAgentRequest).set('X-CSRF-Token', window._csrf).type('json');
	},

	get: function (path: string): SuperAgentRequest {
		return (request.get.call(this, path) as SuperAgentRequest).accept('json');
	},
};

export default wrapper;

