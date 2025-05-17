// License: LGPL-3.0-or-later
require('parsleyjs')

const render = require('ff-core/render')
const donate = require('./wizard')
const snabbdom = require('snabbdom')
const flyd = require('flyd')
const { parseDonateParams } = require('./wizard/utils');

const request = require('../../common/request')

const patch = snabbdom.init([
  require('snabbdom/modules/eventlisteners')
, require('snabbdom/modules/class')
, require('snabbdom/modules/props')
, require('snabbdom/modules/style')
])

const params = parseDonateParams(document.location, app);

const params$ = flyd.stream(params)
app.params$ = params$
if(params.campaign_id && params.gift_option_id) {
  setGiftOptionParams(params.campaign_id, params.gift_option_id)
}

// Listen to postMessages to change params
window.addEventListener('message', receiveMessage, false)
function receiveMessage(event) {
  var ps
  try { ps = JSON.parse(event.data) }
  catch(e) {}
  if(ps && ps.sender === 'commitchange') {
    if (ps.command) {
      var event = new CustomEvent('message:'+ps.command,{data:ps});
      container.dispatchEvent(event);
    }
    if(ps.command === 'setDonationParams') {
      params$(ps)
      // Fetch the gift option data if they passed a gift option id
      if(ps.campaign_id && ps.gift_option_id) {
        setGiftOptionParams(ps.campaign_id, ps.gift_option_id)
      }
    }
  }
}

// Given a gift option id, make a request to get its full data and set the other params accordingly
function setGiftOptionParams(campaign_id, gift_id) {
  flyd.map(
    resp => {
      if(resp.status !== 200) return
      var gift_option = resp.body.data
      var params = params$()
      params.gift_option = gift_option
      params.single_amount = (gift_option.amount_one_time || gift_option.amount_recurring) / 100
      if(params.type === 'recurring' && gift_option.amount_recurring) {
        params.single_amount = gift_option.amount_recurring / 100
      } else if(!gift_option.amount_one_time && gift_option.amount_recurring) {
        params.type = 'recurring'
      } else if(params.type === 'recurring' && !gift_option.amount_recurring) {
        params.type = undefined
      }
      params$(params)
    }
  , request({
      method: 'get'
    , path: `/nonprofits/${ENV.nonprofitID}/campaigns/${campaign_id}/campaign_gift_options/${gift_id}`
    }).load
  )
}

var state = donate.init(params$)
var container = document.querySelector('.js-donateForm')
if(app.nonprofit.can_view_payment_wizard) {
  $(".donationWizard").trigger("render:pre");
  var event = new CustomEvent('render:pre');
  container.parentNode.dispatchEvent(event);
  render({patch, view: donate.view, state, container})
  jQuery(function($){
  $(".donationWizard").trigger("render:post")
  });
//  event = new CustomEvent('render:post');
//  container.parentNode.dispatchEvent(event);
}
