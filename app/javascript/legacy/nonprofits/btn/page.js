// License: LGPL-3.0-or-later
 const Font = require('../../common/brand-fonts');
const utils = require('../../common/utilities');
const $brandedButton = $('.branded-donate-button');

  if(utils.get_param('fixed')){
	$brandedButton.addClass('is-fixed')
	$('.centered').css('padding-top', '5px')
  }

  const $logoBlue = '#42B3DF',
	brandColor = app.nonprofit.brand_color || $logoBlue,
	brandFont = Font[app.nonprofit.brand_font] || Font.bitter

  $brandedButton.css({
	'background-color': brandColor,
	'font-family': brandFont 
	}
  )
