// License: LGPL-3.0-or-later
/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { useEffect, useRef, useState } from 'react';
import { TextField } from './index';
import { action } from '@storybook/addon-actions';
import { Control, FormProvider, useForm, useWatch } from 'react-hook-form';
import useYup from '../../hooks/useYup';
import { yupResolver } from '@hookform/resolvers/yup';
import { Story } from '@storybook/react';
import { waitFor } from '@storybook/testing-library';
import { Button, Typography } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import noop from 'lodash/noop';
import { defaultProps } from '../../common/react';
import { defaultStoryExport } from '../../tests/stories';


export default defaultStoryExport({ title: 'Form Fields/TextField' });

function InnerForm({ disabled, onChange, control, helperText }: { control?: Control<unknown>, disabled?: boolean, helperText?: React.ReactNode, onChange: (args: { value: string }) => void }) {
	const value = useWatch({ name: 'value', control });
	const onChangeRef = useRef(onChange);
	onChangeRef.current = onChange;
	useEffect(() => {
		onChangeRef.current({ value });
	}, [value, onChangeRef]);

	return <TextField name="value" label={'First Name'} helperText={helperText} disabled={disabled} />;
}

function FormHandler(props: {
	helperText?: React.ReactNode;
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

	const [endSubmit, setEndSubmit] = useState(false);
	const endSubmitRef = useRef(endSubmit);
	endSubmitRef.current = endSubmit;
	const form = useForm({ ...useFormArgs, mode: 'all' });

	const { handleSubmit } = form;
	return (
		<FormProvider {...form}>
			<form onSubmit={handleSubmit(async () => {
				setEndSubmit(false);
				await waitFor(() => {
					if (!endSubmitRef.current) {
						throw new Error('still submitting');
					}
				}, { timeout: 5000 });
			}, () => {
				setEndSubmit(false);
			})}>

				<Grid container spacing={4}>
					<Grid item xs={12}>
						<Typography>If you&apos;d like to see what happens to the TextField component during submission, submit the form.<br /><small>(You can cancel the form submission as well.)</small></Typography>
					</Grid>
					<Grid item xs={12}>
						<InnerForm {...innerFormProps} />
					</Grid>


					<Grid container item xs={12} spacing={2}>
						<Grid item xs={2}>
							<Button type="submit" variant={"outlined"} data-testid="submit-button">Try Submit (submit ends in 5 seconds max)</Button>
						</Grid>
						<Grid item xs={2}>
							<Button onClick={() => setEndSubmit(true)} type='button' variant={"outlined"} data-testid="cancel-button">Cancel Submit</Button>
						</Grid>
					</Grid>


					<Grid item>
						<Typography> The form is <strong>{form.formState.isSubmitting ? <span data-testid="is-submitting">Submitting</span> : <span data-testid="is-not-submitting">Not Submitting</span>}</strong></Typography>
					</Grid>
					{form.formState.isValidating ? <input type="hidden" data-testid="is-validating" value={"validating"}/> : ""}
				</Grid>

			</form>
		</FormProvider>);
}

FormHandler.defaultProps = defaultProps(FormHandler,{
	onChange: noop,
});


interface StoryProps {
	helperText?: React.ReactNode;
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
	schemaCreator: (yup: any) => yup.object({ value: yup.string().min(10).label("First Name") }),
};

export const TextFieldWithHelperTextThatIsCoveredOnError = Template.bind({});
TextFieldWithHelperTextThatIsCoveredOnError.args = {
	onChange: action('on-change'),
	helperText: "HelperText",
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	schemaCreator: (yup: any) => yup.object({ value: yup.string().min(10).label("First Name") }),
};

export const DisabledTextField = Template.bind({});

DisabledTextField.args = {
	disabled: true,
};


