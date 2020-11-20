

export interface Subregion {
	code: string;
	name: string;
}

export interface Country {
	/**
	 * ISO alpha 2 code (or similar)
	 */
	code: string;

	/**
	 * get all of the subregions for a country
	 */
	getSubregions: (locale: string) => Promise<Subregion[] | null>;
}

async function nullSubregions(): Promise<Subregion[] | null> {
	return null;
}

const countries: Country[] = [

	{
		code: 'AF',
		getSubregions: nullSubregions,
	},
	{
		code: 'AX',
		getSubregions: nullSubregions,
	},
	{
		code: 'AL',
		getSubregions: nullSubregions,
	},
	{
		code: 'DZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'AS',
		getSubregions: nullSubregions,
	},
	{
		code: 'AD',
		getSubregions: nullSubregions,
	},
	{
		code: 'AO',
		getSubregions: nullSubregions,
	},
	{
		code: 'AI',
		getSubregions: nullSubregions,
	},
	{
		code: 'AQ',
		getSubregions: nullSubregions,
	},
	{
		code: 'AG',
		getSubregions: nullSubregions,
	},
	{
		code: 'AR',
		getSubregions: nullSubregions,
	},
	{
		code: 'AM',
		getSubregions: nullSubregions,
	},
	{
		code: 'AW',
		getSubregions: nullSubregions,
	},
	{
		code: 'AU',
		getSubregions: nullSubregions,
	},
	{
		code: 'AT',
		getSubregions: nullSubregions,
	},
	{
		code: 'AZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'BS',
		getSubregions: nullSubregions,
	},
	{
		code: 'BH',
		getSubregions: nullSubregions,
	},
	{
		code: 'BD',
		getSubregions: nullSubregions,
	},
	{
		code: 'BB',
		getSubregions: nullSubregions,
	},
	{
		code: 'BY',
		getSubregions: nullSubregions,
	},
	{
		code: 'BE',
		getSubregions: nullSubregions,
	},
	{
		code: 'BZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'BJ',
		getSubregions: nullSubregions,
	},
	{
		code: 'BM',
		getSubregions: nullSubregions,
	},
	{
		code: 'BT',
		getSubregions: nullSubregions,
	},
	{
		code: 'BO',
		getSubregions: nullSubregions,
	},
	{
		code: 'BQ',
		getSubregions: nullSubregions,
	},
	{
		code: 'BA',
		getSubregions: nullSubregions,
	},
	{
		code: 'BW',
		getSubregions: nullSubregions,
	},
	{
		code: 'BV',
		getSubregions: nullSubregions,
	},
	{
		code: 'BR',
		getSubregions: nullSubregions,
	},
	{
		code: 'IO',
		getSubregions: nullSubregions,
	},
	{
		code: 'BN',
		getSubregions: nullSubregions,
	},
	{
		code: 'BG',
		getSubregions: nullSubregions,
	},
	{
		code: 'BF',
		getSubregions: nullSubregions,
	},
	{
		code: 'BI',
		getSubregions: nullSubregions,
	},
	{
		code: 'KH',
		getSubregions: nullSubregions,
	},
	{
		code: 'CM',
		getSubregions: nullSubregions,
	},
	{
		code: 'CA',
		getSubregions: nullSubregions,
	},
	{
		code: 'CV',
		getSubregions: nullSubregions,
	},
	{
		code: 'KY',
		getSubregions: nullSubregions,
	},
	{
		code: 'CF',
		getSubregions: nullSubregions,
	},
	{
		code: 'TD',
		getSubregions: nullSubregions,
	},
	{
		code: 'CL',
		getSubregions: nullSubregions,
	},
	{
		code: 'CN',
		getSubregions: nullSubregions,
	},
	{
		code: 'CX',
		getSubregions: nullSubregions,
	},
	{
		code: 'CC',
		getSubregions: nullSubregions,
	},
	{
		code: 'CO',
		getSubregions: nullSubregions,
	},
	{
		code: 'KM',
		getSubregions: nullSubregions,
	},
	{
		code: 'CG',
		getSubregions: nullSubregions,
	},
	{
		code: 'CD',
		getSubregions: nullSubregions,
	},
	{
		code: 'CK',
		getSubregions: nullSubregions,
	},
	{
		code: 'CR',
		getSubregions: nullSubregions,
	},
	{
		code: 'CI',
		getSubregions: nullSubregions,
	},
	{
		code: 'HR',
		getSubregions: nullSubregions,
	},
	{
		code: 'CU',
		getSubregions: nullSubregions,
	},
	{
		code: 'CW',
		getSubregions: nullSubregions,
	},
	{
		code: 'CY',
		getSubregions: nullSubregions,
	},
	{
		code: 'CZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'DK',
		getSubregions: nullSubregions,
	},
	{
		code: 'DJ',
		getSubregions: nullSubregions,
	},
	{
		code: 'DM',
		getSubregions: nullSubregions,
	},
	{
		code: 'DO',
		getSubregions: nullSubregions,
	},
	{
		code: 'EC',
		getSubregions: nullSubregions,
	},
	{
		code: 'EG',
		getSubregions: nullSubregions,
	},
	{
		code: 'SV',
		getSubregions: nullSubregions,
	},
	{
		code: 'GQ',
		getSubregions: nullSubregions,
	},
	{
		code: 'ER',
		getSubregions: nullSubregions,
	},
	{
		code: 'EE',
		getSubregions: nullSubregions,
	},
	{
		code: 'ET',
		getSubregions: nullSubregions,
	},
	{
		code: 'FK',
		getSubregions: nullSubregions,
	},
	{
		code: 'FO',
		getSubregions: nullSubregions,
	},
	{
		code: 'FJ',
		getSubregions: nullSubregions,
	},
	{
		code: 'FI',
		getSubregions: nullSubregions,
	},
	{
		code: 'FR',
		getSubregions: nullSubregions,
	},
	{
		code: 'GF',
		getSubregions: nullSubregions,
	},
	{
		code: 'PF',
		getSubregions: nullSubregions,
	},
	{
		code: 'TF',
		getSubregions: nullSubregions,
	},
	{
		code: 'GA',
		getSubregions: nullSubregions,
	},
	{
		code: 'GM',
		getSubregions: nullSubregions,
	},
	{
		code: 'GE',
		getSubregions: nullSubregions,
	},
	{
		code: 'DE',
		getSubregions: nullSubregions,
	},
	{
		code: 'GH',
		getSubregions: nullSubregions,
	},
	{
		code: 'GI',
		getSubregions: nullSubregions,
	},
	{
		code: 'GR',
		getSubregions: nullSubregions,
	},
	{
		code: 'GL',
		getSubregions: nullSubregions,
	},
	{
		code: 'GD',
		getSubregions: nullSubregions,
	},
	{
		code: 'GP',
		getSubregions: nullSubregions,
	},
	{
		code: 'GU',
		getSubregions: nullSubregions,
	},
	{
		code: 'GT',
		getSubregions: nullSubregions,
	},
	{
		code: 'GG',
		getSubregions: nullSubregions,
	},
	{
		code: 'GN',
		getSubregions: nullSubregions,
	},
	{
		code: 'GW',
		getSubregions: nullSubregions,
	},
	{
		code: 'GY',
		getSubregions: nullSubregions,
	},
	{
		code: 'HT',
		getSubregions: nullSubregions,
	},
	{
		code: 'HM',
		getSubregions: nullSubregions,
	},
	{
		code: 'VA',
		getSubregions: nullSubregions,
	},
	{
		code: 'HN',
		getSubregions: nullSubregions,
	},
	{
		code: 'HK',
		getSubregions: nullSubregions,
	},
	{
		code: 'HU',
		getSubregions: nullSubregions,
	},
	{
		code: 'IS',
		getSubregions: nullSubregions,
	},
	{
		code: 'IN',
		getSubregions: nullSubregions,
	},
	{
		code: 'ID',
		getSubregions: nullSubregions,
	},
	{
		code: 'IR',
		getSubregions: nullSubregions,
	},
	{
		code: 'IQ',
		getSubregions: nullSubregions,
	},
	{
		code: 'IE',
		getSubregions: nullSubregions,
	},
	{
		code: 'IM',
		getSubregions: nullSubregions,
	},
	{
		code: 'IL',
		getSubregions: nullSubregions,
	},
	{
		code: 'IT',
		getSubregions: nullSubregions,
	},
	{
		code: 'JM',
		getSubregions: nullSubregions,
	},
	{
		code: 'JP',
		getSubregions: nullSubregions,
	},
	{
		code: 'JE',
		getSubregions: nullSubregions,
	},
	{
		code: 'JO',
		getSubregions: nullSubregions,
	},
	{
		code: 'KZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'KE',
		getSubregions: nullSubregions,
	},
	{
		code: 'KI',
		getSubregions: nullSubregions,
	},
	{
		code: 'KR',
		getSubregions: nullSubregions,
	},
	{
		code: 'KP',
		getSubregions: nullSubregions,
	},
	{
		code: 'KW',
		getSubregions: nullSubregions,
	},
	{
		code: 'KG',
		getSubregions: nullSubregions,
	},
	{
		code: 'LA',
		getSubregions: nullSubregions,
	},
	{
		code: 'LV',
		getSubregions: nullSubregions,
	},
	{
		code: 'LB',
		getSubregions: nullSubregions,
	},
	{
		code: 'LS',
		getSubregions: nullSubregions,
	},
	{
		code: 'LR',
		getSubregions: nullSubregions,
	},
	{
		code: 'LY',
		getSubregions: nullSubregions,
	},
	{
		code: 'LI',
		getSubregions: nullSubregions,
	},
	{
		code: 'LT',
		getSubregions: nullSubregions,
	},
	{
		code: 'LU',
		getSubregions: nullSubregions,
	},
	{
		code: 'MO',
		getSubregions: nullSubregions,
	},
	{
		code: 'MK',
		getSubregions: nullSubregions,
	},
	{
		code: 'MG',
		getSubregions: nullSubregions,
	},
	{
		code: 'MW',
		getSubregions: nullSubregions,
	},
	{
		code: 'MY',
		getSubregions: nullSubregions,
	},
	{
		code: 'MV',
		getSubregions: nullSubregions,
	},
	{
		code: 'ML',
		getSubregions: nullSubregions,
	},
	{
		code: 'MT',
		getSubregions: nullSubregions,
	},
	{
		code: 'MH',
		getSubregions: nullSubregions,
	},
	{
		code: 'MQ',
		getSubregions: nullSubregions,
	},
	{
		code: 'MR',
		getSubregions: nullSubregions,
	},
	{
		code: 'MU',
		getSubregions: nullSubregions,
	},
	{
		code: 'YT',
		getSubregions: nullSubregions,
	},
	{
		code: 'MX',
		getSubregions: nullSubregions,
	},
	{
		code: 'FM',
		getSubregions: nullSubregions,
	},
	{
		code: 'MD',
		getSubregions: nullSubregions,
	},
	{
		code: 'MC',
		getSubregions: nullSubregions,
	},
	{
		code: 'MN',
		getSubregions: nullSubregions,
	},
	{
		code: 'ME',
		getSubregions: nullSubregions,
	},
	{
		code: 'MS',
		getSubregions: nullSubregions,
	},
	{
		code: 'MA',
		getSubregions: nullSubregions,
	},
	{
		code: 'MZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'MM',
		getSubregions: nullSubregions,
	},
	{
		code: 'NA',
		getSubregions: nullSubregions,
	},
	{
		code: 'NR',
		getSubregions: nullSubregions,
	},
	{
		code: 'NP',
		getSubregions: nullSubregions,
	},
	{
		code: 'NL',
		getSubregions: nullSubregions,
	},
	{
		code: 'NC',
		getSubregions: nullSubregions,
	},
	{
		code: 'NZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'NI',
		getSubregions: nullSubregions,
	},
	{
		code: 'NE',
		getSubregions: nullSubregions,
	},
	{
		code: 'NG',
		getSubregions: nullSubregions,
	},
	{
		code: 'NU',
		getSubregions: nullSubregions,
	},
	{
		code: 'NF',
		getSubregions: nullSubregions,
	},
	{
		code: 'MP',
		getSubregions: nullSubregions,
	},
	{
		code: 'NO',
		getSubregions: nullSubregions,
	},
	{
		code: 'OM',
		getSubregions: nullSubregions,
	},
	{
		code: 'PK',
		getSubregions: nullSubregions,
	},
	{
		code: 'PW',
		getSubregions: nullSubregions,
	},
	{
		code: 'PS',
		getSubregions: nullSubregions,
	},
	{
		code: 'PA',
		getSubregions: nullSubregions,
	},
	{
		code: 'PG',
		getSubregions: nullSubregions,
	},
	{
		code: 'PY',
		getSubregions: nullSubregions,
	},
	{
		code: 'PE',
		getSubregions: nullSubregions,
	},
	{
		code: 'PH',
		getSubregions: nullSubregions,
	},
	{
		code: 'PN',
		getSubregions: nullSubregions,
	},
	{
		code: 'PL',
		getSubregions: nullSubregions,
	},
	{
		code: 'PT',
		getSubregions: nullSubregions,
	},
	{
		code: 'PR',
		getSubregions: nullSubregions,
	},
	{
		code: 'QA',
		getSubregions: nullSubregions,
	},
	{
		code: 'RE',
		getSubregions: nullSubregions,
	},
	{
		code: 'RO',
		getSubregions: nullSubregions,
	},
	{
		code: 'RU',
		getSubregions: nullSubregions,
	},
	{
		code: 'RW',
		getSubregions: nullSubregions,
	},
	{
		code: 'BL',
		getSubregions: nullSubregions,
	},
	{
		code: 'SH',
		getSubregions: nullSubregions,
	},
	{
		code: 'KN',
		getSubregions: nullSubregions,
	},
	{
		code: 'LC',
		getSubregions: nullSubregions,
	},
	{
		code: 'MF',
		getSubregions: nullSubregions,
	},
	{
		code: 'PM',
		getSubregions: nullSubregions,
	},
	{
		code: 'VC',
		getSubregions: nullSubregions,
	},
	{
		code: 'WS',
		getSubregions: nullSubregions,
	},
	{
		code: 'SM',
		getSubregions: nullSubregions,
	},
	{
		code: 'ST',
		getSubregions: nullSubregions,
	},
	{
		code: 'SA',
		getSubregions: nullSubregions,
	},
	{
		code: 'SN',
		getSubregions: nullSubregions,
	},
	{
		code: 'RS',
		getSubregions: nullSubregions,
	},
	{
		code: 'SC',
		getSubregions: nullSubregions,
	},
	{
		code: 'SL',
		getSubregions: nullSubregions,
	},
	{
		code: 'SG',
		getSubregions: nullSubregions,
	},
	{
		code: 'SX',
		getSubregions: nullSubregions,
	},
	{
		code: 'SK',
		getSubregions: nullSubregions,
	},
	{
		code: 'SI',
		getSubregions: nullSubregions,
	},
	{
		code: 'SB',
		getSubregions: nullSubregions,
	},
	{
		code: 'SO',
		getSubregions: nullSubregions,
	},
	{
		code: 'ZA',
		getSubregions: nullSubregions,
	},
	{
		code: 'GS',
		getSubregions: nullSubregions,
	},
	{
		code: 'SS',
		getSubregions: nullSubregions,
	},
	{
		code: 'ES',
		getSubregions: nullSubregions,
	},
	{
		code: 'LK',
		getSubregions: nullSubregions,
	},
	{
		code: 'SD',
		getSubregions: nullSubregions,
	},
	{
		code: 'SR',
		getSubregions: nullSubregions,
	},
	{
		code: 'SJ',
		getSubregions: nullSubregions,
	},
	{
		code: 'SZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'SE',
		getSubregions: nullSubregions,
	},
	{
		code: 'CH',
		getSubregions: nullSubregions,
	},
	{
		code: 'SY',
		getSubregions: nullSubregions,
	},
	{
		code: 'TW',
		getSubregions: nullSubregions,
	},
	{
		code: 'TJ',
		getSubregions: nullSubregions,
	},
	{
		code: 'TZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'TH',
		getSubregions: nullSubregions,
	},
	{
		code: 'TL',
		getSubregions: nullSubregions,
	},
	{
		code: 'TG',
		getSubregions: nullSubregions,
	},
	{
		code: 'TK',
		getSubregions: nullSubregions,
	},
	{
		code: 'TO',
		getSubregions: nullSubregions,
	},
	{
		code: 'TT',
		getSubregions: nullSubregions,
	},
	{
		code: 'TN',
		getSubregions: nullSubregions,
	},
	{
		code: 'TR',
		getSubregions: nullSubregions,
	},
	{
		code: 'TM',
		getSubregions: nullSubregions,
	},
	{
		code: 'TC',
		getSubregions: nullSubregions,
	},
	{
		code: 'TV',
		getSubregions: nullSubregions,
	},
	{
		code: 'UG',
		getSubregions: nullSubregions,
	},
	{
		code: 'UA',
		getSubregions: nullSubregions,
	},
	{
		code: 'AE',
		getSubregions: nullSubregions,
	},
	{
		code: 'GB',
		getSubregions: nullSubregions,
	},
	{
		code: 'US',
		getSubregions: nullSubregions,
	},
	{
		code: 'UM',
		getSubregions: nullSubregions,
	},
	{
		code: 'UY',
		getSubregions: nullSubregions,
	},
	{
		code: 'UZ',
		getSubregions: nullSubregions,
	},
	{
		code: 'VU',
		getSubregions: nullSubregions,
	},
	{
		code: 'VE',
		getSubregions: nullSubregions,
	},
	{
		code: 'VN',
		getSubregions: nullSubregions,
	},
	{
		code: 'VG',
		getSubregions: nullSubregions,
	},
	{
		code: 'VI',
		getSubregions: nullSubregions,
	},
	{
		code: 'WF',
		getSubregions: nullSubregions,
	},
	{
		code: 'EH',
		getSubregions: nullSubregions,
	},
	{
		code: 'YE',
		getSubregions: nullSubregions,
	},
	{
		code: 'ZM',
		getSubregions: nullSubregions,
	},
	{
		code: 'ZW',
		getSubregions: nullSubregions,
	},

];


export default countries;