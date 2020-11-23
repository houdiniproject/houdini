
// License: LGPL-3.0-or-later
import flatten from 'lodash/flatten';

import displaynames from './common/intl-polyfills/custom/displayNames';

type RawCountryAndSubregion = [string, string[]?] | string

export interface Subregion {
	code: string;
	name: string;
}

export interface Country {
	/**
	 * ISO alpha 2 code (or similar)
	 */
	code: string;

	/** subregion codes */
	subregionCodes: string[] | null;
}

export interface LocalizedCountry extends Country {

	/**
	 * get all of the subregions for a country
	 */
	getSubregions: () => Promise<Subregion[] | null>;

	/**
	 * Provided locale
	 */
	locale: string|string[];

	/**
	 * Name in given locale
	 */
	name: string;
}

const usStatesEn:[string, string][] = [["AK", "Alaska"], ["AL", "Alabama"], ["AR", "Arkansas"], ["AS", "American Samoa"], ["AZ", "Arizona"], ["CA", "California"], ["CO", "Colorado"], ["CT", "Connecticut"], ["DC", "District of Columbia"], ["DE", "Delaware"], ["FL", "Florida"], ["GA", "Georgia"], ["GU", "Guam"], ["HI", "Hawaii"], ["IA", "Iowa"], ["ID", "Idaho"], ["IL", "Illinois"], ["IN", "Indiana"], ["KS", "Kansas"], ["KY", "Kentucky"], ["LA", "Louisiana"], ["MA", "Massachusetts"], ["MD", "Maryland"], ["ME", "Maine"], ["MI", "Michigan"], ["MN", "Minnesota"], ["MO", "Missouri"], ["MP", "Northern Mariana Islands"], ["MS", "Mississippi"], ["MT", "Montana"], ["NC", "North Carolina"], ["ND", "North Dakota"], ["NE", "Nebraska"], ["NH", "New Hampshire"], ["NJ", "New Jersey"], ["NM", "New Mexico"], ["NV", "Nevada"], ["NY", "New York"], ["OH", "Ohio"], ["OK", "Oklahoma"], ["OR", "Oregon"], ["PA", "Pennsylvania"], ["PR", "Puerto Rico"], ["RI", "Rhode Island"], ["SC", "South Carolina"], ["SD", "South Dakota"], ["TN", "Tennessee"], ["TX", "Texas"], ["UM", "United States Minor Outlying Islands"], ["UT", "Utah"], ["VA", "Virginia"], ["VI", "Virgin Islands, U.S."], ["VT", "Vermont"], ["WA", "Washington"], ["WI", "Wisconsin"], ["WV", "West Virginia"], ["WY", "Wyoming"]];
const usStatesEs:[string, string][] = [["AK", "Alaska"], ["AL", "Alabama"], ["AR", "Arkansas"], ["AS", "American Samoa"], ["AZ", "Arizona"], ["CA", "California"], ["CO", "Colorado"], ["CT", "Connecticut"], ["DC", "Distrito de Columbia"], ["DE", "Delaware"], ["FL", "Florida"], ["GA", "Georgia"], ["GU", "Guam"], ["HI", "Hawaii"], ["IA", "Iowa"], ["ID", "Idaho"], ["IL", "Illinois"], ["IN", "Indiana"], ["KS", "Kansas"], ["KY", "Kentucky"], ["LA", "Louisiana"], ["MA", "Massachusetts"], ["MD", "Maryland"], ["ME", "Maine"], ["MI", "Michigan"], ["MN", "Minnesota"], ["MO", "Missouri"], ["MP", "Northern Mariana Islands"], ["MS", "Mississippi"], ["MT", "Montana"], ["NC", "North Carolina"], ["ND", "Norte Dakota"], ["NE", "Nebraska"], ["NH", "Nuevo Hampshire"], ["NJ", "Nuevo Jersey"], ["NM", "Nuevo Mexico"], ["NV", "Nevada"], ["NY", "Nuevo York"], ["OH", "Ohio"], ["OK", "Oklahoma"], ["OR", "Oregon"], ["PA", "Pennsylvania"], ["PR", "Puerto Rico"], ["RI", "Rhode Island"], ["SC", "South Carolina"], ["SD", "South Dakota"], ["TN", "Tennessee"], ["TX", "Texas"], ["UM", "United States Minor Outlying Islands"], ["UT", "Utah"], ["VA", "Virginia"], ["VI", "Virgin Islands, U.S."], ["VT", "Vermont"], ["WA", "Washington"], ["WI", "Wisconsin"], ["WV", " Virginia Occidental"], ["WY", "Wyoming"]];

async function getUsStates(locale:string|string[]): Promise<Subregion[]> {

	let states:[string, string][] = null;
	if (typeof locale === 'string') {
		if (locale.toLowerCase() === 'es') {
			states = usStatesEs;
		}
		else {
			states = usStatesEn;
		}
	}
	else {
		if (locale[0].toLowerCase() === 'es') {
			states = usStatesEs;
		}
		else {
			states = usStatesEn;
		}
	}

	return states.map((i) => ({
		code: i[0],
		name: i[1],
		countryCode: "US",
		locale: locale,
	}));
}

async function nullSubregions(): Promise<Subregion[] | null> {
	return null;
}

const rawCountries: RawCountryAndSubregion[] = [
	'AF',
	'AX',
	'AL',
	'DZ',
	'AS',
	'AD',
	'AO',
	'AI',
	'AQ',
	'AG',
	'AR',
	'AM',
	'AW',
	'AU',
	'AT',
	'AZ',
	'BS',
	'BH',
	'BD',
	'BB',
	'BY',
	'BE',
	'BZ',
	'BJ',
	'BM',
	'BR',
	'IO',
	'BN',
	'BG',
	'BF',
	'BI',
	'KH',
	'CM',
	'CA',
	'CV',
	'KY',
	'CF',
	'TD',
	'CL',
	'CN',
	'CX',
	'CC',
	'CO',
	'KM',
	'CG',
	'CD',
	'CK',
	'CR',
	'CI',
	'HR',
	'CU',
	'CW',
	'CY',
	'CZ',
	'DK',
	'DJ',
	'DM',
	'DO',
	'EC',
	'EG',
	'SV',
	'GQ',
	'ER',
	'EE',
	'ET',
	'FK',
	'FO',
	'FJ',
	'FI',
	'FR',
	'GF',
	'PF',
	'TF',
	'GA',
	'GM',
	'GE',
	'DE',
	'GH',
	'GI',
	'GR',
	'GL',
	'GD',
	'GP',
	'GU',
	'GT',
	'GG',
	'GN',
	'GW',
	'GY',
	'HT',
	'HM',
	'VA',
	'HN',
	'HK',
	'HU',
	'IS',
	'IN',
	'ID',
	'IR',
	'IQ',
	'IE',
	'IM',
	'IL',
	'IT',
	'JM',
	'JP',
	'JE',
	'JO',
	'KZ',
	'KE',
	'KI',
	'KR',
	'KP',
	'KW',
	'KG',
	'LA',
	'LV',
	'LB',
	'LS',
	'LR',
	'LY',
	'LI',
	'LT',
	'LU',
	'MO',
	'MK',
	'MG',
	'MW',
	'MY',
	'MV',
	'ML',
	'MT',
	'MH',
	'MQ',
	'MR',
	'MU',
	'YT',
	'MX',
	'FM',
	'MD',
	'MC',
	'MN',
	'ME',
	'MS',
	'MA',
	'MZ',
	'MM',
	'NA',
	'NR',
	'NP',
	'NL',
	'NC',
	'NZ',
	'NI',
	'NE',
	'NG',
	'NU',
	'NF',
	'MP',
	'NO',
	'OM',
	'PK',
	'PW',
	'PS',
	'PA',
	'PG',
	'PY',
	'PE',
	'PH',
	'PN',
	'PL',
	'PT',
	'PR',
	'QA',
	'RE',
	'RO',
	'RU',
	'RW',
	'BL',
	'SH',
	'KN',
	'LC',
	'MF',
	'PM',
	'VC',
	'WS',
	'SM',
	'ST',
	'SA',
	'SN',
	'RS',
	'SC',
	'SL',
	'SG',
	'SX',
	'SK',
	'SI',
	'SB',
	'SO',
	'ZA',
	'GS',
	'SS',
	'ES',
	'LK',
	'SD',
	'SR',
	'SJ',
	'SZ',
	'SE',
	'CH',
	'SY',
	'TW',
	'TJ',
	'TZ',
	'TH',
	'TL',
	'TG',
	'TK',
	'TO',
	'TT',
	'TN',
	'TR',
	'TM',
	'TC',
	'TV',
	'UG',
	'UA',
	'AE',
	'GB',
	[
		'US', [
			"AK", "AL", "AR", "AS", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "GU", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MP", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "UM", "UT", "VA", "VI", "VT", "WA", "WI", "WV", "WY",
		],
	],
	'UM',
	'UY',
	'UZ',
	'VU',
	'VE',
	'VN',
	'VG',
	'VI',
	'WF',
	'EH',
	'YE',
	'ZM',
	'ZW',
];
export function getCountries() : Country[] {
	return rawCountries.map((i) => {
		const code = typeof i === 'string' ? i : i[0];
		const subregionCodes = typeof i === 'string' || i.length != 2 ? null : i[1];
		return {
			code,
			subregionCodes,
		};
	});
}

export async function getLocalizedCountries(locale:string|string[]) : Promise<LocalizedCountry[]> {
	await displaynames(flatten([locale]));
	const regionNames = new Intl.DisplayNames(locale, { type: 'region' });
	return getCountries().map((i) => {
		const getSubregions = async () => {
			if (i.code === 'US'){
				return await getUsStates(locale);
			}
			else {
				return await nullSubregions();
			}
		};
		return {
			...i,
			name: regionNames.of(i),
			locale,
			getSubregions,
		};
	});
}
