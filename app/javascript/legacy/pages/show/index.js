// License: LGPL-3.0-or-later
var editable = require('../../common/editable')

if(app.current_admin)
	editable($('.editable'), {sticky: true})
