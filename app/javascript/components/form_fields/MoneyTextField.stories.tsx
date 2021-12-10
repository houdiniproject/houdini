// License: LGPL-3.0-or-later
/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { useEffect, useRef } from 'react';

import { Money } from '../../common/money';
import { MoneyTextField } from './index';
import { action } from '@storybook/addon-actions';
import { Control, FormProvider, useForm, useWatch } from 'react-hook-form';

function FormInner(props: { control: Control<any>, onChange: (args: { value: Money }) => void }) {
	const { onChange, control } = props;
	const value = useWatch({ name: 'value', control });
	const onChangeRef = useRef(onChange);
	onChangeRef.current = onChange;
	useEffect(() => {
		onChangeRef.current({ value: Money.fromCents(value) });
	}, [value, onChangeRef]);

	return <><div><span aria-label="cents">{value.cents}</span> <span aria-label="currency">{value.currency}</span></div>
		<MoneyTextField name="value" aria-label="field" control={control} /></>;
}

function FormHandler(props: { onChange: (args: { value: Money }) => void, value: Money }) {

	const { value, ...innerFormProps } = props;
	const form = useForm({ defaultValues: { value: value.toJSON() } });
	const { handleSubmit } = form;
	return (
		<FormProvider {...form}>
			<form onSubmit={handleSubmit(() => { console.log("submitted"); })}>
				<FormInner {...innerFormProps} control={form.control} />
			</form>
		</FormProvider>);
}

FormHandler.defaultProps = {
	// eslint-disable-next-line @typescript-eslint/no-empty-function
	onChange: () => { },
	locale: 'en',
};
export default { title: 'Form Fields/MoneyTextField' };

export function usd100() {
	const usd100 = Money.fromCents(100, 'usd');
	return <FormHandler onChange={action('on-change')} value={usd100} />;
}

export function jpy100() {
	const jpy100 = Money.fromCents(100, 'jpy');
	return <FormHandler onChange={action('on-change')} value={jpy100} />;
}
