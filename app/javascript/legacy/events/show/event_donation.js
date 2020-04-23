// License: LGPL-3.0-or-later
$('.ticket-level').click(function(e) {
	wiz.model.set('single_amount', $(this).data('dollars'))
	wiz.model.set('designation', $(this).data('name'))
	wiz.model.set('description', $(this).data('desc'))
	wiz.ticket_level_id = $(this).data('id')
	wiz.donation.set({
		amount: $(this).data('amount'),
		designation: $(this).data('name')
	})
})

$('.nonprofit-donate-button').click(function() {
	wiz.model.set('single_amount', undefined)
	wiz.model.set('designation', undefined)
	wiz.model.set('description', undefined)
	wiz.ticket_level_id = undefined
	wiz.donation.set({
		amount: undefined,
		designation: undefined
	})
})

$('.anon-wrapper').hide()
$('.info-submit').text('Submit')

module.exports = wiz
