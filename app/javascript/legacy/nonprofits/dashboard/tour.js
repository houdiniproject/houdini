// License: LGPL-3.0-or-later
require('../../common/vendor/bootstrap-tour-standalone')

var $nav = $('.sideNav')
var $text = $('.sideNav-text')

function showNav(){
	$nav.css('width', '240px')
	$text.css({
		'-webkit-opacity' : '1',
		'-moz-opacity': '1',
		'-ms-opacity': '1',
		'opacity': '1'
	})
}

function hideNav(){
	$nav.removeAttr('style')
	$text.removeAttr('style')
}

var dashboard_tour = new Tour({
	backdrop: false,
	steps: [
		{
			orphan: true,
			title: 'Welcome to CommitChange!',
			content: "This dashboard will give you a detailed overview of all of your fundraising activities.  As you begin to raise money through donations, contributions and ticket sales, this dashboard will show more helpful information."
		},
		{
			element: '.tour-graph',
			placement: 'bottom',
			title: 'Graph',
			content: "This graph will chart your donation history. You can change the time span from the top of the graph."
		},
		{
			element: '.tour-metrics',
			placement: 'left',
			title: 'Overview metrics',
			content: "These metrics will help show you the big picture of your fundraising."
		},
		{
			element: '.tour-listings',
			placement: 'left',
			title: 'Recent metrics',
			content: "These metrics will help give you a day-to-day picture of your fundraising. You can also create a new campaign or event by simply clicking on one of the orange buttons."
		},
		{
			backdrop: false,
			orphan: true,
			title: 'Navigation',
			content: "To find other parts of our site, such as payments history, settings and your profile page, use the sidebar on the left.",
			onHide: hideNav,
			onShow: showNav,
		},
		{
			orphan: true,
			title: "You're all set!",
			content: "Check your inbox for an email confirmation link. We will verify your status as a nonprofit within 5-7 days. Contact support@commitchange.com if you have any questions. We're glad to have you on board!"
		}
	]
})

if($.cookie('tour_dashboard') === String(app.nonprofit_id)) {
	$.removeCookie('tour_dashboard', {path: '/'})
	dashboard_tour.init()
	dashboard_tour.restart()
}
