// License: LGPL-3.0-or-later
 var Font = require('../../common/brand-fonts'),
     utils = require('../../common/utilities'),
	$brandedButton = document.querySelector('.branded-donate-button')

  if(utils.get_param('fixed')){
	$brandedButton.classList.add('is-fixed')
	var element = document.querySelector('.centered')
	element.style.paddingTop = '5px'
  }

  var $logoBlue = '#42B3DF',
	brandColor = app.nonprofit.brand_color || $logoBlue,
	brandFont = Font[app.nonprofit.brand_font] || Font.bitter

$brandedButton.style.backgroundColor = brandColor;
$brandedButton.style.fontFamily = brandFont;
  
