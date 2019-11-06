// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const flyd = require('flyd')
const R = require('ramda')
require('../common/vendor/colpick') // XXX jquery

// Color picker UI component, wrapping the colpick jquery plugin
// You can use colorPicker.streams.color to access a stream of hex color values selected by the user
// Will also set colorPicker.state.color for every selected color value

function init(defaultColor) {
  var logoBlue = '#42B3DF'
  return {color$: flyd.stream(defaultColor || logoBlue)}
}

const view = state =>
  h('div.colPick-wrapper.inner#colorpicker', {
    hook: {
      insert: (vnode) => {
        $(vnode.elm).colpick({
          flat: true
        , layout: 'hex'
        , submit: false
        , color: state.color$()
        , onChange: (hsb, hex, rgb, el, bySetColor) => state.color$('#' + hex)
        })
      }
    }
  })

module.exports = {init, view}

