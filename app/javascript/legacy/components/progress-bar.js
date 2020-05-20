// License: LGPL-3.0-or-later
const h = require('snabbdom/h')
const R = require('ramda')
const flyd = require('flyd')

// A progress bar component
// Only a view function
// Simply pass in a state object, which should have:
//  - hidden: Boolean (whether to display the bar)
//  - percentage: Integer (percentage complete for the bar)
//  - status: String (status message to display)
function view(state) {
  if(state.hidden) return ''
  return h('div.u-centered', [
    h('div.progressBar.u-marginY--10', [
      h('div.progressBar-fill--striped', {style: {width: state.percentage + '%'}})
    ])
  , h('p.status.u-marginTop--10', [ state.status ])
  ])
}

module.exports = view

