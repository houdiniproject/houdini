// License: LGPL-3.0-or-later
import * as React from 'react';
import { useEffect, useRef } from 'react';
import { TextField } from './index';
import { action } from '@storybook/addon-actions';
import { Control, FormProvider, useForm, useWatch } from 'react-hook-form';
import useYup from '../../hooks/useYup';
import { AnySchemaConstructor } from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { Story } from '@storybook/react';

function FormikInner(props: { onChange: (args: { value: string }) => void, control: Control<any> }) {
	const { onChange, control } = props;
	const value = useWatch({ name: 'value', control });
	const onChangeRef = useRef(onChange);
	onChangeRef.current = onChange;
	useEffect(() => {
		onChangeRef.current({ value });
	}, [value, onChangeRef]);

	return <><div><span aria-label="cents">{value.cents}</span> <span aria-label="currency">{value.currency}</span></div>
		<TextField name="value" aria-label="field" control={control} /></>;
}

function FormHandler(props: {
	onChange: (args: { value: string }) => void; value?: string;
	schemaCreator?: (yup: ReturnType<typeof useYup>) => any;
}) {

	const { value, schemaCreator, ...innerFormikProps } = props;

	const yup = useYup();

	let useFormArgs: any = { defaultValues: { value: value || '' } };
	if (schemaCreator) {
		useFormArgs = { ...useFormArgs, resolver: yupResolver(schemaCreator(yup)) };
	}

	const form = useForm(useFormArgs);

	const { handleSubmit } = form;
	return (
		<FormProvider {...form}>
			<form onSubmit={handleSubmit(() => { console.log("submitted"); })}>
				<FormikInner {...innerFormikProps} control={form.control} />
			</form>
		</FormProvider>);
}

FormHandler.defaultProps = {
	// eslint-disable-next-line @typescript-eslint/no-empty-function
	onChange: () => { },
	locale: 'en',
};
export default { title: 'TextField' };

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
};

export const EmptyTextFieldWithValidation = Template.bind({});
EmptyTextFieldWithValidation.args = {
	onChange: action('on-change'),
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	schemaCreator: (yup:any) => yup.object({ value: yup.string().min(10) }),
};

