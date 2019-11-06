// License: LGPL-3.0-or-later
var action_recipient = require("./action_recipient")
var request = require('../../../common/client')

appl.def('show_bulk_delete_supporters', function(){
	var total = appl.supporters.selecting_all ? appl.supporters.total_count : appl.supporters.selected.length
	appl
		.def('action_recipient', action_recipient())
		.def('supporters.selected_with_limit', appl.supporters.selected.slice(0,29))
		.def('supporters.remaining', total - appl.supporters.selected_with_limit.length)
		.open_modal('bulkDeleteModal')
})


appl.def('bulk_delete', function() {

  var post_data = {}
  if (appl.supporters.selecting_all)
  {
  	post_data.selecting_all = true
  	post_data.query = appl.supporters.query
  }
  else
  {
  	post_data.supporter_ids = appl.supporters.selected.map(function(s) { return s.id })
  }

  appl.def('loading', true)
  request.put("/nonprofits/" + app.nonprofit_id + "/supporters/bulk_delete")
		.send(post_data)
		.end(function(err, resp){
      appl.def('loading', false)
			if(!resp.ok) return appl.notify('Sorry, we were unable to delete those supporters')
			appl.notify('Supporters successfully removed')
      appl.close_modal()
			appl.supporters.index()
			appl.def('supporters.selected', [])
		})
})

