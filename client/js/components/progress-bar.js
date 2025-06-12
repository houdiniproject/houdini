// License: LGPL-3.0-or-later
const h = require('snabbdom/h')

// A progress bar component
// Only a view function
// Simply pass in a state object, which should have:
//  - hidden: Boolean (whether to display the bar)
//  - percentage: Integer (percentage complete for the bar)
//  - status: String (status message to display)
/**
 * 
 * @param {{hidden:boolean, percentage:number, status: string}} state 
 * @returns 
 */
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

