// License: LGPL-3.0-or-later
declare const app: {header_image_url?:string};

if(app.header_image_url) {
	const cssString =  "display: block; background-image: url("  + app.header_image_url + ")";
	const header = document.getElementById('js-fundraisingHeader');
	if (header) {
		header.className ='fundraisingHeader--image container';
	}

	const headerImage = document.getElementById('js-fundraisingHeader-image');

	if (headerImage) {
		headerImage.style.cssText = cssString;
	}
}
