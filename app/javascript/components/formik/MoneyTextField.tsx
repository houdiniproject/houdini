
// License: LGPL-3.0-or-later
import * as React from "react";

import MuiTextField from '@material-ui/core/TextField';
import { fieldToTextField, TextFieldProps } from 'formik-material-ui';
import { Money } from "../../common/money";
import { useHoudiniIntl } from "../intl";
import { useEffect, useRef } from "react";

import {useI18nCurrencyInput, Types} from '@houdiniproject/react-i18n-currency-input';
import '../../common/intl-polyfills/numberFormat';

export interface UseSerializeMoneyProps extends Omit<Types.UseI18nCurrencyInputProps, 'currency' | 'locale'|'value'> {
	value:Money;
}

/**
 * Hook for serializing a Money object to a string and back again. Particularly
 * useful for text fields.
 *
 * Example:
 * let money = new Money(100, 'usd')
 * let { serializedAmount, handleChange} = useSerializeMoney(money, (amount) => {money = amount})
 *
 * // serializedAmount gets $1.00 as a string. handleChange receives the new serializedvalue after a change
 * @param inputAmount a Money object
 * @param setOutputAmount used for passing up output of the Hook
 */
export function useSerializeMoney(props:UseSerializeMoneyProps) : ReturnType<typeof useI18nCurrencyInput> {
	const intl = useHoudiniIntl();
	const {locale} = intl;
	const {value, ...other} = props;
	const {amount, currency} = value;

	const i18n = useI18nCurrencyInput({...other, locale,
		currency,
		value:amount,
	});


	return {...i18n};
}

export type IMoneyTextFieldProps = Omit<TextFieldProps,'value'> &
	Omit<Types.UseI18nCurrencyInputProps, 'currency' | 'locale'|'value'| 'inputRef'|'inputType'> &
	{ value:Money };

/**
 * A text field which accepts a Money value, uses useI18nCurrencyInput and returns a Money value for various callbacks
 *
 * @param {IMoneyTextFieldProps} { children, form, field, currencyDisplay, useGrouping, allowEmpty, selectAllOnFocus, ...props }
 * @returns {JSX.Element}
 */
function MoneyTextField({ children, form, field, currencyDisplay, useGrouping, allowEmpty, selectAllOnFocus, ...props }:IMoneyTextFieldProps) : JSX.Element {
	const {name:fieldName, value} =  field;

	const inputRef = useRef<HTMLInputElement>();

	const {currency} = value;

	const { maskedValue, valueInCents,
		onChange,
		onFocus,
		onMouseUp,
		onSelect } = useSerializeMoney({ inputRef, value, currencyDisplay, useGrouping, allowEmpty, selectAllOnFocus});

	useEffect(() => {

		form.setFieldValue(fieldName, Money.fromCents(valueInCents, currency));

	}, [fieldName, valueInCents, currency]);


	return <MuiTextField {...fieldToTextField({form, field, ...props})} value={maskedValue}
		onChange={onChange} onFocus={onFocus} onMouseUp={onMouseUp} onSelect={onSelect} inputRef={inputRef}>
		{children}
	</MuiTextField>;

}

export default MoneyTextField;