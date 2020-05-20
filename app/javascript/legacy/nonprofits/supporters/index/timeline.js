// License: LGPL-3.0-or-later

appl.def('timeline.make_clickable', function(node){
  var card = appl.prev_elem(node)
  card.setAttribute('clickable', '')
})

appl.def('timeline.show_email', function(email, date) {
  email.date = date
  set_readonly_email(email)
	appl.open_modal('emailReadOnlyModal')
})

appl.def('timeline.show_note', function(note, date) {
  appl.def('current_note', {
    date: date,
    content: note.content,
    id: note.id,
    is_editing: false
  })
	appl.open_modal('noteModal')
})

function set_readonly_email(email) {
	appl.def('timeline.displaying_email', {
		body: email.body.replace(/{{NAME}}/g, appl.supporter_details.data.name_email_or_id),
		subject: email.subject,
		date: email.date
	})
}


appl.def('ajax_supporter_notes', {
	create: function(form_obj, node) {
    appl.is_loading()
		appl.ajax.create('supporter_details.supporter_notes', form_obj).then(function(resp) {
      appl.not_loading()
			if(!resp.ok) return appl.notify("Sorry! Unable to post note: " + resp.body)
			appl.def('timeline_action', null)
			appl.ajax.index('supporter_details.activities')
			appl.notify("Note added")
			node.parentNode.reset()
		})
	},
  update: function(form_obj) {
    appl.is_loading()
    appl.ajax.update('supporter_details.supporter_notes', form_obj['id'], form_obj).then(function(resp) {
      appl.not_loading()
      if(!resp.ok) return appl.notify("Sorry! Unable to update note: " + resp.body)
      appl.ajax.index('supporter_details.activities')
      appl.notify("Note updated")
    })
  },
  delete: function(id) {
    appl.is_loading()
    appl.close_modal()
    appl.ajax.del('supporter_details.supporter_notes', id).then(function(resp) {
      appl.not_loading()
      if(!resp.ok) return appl.notify("Sorry! Unable to delete note: " + resp.body)
      appl.ajax.index('supporter_details.activities')
      appl.notify("Note deleted")
    })
  }
})

appl.def('get_donation_url', function(donation) {
	var search_id = (donation && donation.payment && donation.payment.id) ? ('?pid=' + donation.payment.id) : ('?sid=' + appl.supporter_details.id)
	return "/nonprofits/" + app.nonprofit_id + "/payments" + search_id
})
