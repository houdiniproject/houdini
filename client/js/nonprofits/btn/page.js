 var Font = require('../../common/brand-fonts'),
     utils = require('../../common/utilities'),
	$brandedButton = $('.branded-donate-button')

  if(utils.get_param('fixed')){
	$brandedButton.addClass('is-fixed')
	$('.centered').css('padding-top', '5px')
  }

  var $logoBlue = '#42B3DF',
	brandColor = app.nonprofit.brand_color || $logoBlue,
	brandFont = Font[app.nonprofit.brand_font] || Font.bitter

  $brandedButton.css({
	'background-color': brandColor,
	'font-family': brandFont 
	}
  )
