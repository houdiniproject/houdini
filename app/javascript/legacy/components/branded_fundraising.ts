// License: LGPL-3.0-or-later
import brandColors  from '../components/nonprofit-branding';
import get from 'lodash/get';

$('[if-branded]').each(function() {
	const params = this.getAttribute("if-branded").split(',').map(function(s) { return s.trim(); });
	$(this).css(params[0], get(brandColors,params[1]));
});

export default brandColors;

