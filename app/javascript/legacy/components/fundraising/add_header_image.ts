// License: LGPL-3.0-or-later
if(app.header_image_url) {
	var cssString =  "display: block; background-image: url("  + app.header_image_url + ")"
	document.getElementById('js-fundraisingHeader').className ='fundraisingHeader--image container'
	document.getElementById('js-fundraisingHeader-image').style.cssText = cssString
}
