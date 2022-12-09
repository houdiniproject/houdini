// License: LGPL-3.0-or-later
 const Font = require('../../common/brand-fonts'),
$brandedButton = document.querySelectorAll('.branded-donate-button');

	// from utils because utils is huge
	function get_param(name) {
		const param = decodeURI((RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) || [null])[1])
		return (param == 'undefined') ? undefined : param
	}

  if(get_param('fixed')){
	  $brandedButton.forEach((elem) => elem.classList.add('is-fixed'))
	
	document.querySelectorAll('.centered').forEach((elem) => elem.style.paddingTop = '5px')
  }

  const $logoBlue = '#42B3DF',
	brandColor = app.nonprofit.brand_color || $logoBlue,
	brandFont = Font[app.nonprofit.brand_font] || Font.bitter

	$brandedButton.forEach((elem) => {
		elem.style.backgroundColor = brandColor
		elem.style.fontFamily = brandFont
	});
  
