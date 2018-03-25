// License: LGPL-3.0-or-later
require('../../../common/vendor/bootstrap-tour-standalone')

var supporters_tour = new Tour({
	backdrop: false,
	steps: [
		{
			orphan: true,
			title: 'Welcome to your supporters dashboard!',
			content: "This page is the hub for all of your supporter data and supporter related actions, such as emailing, tagging, merging, adding notes and more. You'll notice that there is not much data here yet. Click 'Next' to find out how to import supporter data."  
		},
		{
			orphan: true,
			title: 'Importing supporter data 1/3',
			content: "There are three ways that supporter data can be added to the CRM. The first method is automatic - whenever anyone makes a donation, contributes to a campaign or buys a ticket to an event, their information is automatically added  here.  That means no more tedious data entry for you or your team."
		},
		{
			element: '.tour-addSupporter',
			placement: 'left',
			title: 'Importing supporter data 2/3',
			content: "The second method is manually - you can simply add a supporter by clicking on this button and adding the new supporter's info into a form."
		},
		{
			element: '.tour-import',
			placement: 'left',
			title: 'Importing supporter data 3/3',
			content: "The third method is to import your supporter data.  You can click this button and we'll walk you through the import process. "
		},
		{
			element: '.tour-supporters',
			placement: 'top',
			title: 'Supporter profile 1/2',
			content: "Clicking on a supporter's row will open up that supporter's panel. The supporter panel shows that supporter's details, a timeline of their activities and actions."
		},
		{
			element: '.sidePanel',
			placement: 'left',
			title: 'Supporter profile 2/2',
			onShow: openSidePanel,
			onHide: appl.close_side_panel,
			content: "From the supporter panel, you can edit the supporter's fields, add notes, tag, send an email or add an offline donation.  All activity tied to the supporter, such as sending an email or attending an event, will automatically be added to their timeline. In addition, if the supporter has any publicly available social media data, we will add it to this panel."
		},
		{
			element: '.tour-bulk',
			placement: 'bottom',
			title: 'Bulk actions',
			onShow: showBulkActions,
			onHide: hideBulkActions,
			content: "To access your bulk actions, just click on the supporters' checkboxes that you want to perform the bulk action on.  To perform a bulk action on all of your supporters, click the checkbox on the top left corner."
		},
		{
			orphan: true,
			title: 'Need more help?',
			content: "There are still more features in our CRM that we weren't able to cover on this tour, such as creating email templates and adding donate buttons to your supporter emails. If you want a walk-through of any features or have any questions or comments, please email support@commitchange.com. We're here to help."
		}
	]
})

if($.cookie('tour_supporters') === String(app.nonprofit_id)) {
	$.removeCookie('tour_supporters', {path: '/'})
	supporters_tour.init()
	supporters_tour.restart()
}


function openSidePanel(){
	if(!appl.supporters.data){return}
	appl.def('supporter_details.data', appl.supporters.data[0])
	appl.open_side_panel()
}

function showBulkActions(){
	if(!appl.supporters.data){return}
	appl.def('supporters.data', set_checked(appl.supporters.data, true))
	appl.def('supporters.selected', appl.supporters.data)
}

function hideBulkActions(){
	appl.def('supporters.data', set_checked(appl.supporters.data, false))
	appl.def('supporters.selected', '')
}

function set_checked(supporters, state) {
	return supporters.map(function(s) {s.is_checked = state; return s})
}

