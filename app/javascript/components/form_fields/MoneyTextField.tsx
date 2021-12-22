
// License: LGPL-3.0-or-later
import * as React from "react";

import MuiTextField from '@material-ui/core/TextField';
import { TextFieldProps as MuiTextFieldProps } from '@material-ui/core/TextField';
import { Money, MoneyAsJson } from "../../common/money";
import { useIntl } from "../intl";
import { MutableRefObject, useEffect, useRef } from "react";

import { useI18nCurrencyInput, Types } from '@houdiniproject/react-i18n-currency-input';
import '../../common/intl-polyfills/numberFormat';
import { Control, ControllerFieldState, ControllerRenderProps, FormState, useController } from "react-hook-form";
import { useId } from "@reach/auto-id";

interface ConversionProps<T extends unknown=unknown>  {
	disabled?:boolean;
	field: ControllerRenderProps<T, string>;
	fieldState: ControllerFieldState;
	formState: FormState<T>;
	helperText?:React.ReactNode;
	inputRef: MutableRefObject<HTMLInputElement|null>;
	onBlur?:(e:React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
}


export function fieldToTextField({
	field: { onBlur: fieldOnBlur, ref:refCallback, ...field },
	fieldState: {error, isTouched},
	formState: { isSubmitting },
	onBlur,
	helperText,
	disabled,
	inputRef,
	...others
}: ConversionProps): MuiTextFieldProps {
	const fieldError = error?.message;
	const showError = isTouched && !!fieldError;

	return {
		error: showError,
		helperText: showError ? fieldError : helperText,
		disabled: disabled ?? isSubmitting,
		onBlur:
			onBlur ??
			function () {
				fieldOnBlur();
			},
		...field,
		...others,

		inputRef: (e) => {
			refCallback(e);
			inputRef.current = e;
		},
	};
}


export interface UseSerializeMoneyProps extends Omit<Types.UseI18nCurrencyInputProps, 'currency' | 'locale' | 'value'> {
	onChange: (e:Money) => void;
	value: Money;
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
export function useSerializeMoney(props: UseSerializeMoneyProps): ReturnType<typeof useI18nCurrencyInput> {
	const intl = useIntl();
	const { locale } = intl;
	const { value, ...other } = props;
	const { cents, currency } = value;
	const onChangeRef = useRef<(e:Money) => void>(props.onChange);

	const i18n = useI18nCurrencyInput({
		...other, locale,
		currency,
		value: cents,
	});

	onChangeRef.current = props.onChange;

	const {valueInCents:currenciedValue} = i18n;

	useEffect(() => {
		onChangeRef.current(Money.fromCents(currenciedValue, currency));
	}, [currenciedValue, currency]);


	return { ...i18n };
}


export type IMoneyTextFieldProps<TFieldValues = unknown> = Omit<MuiTextFieldProps, 'value' | 'error' |'inputRef'> &
	Omit<Types.UseI18nCurrencyInputProps, 'currency' | 'locale' | 'value' | 'inputRef' | 'inputType'> & { control?: Control<TFieldValues> };

/**
 * A text field which accepts a Money value, uses useI18nCurrencyInput and returns a Money value for various callbacks
 *
 * @param {IMoneyTextFieldProps} { children, form, field, currencyDisplay, useGrouping, allowEmpty, selectAllOnFocus, ...props }
 * @returns {JSX.Element}
 */
function MoneyTextField<TFieldValues=unknown>({ children,
	control,
	name,
	currencyDisplay,
	useGrouping,
	allowEmpty,
	selectAllOnFocus,
	id:passedId,
	...props }: IMoneyTextFieldProps<TFieldValues>): JSX.Element {
	const {
		field,
		fieldState,
		formState,
	} = useController({
		name,
		control,
	});

	const generatedId = useId();
	const id = passedId || generatedId;

	const value = Money.fromCents(field.value as MoneyAsJson);

	const inputRef = useRef<HTMLInputElement|null>();
	const { maskedValue, onChange,
		onFocus,
		onMouseUp,
		onSelect } = useSerializeMoney({ inputRef, value, currencyDisplay, useGrouping, allowEmpty, selectAllOnFocus, onChange: (e) => {
		field.onChange({target: {value: e.toJSON()}	});
	} });

	return <MuiTextField {...fieldToTextField({field, fieldState, formState, inputRef,  ...props})} value={maskedValue}
		onChange={onChange} onFocus={onFocus} onMouseUp={onMouseUp} onSelect={onSelect} id={id}>
		{children}
	</MuiTextField>;

}

export default MoneyTextField;