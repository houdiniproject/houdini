// License: LGPL-3.0-or-later

const h = require('snabbdom/h')

function view(state) {
  const supp = state.params$().supporter
  return h('div.u-padding--10.u-centered', [
    h('h6.u-marginTop--15', 'Your donation was successful!')
  , supp ? h('p', `A receipt will be emailed to ${supp.email}`) : ''
  , h('hr')
  , h('p', state.thankyou_msg || `${state.params$().nonprofit.name} appreciates your support!`)
    // Show the 'finish' button only if we're in an offsite embedded modal
  ,  h('div', [
        h('button.button', {on: {click: state.clickFinish$}}, 'Finish')
      ])

  ])
}


module.exports = {view}
