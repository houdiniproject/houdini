// License: LGPL-3.0-or-later

// based on app/javascript/legacy/nonprofits/donate/get-params.js

function splitParam(param: string | null| undefined) : string[] {
	if (param) {
		return param.split(/[_;,]/);
	}
	else {
		return [];
	}
}

function splitField(param: string) : {label:string, name:string }[] {
	if (param) {
		const individualFields = param.split(',');
		return individualFields.map(f => {
			const [name, label] = f.split(':').map(i => i.trim());
			return { name, label: label ? label : name };
		});
	}
	else {
		[];
	}
}

export default function getParams(params:NodeJS.Dict<string>)  : {
	custom_amounts: number[];
	custom_fields: {label:string, name:string }[];
	multiple_designations:string[];
}
{
	const defaultAmts = '10,25,50,100,250,500,1000';

	const {
		multiple_designations,
		custom_amounts,
		custom_fields,
		...other
	} = params;

	const result = {
		...other,
		multiple_designations: splitParam(multiple_designations),
		custom_amounts: splitParam(custom_amounts || defaultAmts).map(i => Number(i)),
		custom_fields: splitField(custom_fields),
	};
	return result;
}
