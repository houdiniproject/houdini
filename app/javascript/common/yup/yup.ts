/* eslint-disable @typescript-eslint/no-explicit-any */
import { setLocale, LocaleObject, TestMessageParams } from 'yup';
import type {IntlShape} from '../../components/intl';


/**
 * Wraps a validation failure from yup
 * @date 2020-10-24
 * @export
 * @class YupFail
 * @example
 * const schema = yup.schema({
 *  // we use createMessage to make sure we provide the correct function to min
 * 	name: yup.string.min(20, createMessage(
 * 		//we're taking the path and min properties of the min function's result
 * 		({path, label, min}) => {
 *			if (label) {
 *	 			// in yup messages, path represents the name of the field.
 * 				// if label is provided, that's a better name
 *				path = label;
 *			}
 * 			return new YupFail('translation.id.path',
 *          {path, min} // you HAVE to pass path here, even if the message doesn't use it
 * 			);
 * 		}
 * 	))
 * })
 *
 * // the yup schema was passed into Formik and formikConfig.errors has been set for the name
 * // field. We assume the `errors` const has latest formikConfig.errors
 *
 * // the below code is part of a TSX component
 * <ul className="errorListForName">
 * 	{
 * 		errors.name.map((yupFail:YupFail) => (
 * 				<li key={yupFail.id} className="errorItem">{formatMessage(...yupFail.message)</li>
 * 			)
 * 		)
 * 	}
 * </ul>
 *
 */
export class YupFail {

	/**
	 * Creates an instance of Description.
	 * @date 2020-10-24
	 * @param id the translation ID of the failure message
	 * @param values the values to be interpolated into the failure message ID'd by {@link id}
	 */
	constructor(readonly id: string, readonly values: Parameters<ToPropResult>[0]) {
		this.id = id;
		this.values = values;
		Object.bind(this, this.message);
	}

	get message(): Parameters<IntlShape['formatMessage']> {
		return [{id:this.id}, this.values];
	}

}
type RequiredValueProps = {path:string};
/**
 * A spec
 */
type TestOptionsMessageFn<Extra extends Record<string, any> = Record<string, any>, R = any> =
	| ((params: Extra & Partial<TestMessageParams> & RequiredValueProps) => R)



export type ToPropResult<Extra extends Record<string, any> = Record<string, any>> = TestOptionsMessageFn<Extra, YupFail>


/**
 * A function used for improving typescript safety when manually creating your
 * own validation messages
 * @param fn a function
 */
export function createMessage<Extra extends Record<string, any> = Record<string, any>>(fn: ToPropResult<Extra>): ToPropResult<Extra> {
	return fn;
}



// }

type HoudiniYupLocaleObject = Required<LocaleObject>;

// TODO: we could optimize this and only run it the first time the module is
// loaded

const locale: HoudiniYupLocaleObject = {
	mixed: {
		default: message("yup.mixed.default"),
		required: message("yup.mixed.required"),
		oneOf: message("yup.mixed.oneOf"),
		notOneOf: message("yup.mixed.notOneOf"),
	},
	string: {
		length: message("yup.string.length"),
		min: message("yup.string.min"),
		max: message("yup.string.max"),
		matches: message("yup.string.regex"),
		email: message("yup.string.email"),
		url: message("yup.string.url"),
		uuid: message("yup.string.uuid"),
		trim: message("yup.string.trim"),
		lowercase: message("yup.string.lowercase"),
		uppercase: message("yup.string.uppercase"),
	},
	number: {
		min: message("yup.number.min"),
		max: message("yup.string.max"),
		lessThan: message("yup.number.lessThan"),
		moreThan: message("yup.number.moreThan"),

		positive: message("yup.number.postive"),
		negative: message("yup.number.negative"),
		integer: message("yup.number.integer"),
	},
	date: {
		min: message("yup.date.min"),
		max: message("yup.data.max"),
	},

	boolean: {

	},
	object: {
		noUnknown: message("yup.object.noUnknown"),
	},

	array: {
		min: message("yup.array.min"),
		max: message("yup.array.max"),
	},
};

function message<Extra extends Record<string, any> = Record<string, unknown>>(id: string): ToPropResult<Extra> {
	// eslint-disable-next-line @typescript-eslint/no-unused-vars
	return createMessage(({ path, label, value, originalValue, ...other }) => {
		if (label) {
			path = label;
		}
		return new YupFail(id, { path, ...other });
	});
}
setLocale(locale);
