// License: LGPL-3.0-or-later

import sanitize from './sanitize-slug';

// Just a hacky way to automatically sanitize slug inputs when they are changed

const inputs = document.querySelectorAll<HTMLInputElement>('.js-sanitizeSlug');
inputs.forEach(
	(inp) =>
		inp.addEventListener('change',
			(ev) => {
				const inputTarget = ev.currentTarget as HTMLInputElement;
				inputTarget.value = sanitize(inputTarget.value || inputTarget.getAttribute('data-slug-default') || "");
			})
);


