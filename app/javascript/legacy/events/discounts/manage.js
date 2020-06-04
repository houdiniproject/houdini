// License: LGPL-3.0-or-later
var R = require('ramda')
var request = require('../../common/client')
var format = require('../../common/format')

appl.def('discounts.create_or_update', function(form_obj, node){
  appl.def('discounts.loading', true)
  if(!validate(form_obj)) {
     appl.def('discounts.loading', false)
    return
  }
  if(form_obj.id) {
    update_discount(form_obj)
  } else {
    delete form_obj.id
    create_discount(form_obj)
  }
})


appl.def('discounts.show_new', function(){
  appl.def('discounts.editing', {id: '', name: '', percent: '', code: ''})
  appl.open_modal('createOrEditDiscountsModal')
})


appl.def('discounts.show_edit', function(i){
  appl.def('discounts.editing', appl.discounts.data[i])
  appl.open_modal('createOrEditDiscountsModal')
})


function update_discount(form_obj){
  request.put(appl.discounts.url + '/' + form_obj.id, form_obj)
    .end(function(err, resp){
      after_create_or_edit("Discount successfully edited")
  })
}


appl.def('discounts.delete', function(id){
  request.del(appl.discounts.url + '/' + id).end(function(err, resp) {
      appl.notify('Discount successfully deleted')
      appl.discounts.index()
    })
})


function create_discount(form_obj){
  request.post(appl.discounts.url, form_obj)
    .end(function(err, resp){
      after_create_or_edit("Discount successfully added")
    })
}


function after_create_or_edit(message){
  appl.discounts.index()
  appl.notify(message)
  appl.open_modal("manageDiscountsModal")
  appl.def('discounts.loading', false)
}


function validate(form_obj){
  var blanks =['name', 'percent', 'code']
  var message = ''
  blanks.map(function(a, i) {
    if(!form_obj[a]) { message += format.capitalize(a) + ', '}
  })
  if (message) {
    appl.notify(message + " can't be blank")
    return false
  }
  var percent = Number(form_obj.percent)
  if (!Boolean(percent) || percent <= 0) {
    appl.notify("Percentage must be a number larger than 0")
    return false
  }
  if(percent > 100) {
    appl.notify("Percentage can't be more than 100")
    return false
  }
  var codes = R.pluck('code', R.reject(function(x){ return x['id'] === Number(form_obj.id)}, appl.discounts.data))
  var hasDupeCodes = R.contains(form_obj.code, codes)
 
  if (hasDupeCodes){
    appl.notify("That code is already being used for this event.  Please type another code.")
    return false
  }
  return form_obj
}

