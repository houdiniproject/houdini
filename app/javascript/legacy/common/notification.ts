// License: LGPL-3.0-or-later

export default function notification(msg: string, err: unknown):void {
	const el = document.getElementById('js-notification');
	if (el) {
		if (err) { el.className = 'show error'; }
		else { el.className = 'show'; }
		el.innerText = msg;
		window.setTimeout(function () {
			el.className = '';
			el.innerText = '';
		}, 7000);
	}
}

