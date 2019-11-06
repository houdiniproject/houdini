// License: LGPL-3.0-or-later
var chartOptions = {}

chartOptions.default = {
  defaultFontFamily: "'Open Sans', 'Helvetica Neue', 'Arial',  'sans-serif'"
, scales: {
    yAxes: [{ ticks: { min: 0 }}]
 }
}

chartOptions.dollars = {
  defaultFontFamily: "'Open Sans', 'Helvetica Neue', 'Arial',  'sans-serif'"
, scales: {
    yAxes: [{ ticks: {
      min: 0
    , callback: (val) => '$' + utils.cents_to_dollars(val)
    } }]
  }
, tooltips: {
    callbacks: {
      label: (item, data) =>
        data.datasets[item.datasetIndex].label + 
        ': $' + utils.cents_to_dollars(item.yLabel)
    }
  }
}

module.exports = chartOptions

