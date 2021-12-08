
// License: LGPL-3.0-or-later
import * as React from "react";

import MuiTextField from '@material-ui/core/TextField';
import { TextFieldProps as MuiTextFieldProps } from '@material-ui/core/TextField';
import { Money, MoneyAsJson } from "../../common/money";
import { useIntl } from "../intl";
import { MutableRefObject, Ref, RefObject, useEffect, useRef } from "react";

import { useI18nCurrencyInput, Types } from '@houdiniproject/react-i18n-currency-input';
import '../../common/intl-polyfills/numberFormat';
import { Control, ControllerFieldState, ControllerRenderProps, FormState, useController, useFormContext } from "react-hook-form";

interface ConversionProps<T extends unknown=unknown>  {
	field: ControllerRenderProps<T, string>;
	fieldState: ControllerFieldState;
	formState: FormState<T>;
	onBlur?:(e:React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
	helperText?:React.ReactNode;
	disabled?:boolean;
	[others:string]:any;
}


export function fieldToTextField({
	field: { onBlur: fieldOnBlur, ref:refCallback, ...field },
	fieldState: {error, isTouched, ...otherFieldState},
	formState: { isSubmitting, ...otherFormState },
	onBlur,
	helperText,
	disabled,
	inputRef,
	...props
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
		...props,

		inputRef: (e) => {
			refCallback(e);
			if (inputRef) {
				inputRef.current = e
			}
		},
	};
}


export type ITextFieldProps = Omit<MuiTextFieldProps, 'value' | 'error'> & { control: Control<any> };

/**
 * A text field which accepts a Money value, uses useI18nCurrencyInput and returns a Money value for various callbacks
 *
 * @param {IMoneyTextFieldProps} { children, form, field, currencyDisplay, useGrouping, allowEmpty, selectAllOnFocus, ...props }
 * @returns {JSX.Element}
 */
function TextField({ children, control, name, ...props }: ITextFieldProps): JSX.Element {
	const {
		field,
		fieldState,
		formState,
	} = useController({
		name,
		control,
	});



	return <MuiTextField {...fieldToTextField({field, fieldState, formState, ...props})}>
		{children}
	</MuiTextField>;

}

export default TextField;