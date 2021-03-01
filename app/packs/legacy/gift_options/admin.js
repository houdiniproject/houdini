// License: LGPL-3.0-or-later
require('../common/restful_resource')
const reorder = require('../components/drag-to-reorder')
const format = require('../common/format')
const R = require('ramda')

const url = `/nonprofits/${app.nonprofit_id}/campaigns/${app.campaign_id}/campaign_gift_options/update_order`

reorder(url, 'js-reorderGifts', appl.ajax_gift_options.index)

appl.def('ajax_gift_options', {

	update: function(form_obj, node) {
		if(checkForAmount(form_obj)){
			return
		}
		var id = appl.gift_options.current.id
		appl.ajax.update('gift_options', id, form_obj, node).then(function(resp) {
			node.parentNode.reset()
			appl.def('loading', false)
			appl.ajax_gift_options.index()
			appl.notify('Gift option updated successfully')
			appl.open_modal('manageGiftOptionsModal')
		})
	},

	create: function(form_obj, node) {
		if(checkForAmount(form_obj)){
			return
		}
		appl.ajax.create('gift_options', form_obj, node).then(function(resp) {
			node.parentNode.reset()
			appl.def('loading', false)
			appl.open_modal('manageGiftOptionsModal')
			appl.notify('Gift option created successfully')
			appl.ajax_gift_options.index()
		})
	},

	del: function(id, node) {
		var task = appl.ajax.del('gift_options', id, node)
		task.then(function(resp) {
			appl.open_modal('manageGiftOptionsModal')
			appl.notify('Gift option removed successfully')
			appl.ajax_gift_options.index()
		})
		task.catch(function(resp){
            appl.open_modal('manageGiftOptionsModal')
            appl.notify('This gift option has already been used. It can\'t be removed')
            appl.ajax_gift_options.index()
		})
	},

// Update or create a gift option depending on which mode we're in
	save: function(form_obj, node) {
    // the server expects both amount_one_time and amount_recurring to have 
    // a number value and this function passes in '0' as a fallback in the 
    // case that either input is left blank by the user
    const toCents = x => format.dollarsToCents(x || '0')

    var data = R.evolve({
        amount_one_time: toCents 
      , amount_recurring: toCents
      }, form_obj)
		if(appl.gift_options.is_updating) {
			appl.ajax_gift_options.update(data, node)
		} else {
			appl.ajax_gift_options.create(data, node)
		}
	},
})


function checkForAmount(form_obj) {
	if(!form_obj.amount_one_time && !form_obj.amount_recurring) {
		appl.notify('Please enter at least one amount')
		return true
	} else {
		return false
	}
}

appl.def('gift_options', {
	resource_name: 'campaign_gift_options',
	path_prefix: '/nonprofits/' + app.nonprofit_id + '/campaigns/' + app.campaign_id + '/',

	open_edit: function(gift_option) {
		appl.def('gift_options', {current: gift_option, is_updating: true})
			.def('gift_option_action', 'Edit')

		appl.open_modal('giftOptionFormModal')
	},

	open_new: function() {
		appl.def('gift_options', {current: undefined, is_updating: false})
			.def('gift_option_action', 'New')
		document.querySelector("#giftOptionFormModal form").reset()
		appl.open_modal('giftOptionFormModal')
	}
})

