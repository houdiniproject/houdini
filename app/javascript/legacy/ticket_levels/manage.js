// License: LGPL-3.0-or-later
var request = require('../common/client')
var path = '/nonprofits/' + app.nonprofit_id + '/events/' + appl.event_id + '/ticket_levels'
const reorder = require('../components/drag-to-reorder')

reorder(`${path}/update_order`, 'js-reorderTickets')

module.exports = index_ticket_levels

appl.def('ticket_levels', {
  show_create_or_edit: function(action, i){
    var reset = {name: '', amount: 0, limit: '', id: '', description: ''}
    appl.def('ticket_levels', {
      currently_editing: action === 'edit' ? appl.ticket_levels.data[i] : reset,
      current_action: action
    })
    appl.open_modal('ticketLevelCreateOrEditModal')
  },
  create_or_edit: function(form_obj){
    appl.is_loading()
    if(appl.ticket_levels.current_action === 'edit')
      edit_ticket_level(form_obj)
    else
      create_ticket_level(form_obj)
  },
  delete: function(id){
    request.del(path + '/' + id).end(function(err, resp){
        after_ticket_level_ajax(err, 'delete')
    })
  }
})


function index_ticket_levels(path, cb){
  appl.is_loading()
  request.get(path).end(function(err, resp) {
    appl.def('ticket_levels.data', resp.body.data.map(augment_ticket_level_data))
    if(cb){cb()}
    appl.not_loading()
  })

  function augment_ticket_level_data(data) {
    if (data.amount === 0) 
      data.formatted_amount = 'Free'
    else 
      data.formatted_amount = '$' + appl.cents_to_dollars(data.amount)
    if (data.limit)
      data.remaining = data.limit - data.quantity
    if (data.remaining <= 0)
      data.sold_out = true
    return data
  }  
}



function edit_ticket_level(form_obj) {
  request.put(path + '/' + form_obj.id, form_obj).end(function(err, resp){
    after_ticket_level_ajax(err, 'update')
  })
}


function create_ticket_level(form_obj) {
  request.post(path, form_obj).end(function(err, resp){
    after_ticket_level_ajax(err, 'create')
  })
}


function after_ticket_level_ajax(err, action) {
  appl.not_loading()
  if(err) 
   appl.notify("Sorry, we weren't able to " + action + " your ticket.  Please try again in a moment.")
  else {
   appl.notify('Ticket level succesfully ' + action + 'd.')
   index_ticket_levels(path)
   appl.open_modal('manageTicketLevelsModal')
  } 
}

index_ticket_levels(path)
