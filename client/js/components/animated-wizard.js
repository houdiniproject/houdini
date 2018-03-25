const R = require('ramda')
const h = require('flimflam/h')
const flyd = require('flimflam/flyd')
const wizard = require('flimflam/ui/wizard')
const carousel = require('./carousel')

// the api for this components is the same as the regular ff wizard.
// it wraps the wizard content in a carousel component which adds a horizontally
// scrolling animation whenever the wizard index changes.
// it also makes the heights of each wizard step the same.
const content = (state, content) => {
  const count = content.length
  const index = state.isCompleted$() ? (state.currentStep$() + 1) : state.currentStep$()
  return carousel({count, index, content})
}

const labels = (state, steps) => {
  const truncatedSteps = R.map(x => h('span.inline-block.truncate', x), steps)
  return wizard.labels(state, truncatedSteps)
}

module.exports = {init: wizard.init, labels, content} 

