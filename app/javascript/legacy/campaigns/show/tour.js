// License: LGPL-3.0-or-later
require('../../common/vendor/bootstrap-tour-standalone')

var tour_campaign = new Tour({
	steps: [
		{
			orphan: true,
			title: 'Welcome to your new campaign!',
			content: "Click 'Next' to find out how you can flesh out your campaign before sharing it."
		},
		{
			title: 'Manage your campaign',
			placement: 'bottom',
			element: '.tour-admin',
			content: "You can manage your campaign by clicking on these buttons at the top of the page."
		},
		{
			element: '.froala-box',
			title: 'Write your story',
			content: "Every successful campaign has a powerful story. Write and edit your story in the area to the left. You can add formatting by clicking the icons at the top of this box."
		},
		{
			orphan: true,
			title: 'You’re on your way!',
			content: "Once you’ve written your campaign story and added gift options, you can start sharing it with all your contacts. We’re excited for it to succeed!"
		}
	]
})

if($.cookie('tour_campaign') === String(app.nonprofit_id)) {
	$.removeCookie('tour_campaign', {path: '/'})
	tour_campaign.init()
	tour_campaign.restart()
}

