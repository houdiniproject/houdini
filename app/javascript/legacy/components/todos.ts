// License: LGPL-3.0-or-later
import request from '../common/client';
import {
	nonprofitPath,
} from '../../routes';

import type { ApplWithTodos } from '../types/appl';


declare const app: { nonprofit_id: string };
declare const appl: ApplWithTodos;

export default function todos(cb: (data: unknown, url: string) => void): void {

	appl.def('todos.loading', true);

	const url = nonprofitPath(app.nonprofit_id);

	// data returns booleans
	request.get(appl.todos_action).end(function (_err, resp) {
		if (!resp.ok) return;
		const data = resp.body;

		cb(data, url);

		appl.def('todos.loading', false);
		appl.def('todos.percent_done', todos_percentage());
	});

	function todos_percentage(): number {
		let finished_todos = 0;
		appl.todos.items.forEach(function (item) {
			if (item.done) finished_todos += 1;
		});
		return Math.floor(finished_todos / appl.todos.items.length * 100);
	}
}
