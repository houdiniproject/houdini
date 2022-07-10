// License: LGPL-3.0-or-later
import moment from 'moment';
import { pluralize } from '../../legacy_react/src/lib/deprecated_format';
import { camelToWords, numberWithCommas } from '../../legacy_react/src/lib/format';


function zeroPad(num:number, size:number):string {
	return (num + "").padStart(size, "0");
}

const format = {

	snake_to_words: function (snake: string): string {
		if (!snake) return snake;
		return snake.replace(/_/g, ' ').replace(/^./, function (m) { return m.toUpperCase(); });
	},

	camelToWords: camelToWords,

	dollarsToCents: function (dollars: number | string): number {
		dollars = dollars.toString().replace(/[$,]/g, '');
		if (!isNaN(Number(dollars)) && dollars.match(/^-?\d+\.\d$/)) {
			// could we use toFixed instead? Probably but this is straightforward.
			dollars = dollars + "0";
		}
		if (isNaN(Number(dollars)) || !dollars.match(/^-?\d+(\.\d\d)?$/)) throw "Invalid dollar amount: " + dollars;
		return Math.round(Number(dollars) * 100);
	},

	centsToDollars: function (cents?:undefined|string|number, options:{noCents?:boolean} = {}) {
		if (cents === undefined) return '0';
		return numberWithCommas((Number(cents) / 100.0).toFixed(options.noCents ? 0 : 2).toString()).replace(/\.00$/, '');
	},

	weeklyToMonthly:function (amount?:number):number {
		if (amount === undefined) return 0;
		return Math.round(4.3 * amount);
	},


	numberWithCommas:numberWithCommas,

	percent: function (x?:number, y?:number) :number {
		if (!x || !y) return 0;
		return Math.round(y / x * 100);
	},
	pluralize: pluralize,

	capitalize: function (string:string):string {
		return string.split(' ')
			.map(function (s) { return s.charAt(0).toUpperCase() + s.slice(1); })
			.join(' ');
	},

	date: {
		readableWithTime: function (str:string):string {
			return moment(str).format("YYYY-MM-DD h:MMa");
		},
		toStandard: function (str:string) :string {
			return moment(str).format("YYYY-MM-DD h:MMa");
		},

		toSimple: function (str:string):string {
			if (!str || !str.length) return '';
			const d = new Date(str);
			return zeroPad(d.getMonth() + 1, 2) + '/' +
				zeroPad(d.getDate(), 2) + '/' +
				zeroPad(d.getFullYear(), 2);
		},
	},

	geography: {
		isUS: function (str:string):boolean {
			return Boolean(str.match(/(^united states( of america)?$)|(^u\.?s\.?a?\.?$)/i));
		},
	},

} as const;


export default format;