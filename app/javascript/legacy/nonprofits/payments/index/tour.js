// License: LGPL-3.0-or-later
require('../../../common/vendor/bootstrap-tour-standalone')

var transactions_tour = new Tour({
	backdrop: false,
	steps: [
		{
			orphan: true,
			title: 'Welcome to your payments history dashboard!',
			content: "This page shows your complete payments history. This includes donations through your website, campaign contributions, tickets for events, and offline checks."
		},
		{
			element: '.tour-filter',
			placement: 'right',
			title: 'Filtering & searching',
			content: "Filter your payments using this panel. You can also use the search bar at the top to search by donor name or email.",
			onHide: appl.close_filter_panel,
			onShow: appl.open_filter_panel,
		},
		{
			element: '.tour-totalPayments',
			placement: 'bottom',
			title: 'Pending balance',
			content: "This is your organization's pending balance. This amount is held temporarily in escrow until it is withdrawn into your organization's bank account."
		},
		{
			element: '.tour-payouts',
			placement: 'bottom',
			title: 'Payouts dashboard',
			content: "To setup payouts and to see your payout history, you can click on this tab."
		},
		{
			orphan: true,
			title: 'Check back!',
			content: "As your organization starts to receive donations and contributions and to sell event tickets, check back here to watch your pending balance increase. Please contact support@commitchange.com if you have questions."
		}
	]
})

if($.cookie('tour_transactions') === String(app.nonprofit_id)) {
	$.removeCookie('tour_transactions', {path: '/'})
	transactions_tour.init()
	transactions_tour.restart()
}

