// License: LGPL-3.0-or-later
const flyd = require('flyd')
const flyd_filter = require('flyd/module/filter')
const R = require('ramda')
const h = require('snabbdom/h')
const moment = require('moment')

// Modal component for exporting reports

// XXX Note: this can be generalized to be any report modal, but for now it is specific to end-of-year

flyd.log = flyd.map(console.log.bind(console))

function init() {
  var state = {
    currentYear: moment().year()
  , changeYear$: flyd.stream()
  , submit$: flyd.stream()
  }
  const selectedYear$ = flyd_filter(
    year => Number(year) <= state.currentYear && Number(year) >= 2012
  , flyd.merge(
      flyd.map(ev => ev.currentTarget.value, state.changeYear$)
    , flyd.stream(state.currentYear)
    )
  )
  state.exportPath$ = flyd.map(year => `/nonprofits/${ENV.nonprofitID}/reports/end_of_year.csv?year=${year}`, selectedYear$)
  return state
}

function view(state) {
  return h('div.modal', {props: {id: 'endOfYearReportModal'}}, [ 
    h('div.modal-header', [ h('h2', 'End-of-year report') ])
  , h('div.modal-body', [
      modalBody(state)
    ])
  ])
}

const modalBody = state => {
  return h('div', [
    h('p', 'Export donors who have given during a selected year, with their aggregated totals, averages, and itemized payments histories for that year.')
  , h('label', 'Year')
  , h('input', {
      on: {change: state.changeYear$}
    , props: {
        type: 'number'
      , placeholder: 'YYYY'
      , value: state.currentYear
      , min: 2012
      , max: state.currentYear
      }
    })
  , h('a.button', {props: {target: '_blank', href: state.exportPath$()}}, 'Download CSV Report')
  ])
}

module.exports = {init, view}
