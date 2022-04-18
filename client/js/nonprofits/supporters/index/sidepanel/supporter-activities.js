// License: LGPL-3.0-or-later
const R = require('ramda')
const h = require('snabbdom/h')
const flyd = require('flyd')
const moment = require('moment')
const flatMap = require('flyd/module/flatmap')
const request = require('../../../../common/request')
const flyd_mergeAll = require('flyd/module/mergeall')

const generateContent = require('./generate-content')

function init(parentState) {
  const activitiesWithJson$ = flyd.map(
    R.map(parseActivityJson)
  , parentState.activities$
  )
  const response$ = flyd.merge(
    flyd.stream([]) // default to empty array on pageload
  , activitiesWithJson$ )
  const loading$ = flyd_mergeAll([
    flyd.map(() => false, response$)
  ])
  return {response$, loading$}
}

// Return js object if the string is json, otherwise return the string
const tryJSON = str => {
  try { return JSON.parse(str) } catch(e) { return str }
}

/**
 * If `testObj` is an object OR it's a string that can be parsed as JSON, then we return that object.
 * Otherwise, null.
 */
function jsonOrNull(testObj) {
  if (typeof testObj === 'object') {
    return testObj
  }
  else if (typeof testObj === 'string') {
    try { return JSON.parse(str) } catch(e) {return null;}
  }
  else {
    return null;
  }
}

// Parse the cached `json_data` column for activities
// Also, parse the nested `dedicaton` json if it is present
const parseActivityJson = data => {
  let json_data = jsonOrNull(data.json_data) || {};
  json_data.dedication = tryJSON(json_data.dedication)
  return R.merge(data, {json_data})
}

const view = parentState => {
  var state = parentState.activities
  if(state.loading$()) {
    return  h('div', [ 
      h('p.u-color--grey', [h('i.fa.fa-spin.fa-gear'), ' Loading timeline...'])
    ])
  }
  if(!state.loading$() && !state.response$().length) {
    return  h('div', [ 
      h('p.u-color--grey', 'No activity yet...')
    ])
  }
  return h('ul.timeline-activities', R.map(activityContent(parentState), state.response$()))
}

// used to construct each activitiy list element 
const activityContent = parentState => data => {
  const contentFn = generateContent[data.kind]
  if(!contentFn) return ''
  const content = contentFn(data, parentState)
  return h('li.timeline-activity', [
    h('div.timeline-activity-icon', [h(`i.fa.${content.icon}`)])
  , h('div.timeline-activity-card', [
      h('div', [
        h('small.u-color--grey', moment(data.date).format("ddd, MMMM Do YYYY"))
      , h('div.u-fontSize--15', [
          h('div.activity-section', [h('strong', content.title)])
        , h('div', content.body)
        ]) 
      ])
    ])
  ])
}

module.exports = {init, view}

