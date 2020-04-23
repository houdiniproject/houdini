// License: LGPL-3.0-or-later
const request = require('../common/client') 
const R = require('ramda') 
const Chart = require('chart.js')
const moment = require('moment')
const dateRange = require('../components/date-range') 
const chartOptions = require('../components/chart-options')

var url = `/nonprofits/${app.nonprofit_id}/campaigns/${ENV.campaignID}/timeline`

function query() {
  appl.def('loading_chart', true)
  request.get(url)
    .end(function(err, resp) {
      appl.def('loading_chart', false)
      var ctx = document.getElementById('js-timeline').getContext('2d')
      new Chart(ctx, {
        type: 'line'
      , data: formatData(cumulative(resp.body))
      , options: chartOptions.dollars
      })
    })
}

function cumulative(data) {
  var moments = dateRange(R.head(data).date, R.last(data).date, 'days')
  var dateStrings = R.map((m) => m.format('YYYY-MM-DD'), moments)

  var proto = {
    offsite_cents:   0
  , onetime_cents:   0
  , recurring_cents: 0
  , total_cents:     0
  }

  var dateDictionary = R.reduce((a,b) => {
     a[b] = R.merge(proto, {date: b})
     return a
  }, {}, dateStrings)

  R.reduce((a, b) => {
    a[b.date] = b
    return a
  }, dateDictionary, data)
  
  return R.tail(R.reduce((a, b) => {
    var last = R.last(a)
    b.offsite_cents    += last.offsite_cents
    b.onetime_cents    += last.onetime_cents
    b.recurring_cents  += last.recurring_cents
    b.total_cents      += last.total_cents
    return R.append(b, a) 
  }, [proto], R.values(dateDictionary)))
}

function formatData(data) {
  return {
    labels: R.map((st) => moment(st).format('M/D/YYYY'), R.pluck('date', data))
  , datasets: [ 
      dataset('Total'
            , 'total_cents'
            , '190, 190, 190' 
            , data)
    , dataset('One time'
            , 'onetime_cents'
            , '66, 179, 223'
            , data)
    , dataset('Recurring'
            , 'recurring_cents'
            , '240, 205, 108' 
            , data)
    , dataset('Offsite'
            , 'offsite_cents'
            , '95, 184, 141' 
            , data)
    ]
  }
}

function dataset(label, key, rgb, data) {
  return {
      label: label 
    , data: R.pluck(key, data) 
    , borderColor: `rgb(${rgb})`   
    , backgroundColor: `rgba(${rgb},0.2)`
    , fill: false
    , pointRadius: 0
    , pointHitRadius: 2
  }
}

query()

