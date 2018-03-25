// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const flyd = require('flyd')
const R = require('ramda')

const soldOut = require('./is-sold-out')
const giftButton = require('./gift-option-button')

const giftOption = g => h('option', { props: {value: g.id} }, g.name) 

const setDisplayGift = (state, gifts) => ev => {
  var id = Number(ev.target.value)
  state.selectedModalGift$(R.find(R.propEq('id', id))(gifts))
}

const chooseGift = (state, gifts) =>
  h('div.pastelBox--grey.u-padding--10', [
    h('select.u-margin--0', {on: {change: setDisplayGift(state, gifts)}}
    , R.concat([h('option', 'Choose a gift option')], R.map(giftOption, gifts)))
  , h('div.sideGifts', 
      state.selectedModalGift$() && state.selectedModalGift$().id 
      ? [
          h('p.u-marginTop--10', state.selectedModalGift$().description || '')
        , giftButton(state.giftOptions, state.selectedModalGift$())
        ]
      : ''
    )
  ])

const regularContribution = state => {
  if (app.campaign.hide_custom_amounts) return ''
  return h('div.u-marginTop--15.centered', [
    h('a', {on: {click: state.clickRegularContribution$}}, 'Contribute with no gift option')
  ])
}

module.exports = state => {
  var gifts = R.filter(g => !soldOut(g), state.giftOptions.giftOptions$() || []) 
  return h('div.u-padding--15', [
    chooseGift(state, gifts)
  , regularContribution(state)
  ])
}

