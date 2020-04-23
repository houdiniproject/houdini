// License: LGPL-3.0-or-later
require('../../common/vendor/bootstrap-tour-standalone')

var profile_tour = new Tour({
	backdrop: false,
	steps: [
		{
			orphan: true,
			title: 'Welcome to your nonprofit profile!',
			content: "This is a public page where people can donate, create peer-to-peer campaigns and find out about your organization. The more you fill out this page, the richer your donors' experiences will be.",
		},
		{
			element: '.tour-admin',
			placement: 'bottom',
			title: 'Manage your profile',
			content: "You can manage your profile by clicking on these buttons at the top of the page."
		}
	]
})

if($.cookie('tour_profile') === String(app.nonprofit_id)) {
	$.removeCookie('tour_profile', {path: '/'})
	profile_tour.init()
	profile_tour.restart()
}
