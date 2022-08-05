// License: LGPL-3.0-or-later
var action_recipient = require("./action_recipient")
var request = require('../../../common/client')
require('../../../components/wizard')
var formatErr = require('../../../common/format_response_error')
const R = require('ramda')

appl.def('merge.has_any', function(arr) {
	var supporters =  appl.merge.data.supporters
	for(var i = 0, sup_len = supporters.length; i < sup_len; i++) {
		for(var j = 0, arr_len = arr.length; j < arr_len; j++) {
			var key = arr[j]
			if(supporters[i][key]) {
				appl.def('merge.data.has_at_least_one.' + key, true)
			}
		}
	}
})

appl.def('merge.init', function(){
	if (appl.supporters.selected.length > 5) {
		appl.notify("Sorry, you can't merge more than 5 records at a time.")
		return
	}
	if (appl.supporters.selected.length < 2) {
		appl.notify("Sorry, you need to select more than one record to merge.")
		return
	}
  var ids = appl.supporters.selected.map(function(s) { return s.id })
  appl.def('loading', true)
  appl.def('merge.data', '')
	appl.def('merge.data.action_recipient', action_recipient())
  request.get('/nonprofits/' + app.nonprofit_id + '/supporters/merge_data')
    .query({"ids[]": ids})
    .end(function(err, res) {
      appl.def('loading', false)
      appl.def('merge.data.supporters', res.body)
      appl.merge.has_any(['name', 'email', 'phone', 'address'])
      appl.open_modal('mergeModal')
    })
})

appl.def('merge.set', function(form_obj, node) {
  var supp = appl.merge.data.new_supporter
  appl.def('merge.data.new_supporter', R.merge(supp, form_obj))
})

appl.def('merge.select_address', function(supp, node) {
	appl
		.def('merge.data.new_supporter.address', supp.address)
		.def('merge.data.new_supporter.city', supp.city)
		.def('merge.data.new_supporter.state_code', supp.state_code)
		.def('merge.data.new_supporter.zip_code', supp.zip_code )
		.def('merge.data.new_supporter.country', supp.country )
})

appl.def('merge.submit', function(form_object, node){
	appl.def('loading', true)

	request.post("/nonprofits/" + app.nonprofit_id + "/supporters/merge")
		.send({
			supporter: form_object,
			supporter_ids: appl.supporters.selected.map(function(s){return s.id})
		})
		.end(function(err, resp){
      appl.def('loading', false)
      if(resp.ok) {
        appl
        .def('supporters.selected', [])
        .notify('Supporters successfully merged.')
        .supporters.index()
      } else {
        appl.notify('Error: ' + formatErr(resp))
      }
		})
	resetForm()
	appl.close_modal()
	appl.wizard.reset('merge_wiz')
})

const resetForm = function() {
	document.querySelectorAll('[id^="merge_"]').forEach(function(el) { el.value = '' });
}

