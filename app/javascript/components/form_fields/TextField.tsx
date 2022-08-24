
// License: LGPL-3.0-or-later
import React, { MutableRefObject } from "react";

import MuiTextField from '@material-ui/core/TextField';
import { TextFieldProps as MuiTextFieldProps } from '@material-ui/core/TextField';
import { Control, ControllerFieldState, ControllerRenderProps, FieldPath, FieldValues, FormState, useController } from "react-hook-form";
import { useId } from "@reach/auto-id";

interface ConversionProps<T extends FieldValues> {
	disabled?:boolean;
	field: ControllerRenderProps<T>;
	fieldState: ControllerFieldState;
	formState: FormState<T>;
	helperText?:React.ReactNode;
	inputRef?: MutableRefObject<HTMLInputElement|null>;
	onBlur?:(e:React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
}


export function fieldToTextField<T extends FieldValues>({
	field: { onBlur: fieldOnBlur, ref:refCallback, ...field },
	fieldState: {error, isTouched},
	formState: { isSubmitting},
	onBlur,
	helperText,
	disabled,
	inputRef,
	...props
}: ConversionProps<T>): MuiTextFieldProps {
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


export type ITextFieldProps<TFieldValues extends FieldValues> = Omit<MuiTextFieldProps, 'value' | 'error' | 'inputRef'> & { control?: Control<TFieldValues>};

/**
 * A text field
 *
 * @param {ITextFieldProps}
 * @returns {JSX.Element}
 */
function TextField<TFieldValues extends FieldValues>({ children, control, name:knownName, id:passedId, ...props }: ITextFieldProps<TFieldValues>): JSX.Element {

	const name = knownName as unknown as FieldPath<TFieldValues>;
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





	return <MuiTextField {...fieldToTextField({ field, fieldState, formState,  ...props })} id={id}>
		{children}
	</MuiTextField>;

}

export default TextField;