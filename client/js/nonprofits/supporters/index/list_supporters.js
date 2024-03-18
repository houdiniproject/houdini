// License: LGPL-3.0-or-later
const flyd = require('flimflam/flyd') // for ajaxing /index_metrics, line 27
const request = require('../../../common/request') // for ajaxing /index_metrics
const map = require('../../../components/maps/cc_map')

appl.def('supporters.selected', [])

appl.def('supporters.index', function() {
	appl.def('loading', true)
	appl.ajax.index('supporters').then(function(resp) {
		appl.supporters.open_side_panel_with_params()
		if(appl.supporters.selecting_all){
			set_checked(resp.body.data, true)
		}
		appl.def('loading', false)
		var supporter_ids = appl.supporters.data.map(function(datum){return datum.id})
    appl.def('supporters.data', appl.supporters.data.map(supp => {
      supp.tags_remaining = (supp.tags && supp.tags.length > 5) 
        ? (supp.tags.length - 5)
        : false
      supp.tags = supp.tags ? supp.tags.slice(0,5) : []
      return supp
    }))
		map.init('specific-npo-supporters', {fit_all: true}, {npo_id: app.nonprofit.id, supporter_ids: supporter_ids})
	})

  appl.def('metrics_loading', true)
  const response$ = request({
    method: 'get'
  , path: `/nonprofits/${ENV.nonprofitID}/supporters/index_metrics`
  , query: appl.supporters.query
  }).load
  const respOk$ = flyd.filter(r => r.status === 200, response$)
  flyd.map(r => { appl.def('metrics_loading', false) }, respOk$)
  flyd.map(r => { appl.def('supporters', r.body) }, respOk$)
})


appl.def('supporters', {
	query: {page: 1},
	concat_data: true,
	path_prefix: '/nonprofits/' + app.nonprofit_id + '/'
})


appl.def('supporters.open_side_panel_with_params', function(){
	var url_supporter_id = utils.get_param('sid')
	if(url_supporter_id) {
		appl.ajax.fetch('supporter_details', url_supporter_id).then(function(resp){
			appl.supporter_details.show(resp.body.data)
			appl.def('loading', false)
		})
	}
})


appl.supporters.index()


appl.def('toggle_select_all', function(node) {
	var checkbox = appl.prev_elem(node)
	appl.def('supporters.selecting_all', checkbox.checked)
	if(checkbox.checked) { // select all
		appl.def('supporters.data', set_checked(appl.supporters.data, true))
		appl.def('supporters.selected', appl.supporters.data)
	}
})


appl.def('toggle_select_page', function(node) {
	var checkbox = appl.prev_elem(node)
	appl.def('supporters.selecting_all', false)
	if(checkbox.checked) { // select all
		appl.def('supporters.data', set_checked(appl.supporters.data, true))
		appl.def('supporters.selected', appl.supporters.data)
	} else { // deselect all
		appl.def('supporters.data', set_checked(appl.supporters.data, false))
		appl.def('supporters.selected', [])
	}
	return appl
})


appl.def('toggle_supporters_checkbox', function(id, node) {
	var checked = appl.prev_elem(node).checked
	appl.find_and_set('supporters.data', {id: id}, {is_checked: checked})
	appl.def('supporters.selected', appl.get_checked_supporters())
	appl.def('supporters.selecting_all', false)
})


appl.def('get_checked_supporters', function() {
	return appl.supporters.data.filter(function(s) { return s.is_checked })
})


appl.def('uncheck_all_supporters', function() {
	appl.supporters.data.forEach(function(obj){return obj.is_checked = false})
	appl.def('supporters.data', appl.supporters.data)
		.def('supporters.selected', [])
		.def('supporters.selecting_all', false)
})


function set_checked(supporters, state) {
	return supporters.map(function(s) {s.is_checked = state; return s})
}

appl.def('print_last_payment_before', function(last_payment_before) {
	return String(last_payment_before).split('_').join(' ')
})
