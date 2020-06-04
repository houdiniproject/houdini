// License: LGPL-3.0-or-later
const request = require('../common/client') 
const R = require('ramda') 
const Chart = require('chart.js')
const Pikaday = require('pikaday')
const moment = require('moment')
const chartOptions = require('../components/chart-options')

var frontendFormat = 'M/D/YYYY'
var backendFormat  = 'YYYY-MM-DD'

// set the default query to get the last year of payments 
// and group them by month
var defaultParams = {
    endDate: moment().format(backendFormat)
  , startDate: moment().subtract(12, 'months').format(backendFormat)
  , timeSpan: 'month'
}

var pickadayDefaults = {format: frontendFormat, setDefaultDate: true}

appl.def('updateChartParams', function(formObj) {
  updateChart({
      endDate: moment(formObj.endDate).format(backendFormat)
    , startDate: moment(formObj.startDate).format(backendFormat)
    , timeSpan: formObj.timeSpan 
  })
})

// start date Pickaday
new Pikaday(R.merge({
    field: document.getElementById('js-paymentsChart-startDate')
  , maxDate: moment().subtract(1, 'week').toDate()
  , defaultDate: moment().subtract(1, 'years').toDate()
}, pickadayDefaults))

// end date Pickaday
new Pikaday(R.merge({
    field: document.getElementById('js-paymentsChart-endDate')
  , maxDate: moment().toDate() 
  , defaultDate: moment().toDate() 
}, pickadayDefaults))

var ctx = document.getElementById('js-paymentsChart').getContext('2d')

var chart = new Chart(ctx, {
  type: 'bar'
, options: chartOptions.dollars
, data: {labels: [], datasets: []}
})

var url = `/nonprofits/${app.nonprofit_id}/payment_history`

function updateChart(params) {
  appl.def('loading_chart', true)
  request.get(url)
    .query(params)
    .end(function(err, resp) {
      chart.data.labels   =  formatLabels(R.pluck('time_span', resp.body), params.timeSpan)
      chart.data.datasets =  formatDatasets(resp.body)
      chart.update()
      appl.def('loading_chart', false)
    })
}

function formatLabels(dates, type) {
  switch (type) {
    case "year":
      return R.map(st => moment(st).format('YYYY'), dates)
    case "month":
      return R.map(st => moment(st).format('MMM YYYY'), dates)
    case "week":
      return R.map(st => 
        `${moment(st).format('M/D/YY')} - ${moment(st).add(7, 'days').format('M/D/YY')}`
        , dates)
    default:
      return R.map(st => moment(st).format(frontendFormat), dates)
  }
}

const formatDatasets = (data) => [ 
    dataset('One time'
          , 'onetime_cents'
          , '66, 179, 223'
          , data)
  , dataset('Recurring'
          , 'recurring_cents'
          , '240, 205, 108' 
          , data)
  , dataset('Tickets'
          , 'tickets_cents'
          , '238, 132, 128' 
          , data)
  , dataset('Total'
          , 'total_cents'
          , '195, 195, 195' 
          , data)
  ]

function dataset(label, key, rgb, data) {
  return {
      label: label 
    , data: R.pluck(key, data) 
    , borderWidth: 1
    , borderColor: `rgb(${rgb})`   
    , backgroundColor: `rgba(${rgb},0.3)`
  }
}

updateChart(defaultParams)

