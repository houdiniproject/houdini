// License: LGPL-3.0-or-later
var request = require('../../common/client').default
var R = require('ramda')

appl.def('discounts.url', '/nonprofits/' + app.nonprofit_id + '/events/' + app.event_id + '/event_discounts')

appl.def('discounts.index', function(){
  request.get(appl.discounts.url).end(function(err, resp) {
    appl.def('discounts.data', resp.body || [])
  })
})

appl.discounts.index()

appl.def('discounts.apply', function(node){
  var code = appl.prev_elem(node).value
  var codes = R.pluck('code', appl.discounts.data)
  if (!R.contains(code, codes)) {
    appl.def('ticket_wiz.discounted_total_amount', false)  
    return
  }
  var discount_obj = R.find(R.propEq('code', code), appl.discounts.data)
  var discount_mult = Number(discount_obj.percent) / 100
  var ticket_price = appl.ticket_wiz.total_amount
  var discounted_ticket_price = ticket_price - Math.round(ticket_price *  discount_mult)
  if(discounted_ticket_price === 0){
    appl.def('ticket_wiz.post_data.kind', 'free')
  }
  appl.notify('Discount successfully applied')
  appl.def('ticket_wiz.discounted_total_amount', discounted_ticket_price)  
  appl.def('ticket_wiz.post_data.event_discount_id', discount_obj.id)
})

if(app.current_event_editor) {
    require('./manage')
}

