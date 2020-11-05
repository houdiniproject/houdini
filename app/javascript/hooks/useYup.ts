
import get from 'lodash/get';
import cloneDeep from 'lodash/clone';
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
	const { locale, formatMessage } = intl;
	useEffect(() => {
		yup.setLocale(generateYupLocale(formatMessage));
	}, [locale, formatMessage]);
	return yup;
}


function generateYupLocale(formatMessage: IntlShape['formatMessage']) {
	const newLocale = cloneDeep(yupValidationMessagesToTranslationKeys);

	Object.keys(newLocale).forEach((field) => {
		const object = get(newLocale, field);
		Object.keys(object).forEach((k) => {
			const translationKey = object[k];
			// eslint-disable-next-line @typescript-eslint/no-unused-vars
			object[k] = createMessage(({ path, label, value, originalValue, ...other }) => {
				if (label) {
					path = label;
				}
				return formatMessage({ id: translationKey }, { path, ...other });
			});
		});
	});

	return newLocale;
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
type TestOptionsMessageFn<Extra extends Record<string, any> = Record<string, any>, R = any> =
	| ((params: Extra & Partial<yup.TestMessageParams> & RequiredValueProps) => R)



type ToPropResult<Extra extends Record<string, any> = Record<string, any>> = TestOptionsMessageFn<Extra>


/**
 * A function used for improving typescript safety when manually creating your
 * own validation messages
 * @param fn a function
 */
export function createMessage<Extra extends Record<string, any> = Record<string, any>>(fn: ToPropResult<Extra>): ToPropResult<Extra> {
	return fn;
}