// License: LGPL-3.0-or-later

import utils from '../common/utilities';


export const defaultOptions = {
	defaultFontFamily: "'Open Sans', 'Helvetica Neue', 'Arial',  'sans-serif'",
	scales: {
		yAxes: [{ ticks: { min: 0 } }],
	},
};

export const dollars = {

	defaultFontFamily: "'Open Sans', 'Helvetica Neue', 'Arial',  'sans-serif'"
	, scales: {
		yAxes: [{
			ticks: {
				min: 0
				, callback: (val?: undefined | string | number):string => '$' + utils.cents_to_dollars(val),
			},
		}],
	}
	, tooltips: {
		callbacks: {
			label: (item: {datasetIndex: string, yLabel: string | number }, data: {
        datasets: { [field: string]: { label: string } };
      }):string =>
				data.datasets[item.datasetIndex].label +
        ': $' + utils.cents_to_dollars(item.yLabel),
		},
	},
};


