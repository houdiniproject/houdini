// License: LGPL-3.0-or-later
/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { useEffect, useRef } from 'react';
import { TextField } from './index';
import { action } from '@storybook/addon-actions';
import { Control, FormProvider, useForm, useWatch } from 'react-hook-form';
import useYup from '../../hooks/useYup';
import { yupResolver } from '@hookform/resolvers/yup';
import { Story } from '@storybook/react';
import { useId } from '@reach/auto-id';

function InnerForm(props: { control: Control<unknown>, onChange: (args: { value: string }) => void  }) {
	const { onChange, control } = props;
	const value = useWatch({ name: 'value', control });
	const onChangeRef = useRef(onChange);
	onChangeRef.current = onChange;
	useEffect(() => {
		onChangeRef.current({ value });
	}, [value, onChangeRef]);

	const id = useId();
	return <TextField name="value" label={'First Name'} control={control} id={id}/>;
}

function FormHandler(props: {
	onChange: (args: { value: string }) => void;
	schemaCreator?: (yup: ReturnType<typeof useYup>) => any;
	value?: string;
}) {

	const { value, schemaCreator, ...innerFormProps } = props;

	const yup = useYup();

	let useFormArgs: any = { defaultValues: { value: value || '' } };
	if (schemaCreator) {
		useFormArgs = { ...useFormArgs, resolver: yupResolver(schemaCreator(yup)) };
	}

	const form = useForm({ ...useFormArgs, mode: 'all' });

	const { handleSubmit } = form;
	return (
		<FormProvider {...form}>
			<form onSubmit={handleSubmit(() => { console.log("submitted"); })}>
				<InnerForm {...innerFormProps} control={form.control} />
			</form>
		</FormProvider>);
}

FormHandler.defaultProps = {
	// eslint-disable-next-line @typescript-eslint/no-empty-function
	onChange: () => { },
	locale: 'en',
};
export default { title: 'Form Fields/TextField' };

interface StoryProps {
	onChange: (args: { value: string }) => void;
	schemaCreator?: (yup: ReturnType<typeof useYup>) => any;
	value?: string;
}

const Template: Story<StoryProps> = (args) => <FormHandler {...args} />;

export const EmptyTextField = Template.bind({});
EmptyTextField.args = {
	onChange: action('on-change'),
};


export const StartingWithPenelopeSchultz = Template.bind({});
StartingWithPenelopeSchultz.args = {
	onChange: action('on-change'),
	value: "Penelope Schultz",
	schemaCreator: (yup: any) => yup.object({ value: yup.string().min(10).label("First Name") }),
};

export const EmptyTextFieldWithValidation = Template.bind({});
EmptyTextFieldWithValidation.args = {
	onChange: action('on-change'),
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	schemaCreator: (yup: any) => yup.object({ value: yup.string().min(10).label("First Name") }),
};

