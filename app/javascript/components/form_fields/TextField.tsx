
// License: LGPL-3.0-or-later
import React, { MutableRefObject } from "react";

import MuiTextField from '@material-ui/core/TextField';
import { TextFieldProps as MuiTextFieldProps } from '@material-ui/core/TextField';
import { Control, ControllerFieldState, FormState, useController, FieldValues, Path } from "react-hook-form";
import { useId } from "@reach/auto-id";

interface ConversionProps<T extends unknown = unknown> {
	disabled?:boolean;
	field: FieldValues;
	fieldState: ControllerFieldState;
	formState: FormState<T>;
	helperText?:React.ReactNode;
	inputRef?: MutableRefObject<HTMLInputElement|null>;
	onBlur?:(e:React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
}


export function fieldToTextField({
	field: { onBlur: fieldOnBlur, ref:refCallback, ...field },
	fieldState: {error, isTouched},
	formState: { isSubmitting},
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
				inputRef.current = e;
			}
		},
	};
}


export type ITextFieldProps<TFieldValues=unknown> = Omit<MuiTextFieldProps, 'value' | 'error' |'inputRef'> & { control?: Control<TFieldValues> };

/**
 * A text field
 *
 * @param {ITextFieldProps}
 * @returns {JSX.Element}
 */
function TextField<TFieldValues=unknown>({ children, control, name, id:passedId, ...props }: ITextFieldProps<TFieldValues>): JSX.Element {
	const {
		field,
		fieldState,
		formState,
	} = useController({
		name: name as Path<TFieldValues>,
		control,
	});

	const generatedId = useId();
	const id = passedId || generatedId;

	return <MuiTextField {...fieldToTextField({ field, fieldState, formState,  ...props })} id={id}>
		{children}
	</MuiTextField>;

}

export default TextField;