// License: LGPL-3.0-or-later
var request = require('../../common/client')
require('../../common/image_uploader')
require('../../common/el_swapo')
require('../../common/restful_resource')

const render = require('ff-core/render')
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')
const snabbdom = require('snabbdom')
const branding = require('./branding/index')
const emailSettings = require('./email-settings/index')
const integrations = require('./integrations/index')

function init() {
  var state = {}
  state.emailSettings = emailSettings.init()
  state.branding = branding.init()
  state.integrations = integrations.init()
  return state
}

function view(state) {
  return h('div', [
    emailSettings.view(state.emailSettings)
  , branding.view(state.branding)
  , integrations.view(state.integrations)
  ])
}

// -- Render flimflam

var container = document.querySelector('#js-main')
const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])
var state = init()
render({patch, view, state, container})



// Initialize the froala wysiwyg
appl.def('initialize_froala', function(){
	var editable = require('../../common/editable')
	editable($('.editable'), {
    email_buttons: true,
    placeholder: 'Edit donation receipt message here.',
    sticky: true,
    noUpdateOnChange: true
  })
})

var np_route = '/nonprofits/' + app.nonprofit_id 

appl.def('update_card_failure_message', function() {
  appl.def('card_failure_message.loading', true)
  var messageTop = document.getElementById('js-messageTop').innerHTML 
  var messageBottom = document.getElementById('js-messageBottom').innerHTML 
  var data = { nonprofit: {
      card_failure_message_top: messageTop 
     ,card_failure_message_bottom: messageBottom
    }
  } 
  request.put(np_route + '.json').send(data).end(function(resp) {
    appl.notify('Card failure email successfully saved')
    appl.def('card_failure_message.loading', false)
  })
})

appl.def('update_custom_receipt', function(node) {
  appl.def('receipt.loading', true)
    var classToFind = getClassToFindEditor()
  var receipt = appl.prev_elem(node).getElementsByClassName(classToFind)[0].innerHTML
  var data = { nonprofit: {thank_you_note: receipt} } 
  request.put(np_route + '.json').send(data).end(function(resp) {
    appl.notify('Receipt successfully saved')
    appl.def('receipt.loading', false)
  })
})

appl.def('update_change_amount_message', function(node) {
    appl.def('receipt.loading', true)
    var classToFind = getClassToFindEditor()
    var msg = appl.prev_elem(node).getElementsByClassName(classToFind)[0].innerHTML
    var data = { miscellaneous_np_info: {change_amount_message: msg} }
    request.put(np_route + '/miscellaneous_np_info.json').send(data).end(function(resp) {
        appl.notify('Change amount message saved')
        appl.def('receipt.loading', false)
    })
})

if(app.current_nonprofit_user) {
	appl.create_bank_account = require('../../bank_accounts/create.es6')
}

appl.def('statement.validate', function(node) {
	var statement_val = appl.prev_elem(node).value
	appl.def('statement.name', statement_val)
	if(statement_val.search(/[^\w+(<{@?&!$;:\.\-\'\"\,\s}>)]/gi) < 0) {
		appl.def('statement.invalid', false)
		appl.def('error', '')
	}
	else {
		appl.def('statement.invalid', true)
		appl.def('error', 'Statement name cannot contain special characters')
	}
})

appl.def('cancel_billing_subscription', function() {
	appl.notify('Cancelling subscription...')
	appl.def('loading', true)
	request.put(np_route + '/billing_subscription/cancel')
	  .send({}).end(function(resp) {
		appl.def('loading', false)
	})
})

function getClassToFindEditor()
{
    if (app.editor === 'froala' )
        return "froala-element"
    else if (app.editor === 'quill')
        return "ql-editor"
}

window.onload = function() {
	appl.initialize_froala()
}

