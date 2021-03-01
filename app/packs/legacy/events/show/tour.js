// License: LGPL-3.0-or-later
require('../../common/vendor/bootstrap-tour-standalone')

var tour_event = new Tour({
	steps: [
		{
			orphan: true,
			title: 'Welcome to your new event!',
			content: "Hit 'Next' to find out how you can edit and add content to your event before sharing it."
		},
		{
			element: '.tour-admin',
			placement: 'bottom',
			title: 'Manage your event',
			content: "You can manage your event by clicking on these buttons at the top of the page."
		},
		{
			element: '.froala-box',
			placement: 'right',
			title: 'Event details & story',
			content: "You can add and format text and image content for your event by typing in this box. Adding images, video or even custom code can help enliven your event description. Click the icons at the top for formatting."
		},
		{
			orphan: true,
			title: 'You’re on your way!',
			content: "Once you've added content and ticket levels, and can start sharing your event."
		}
	]
})

 if($.cookie('tour_event') === String(app.nonprofit_id)) {
	$.removeCookie('tour_event', {path: '/'})
	tour_event.restart()
}

