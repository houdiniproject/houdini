// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const flyd = require('flyd')
const R = require('ramda')
const request = require('../../common/request')
const format = require('../../common/format')
const branding = require('../../components/nonprofit-branding')
flyd.mergeAll = require('flyd/module/mergeall')

const quantityLeft = require('./gift-option-quantity-left')
const giftButton = require('./gift-option-button')

// Pass in a stream that has a value when the gift options need to be refreshed, so we know when to refresh em!
function init(giftsNeedRefresh$, parentState) {
  var state = {
    timeRemaining$: parentState.timeRemaining$
  , clickOption$: flyd.stream()
  , openEditGiftModal$: flyd.stream()
  }

  // XXX some legacy viewscript mixed in here
  flyd.map(gift => {
    appl.open_modal('giftOptionFormModal')
    appl.def('gift_options', {current: gift, is_updating: true})
    appl.def('gift_option_action', 'Edit')
  }, state.openEditGiftModal$)

  const pageloadGifts$ = index()
  const refreshedGifts$ = flyd.flatMap(index, giftsNeedRefresh$)
  state.giftOptions$ = flyd.mergeAll([
    pageloadGifts$
  , refreshedGifts$
  , flyd.stream([]) // default before ajax loads
  ])
  return state
}

function index() {
  const path = `/nonprofits/${app.nonprofit_id}/campaigns/${app.campaign_id}/campaign_gift_options`
  return flyd.map(
    req => req.body.data
  , request({path, method: 'get'}).load
  )
}

function view(state) {
  return h('aside.sideGifts.u-marginBottom--15', {
    class: {'u-hide': !state.giftOptions$().length}
  }, R.map(giftBox(state), state.giftOptions$())
  )
}

const giftBox = state => gift => {
  return h('section.u-relative', [
    h('div.sideGift.pastelBox--grey--dark', [
      h('h5.u-marginTop--0', gift.name)
    , totalContributions(gift)
    , quantityLeft(gift)
    , h('p.u-marginBottom--15', gift.description)
    , h('div', [ giftButton(state, gift) ])
    ])
  , (app.current_campaign_editor && app.is_parent_campaign) // Show edit button only if the current user is a parent campaign editor
    ? h('button.button--tiny.absolute.edit.hasShadow', {
        on: {click: ev => state.openEditGiftModal$(gift)}
      }, [
        h('i.fa.fa-pencil')
      , ' Edit Gift'
      ])
    : '' // do not show gift edit button
  ])
}

const totalContributions = gift => {
  if(gift.hide_contributions) return ''
  return h('p', [
    h('i.fa.fa-star', { style: { color: branding.base} })
  , ` ${format.numberWithCommas(gift.total_gifts)} Contribution${gift.total_gifts === 1 ? '' : 's'}`
  ])
}

module.exports = {view, init}
