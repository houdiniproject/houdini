// License: LGPL-3.0-or-later
var tour_subscribers = new Tour({
	backdrop: false,
	steps: [
		{
			orphan: true,
			title: 'Welcome to your recurring payments dashboard!',
			content: "This is where all of your recurring donations will automatically appear.  You can also manually add new recurring donations here with a few easy steps."
		},
		{
			element: '.tour-totalRecurring',
			title: 'Monthly total',
			placement: 'bottom',
			content: 'Your recurring donations per month will be totaled here. Even if the donations are quarterly or annual, they will be calculated into this monthly balance.'
		},
		{
			element: '.tour-export',
			placement: 'left',
			title: 'Export',
			content: 'If you need a report of your subscribers, use this Export button. It will download an excel file of all recurring donors.'
		},
		{
			element: '.tour-newSubscriber',
			placement: 'left',
			title: 'New subscriber button',
			content: "To manually create a new custom recurring donation, use this button. You can specify the time interval as biweekly, monthly, quarterly, annual, or anything else. It's very flexible!"
		},
		{
			orphan: true,
			title: 'Get fundraising!',
			content: "Check back to this page to see your monthly total increase. Please contact support@commitchange.com if you have any questions."
		}
	]
})

if($.cookie('tour_subscribers') === String(app.nonprofit_id)) {
	$.removeCookie('tour_subscribers', {path: '/'})
	tour_subscribers.init()
	tour_subscribers.restart()
}
