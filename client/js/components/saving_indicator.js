// License: LGPL-3.0-or-later
var h = require("virtual-dom/h")

/**
 * 
 * @param {{hide?:boolean, text:?:string}} savingState 
 * @returns ReturnType<typeof h>;
 */
module.exports = function(savingState) {
  return h('div.savingIndicator.pastelBox--yellow'
    , {style: {
          position: 'fixed'
        , top: '0'
        , left: '50%'
        , width: '70px'
        , marginLeft: '-35px'
        , textAlign: 'center'
        , zIndex: '999999'
        , fontSize: '14px'
        , padding: '4px'
        , display: savingState.hide ? 'none' : 'block'
      }}
    , savingState.text)
}
