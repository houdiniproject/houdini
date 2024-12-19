// License: LGPL-3.0-or-later
// npm
const flyd = require('flyd')
flyd.flatMap = require('flyd/module/flatmap')
flyd.filter = require('flyd/module/filter')
flyd.mergeAll = require('flyd/module/mergeall')
const notification = require('ff-core/notification')
// local
const fonts = require('../../../common/brand-fonts')
const request = require('../../../common/request')
const colorPicker = require('../../../components/color-picker.es6')
const view = require('./view')

function init() {
  const np = { ...app.nonprofit }
  const state = {
    nonprofit: np
  , font$: flyd.stream({
      key: np.brand_font || 'bitter'
    , family: np.brand_font ? fonts[np.brand_font].family : fonts.bitter.family
    , name: np.brand_font ? fonts[np.brand_font]['name'] : 'Bitter'
    })
  , color: np.brand_color
  , submit$:  flyd.stream()
  , color$: flyd.stream()
  }

  const resp$ = flyd.flatMap(
    state => flyd.map(r => r.body, request({
      method: 'put'
    , path: `/nonprofits/${np.id}`
    , send: {nonprofit: { brand_color: state.colorPicker.color$(), brand_font: state.font$().key }}
    }).load)
  , state.submit$)

  const notify$ = flyd.map(()=> 'We successfully saved your branding settings!', resp$)

  state.loading$ = flyd.mergeAll([
    flyd.map(()=> true, state.submit$)
  , flyd.map(()=> false, resp$)
  ])

  state.notification = notification.init({message$: notify$})
  state.colorPicker = colorPicker.init(state.nonprofit.brand_color)

  return state
}

module.exports = {view, init}

