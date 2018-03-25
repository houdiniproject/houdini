// License: LGPL-3.0-or-later
window.$ = require("jquery")
window.jQuery = window.$
window.domify = require("domify")
window.app = {}
require("../../../app/assets/javascripts/common/vendor/jquery.cookie")

$(document).ready(function(){
	window.appl = require("../../../app/assets/javascripts/common/application_view")
	require("./utilities_spec")
})
