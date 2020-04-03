// License: LGPL-3.0-or-later
 var Font = require('../../common/brand-fonts'),
     utils = require('../../common/utilities'),
	$brandedButton = document.querySelectorAll('.branded-donate-button')

  if(utils.get_param('fixed')){
	  $brandedButton.forEach((elem) => elem.classList.add('is-fixed'))
	
	document.querySelectorAll('.centered').forEach((elem) => elem.style.paddingTop = '5px')
  }

  var $logoBlue = '#42B3DF',
	brandColor = app.nonprofit.brand_color || $logoBlue,
	brandFont = Font[app.nonprofit.brand_font] || Font.bitter

	$brandedButton.forEach((elem) => {
		elem.style.backgroundColor = brandColor
		elem.style.fontFamily = brandFont
	});
  
