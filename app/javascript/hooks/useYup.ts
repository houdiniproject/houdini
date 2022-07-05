
// License: LGPL-3.0-or-later
import get from 'lodash/get';
import set from 'lodash/set';
import { useEffect } from 'react';
import { useIntl } from '../components/intl';
import type { IntlShape } from '../components/intl';
import * as yup from 'yup';

/**
 * Simply yup but with the default validation messages set to the current locale from `IntlProvider`
 * @description
 * @date 2020-11-05
 * @export
 * @returns yup
 */
export default function useYup(): typeof yup {
	const intl = useIntl();
	const { locale, messages } = intl;
	useEffect(() => {
		yup.setLocale(generateYupLocale(messages));
	}, [locale, messages]);
	return yup;
}


function generateYupLocale(messages: IntlShape['messages']) : typeof yupValidationMessagesToTranslationKeys {
	const newLocale:Partial<typeof yupValidationMessagesToTranslationKeys> = {};

	for (const childKey in yupValidationMessagesToTranslationKeys) {
		const child = get(yupValidationMessagesToTranslationKeys, childKey);
		const newChild= {};
		for (const subchildKey in child) {
			const subchild = get(child, subchildKey);
			const result = ((messages[subchild] as string) ||  subchild).replace(/%{/gi, "${");
			set(newChild, subchildKey, result);
		}

		set(newLocale, childKey, newChild);
	}

	return newLocale as typeof yupValidationMessagesToTranslationKeys;
}


const yupValidationMessagesToTranslationKeys = {
	mixed: {
		default: "yup.mixed.default",
		required: "yup.mixed.required",
		oneOf: "yup.mixed.oneOf",
		notOneOf: "yup.mixed.notOneOf",
	},
	string: {
		length: "yup.string.length",
		min: "yup.string.min",
		max: "yup.string.max",
		matches: "yup.string.regex",
		email: "yup.string.email",
		url: "yup.string.url",
		uuid: "yup.string.uuid",
		trim: "yup.string.trim",
		lowercase: "yup.string.lowercase",
		uppercase: "yup.string.uppercase",
	},
	number: {
		min: "yup.number.min",
		max: "yup.string.max",
		lessThan: "yup.number.lessThan",
		moreThan: "yup.number.moreThan",

		positive: "yup.number.postive",
		negative: "yup.number.negative",
		integer: "yup.number.integer",
	},
	date: {
		min: "yup.date.min",
		max: "yup.data.max",
	},

	boolean: {

	},
	object: {
		noUnknown: "yup.object.noUnknown",
	},

	array: {
		min: "yup.array.min",
		max: "yup.array.max",
	},
};

type RequiredValueProps = {path:string};
/**
 * A spec
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type TestOptionsMessageFn<Extra extends Record<string, any> = Record<string, any>, R = any> =
	| ((params: Extra & Partial<yup.TestMessageParams> & RequiredValueProps) => R);



// eslint-disable-next-line @typescript-eslint/no-explicit-any
type ToPropResult<Extra extends Record<string, any> = Record<string, any>> = TestOptionsMessageFn<Extra>;


/**
 * A function used for improving typescript safety when manually creating your
 * own validation messages
 * @param fn a function
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function createMessage<Extra extends Record<string, any> = Record<string, any>>(fn: ToPropResult<Extra>): ToPropResult<Extra> {
	return fn;
}