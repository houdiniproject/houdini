// License: LGPL-3.0-or-later

function splitParam(str: string) {
	return str.split(/[_;,]/);
}

interface InputParams {
  custom_amounts?: string;
  custom_fields?: string;
  multiple_designations?: string;
}

interface OutputParams {
  custom_amounts: number[];
  custom_fields?: { label: string, name: string }[];
  multiple_designations?: string[];
}

export default function getParams<TInput extends InputParams>(params?: TInput): OutputParams & Record<string, unknown> {
	const defaultAmts = '10,25,50,100,250,500,1000';

	return {
		...params,
		multiple_designations: params?.multiple_designations ? splitParam(params.multiple_designations) : undefined,
		custom_amounts: splitParam(params?.custom_amounts || defaultAmts).map((i) => Number(i)),
		custom_fields: params?.custom_fields?.split(',')?.map(f => {
			const [name, label] = f.split(':').map((i) => i.trim());
			return { name, label: label ? label : name };
		}),
	};
}
