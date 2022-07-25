// License: LGPL-3.0-or-later
// from: https://github.com/jayrbolton/flyd-url/blob/master/index.es6
import flyd from 'flyd';

let href = location.href;
const stream = flyd.stream(new URL(href));
let target = Date.now();
const dur = 50;

const poll = () => {
	if(stream.end()) return;
	const now = Date.now();
	target += dur;
	if(href !== location.href) {
		stream(new URL(location.href));
		href = location.href;
	}
	setTimeout(poll, target - now);
};
poll();

export default stream;