// License: LGPL-3.0-or-later
import * as React from 'react';

import { Money, MoneyAsJson } from '../../common/money';
import { useEffect } from 'react';
import { MoneyTextField } from './index';
import { action } from '@storybook/addon-actions';
import { Control, FormProvider, useForm, useFormContext, useWatch } from 'react-hook-form';

function FormikInner(props: { onChange: (args: { value: Money }) => void, control:Control<any> }) {
	const { onChange, control } = props;
	const value = useWatch({name:'value', control});
	useEffect(() => {
		onChange({ value: Money.fromCents(value) });
	}, [value, onChange]);

	return <><div><span aria-label="cents">{value.cents}</span> <span aria-label="currency">{value.currency}</span></div>
		<MoneyTextField name="value" aria-label="field" control={control} /></>;
}

function FormikHandler(props: { onChange: (args: { value: Money }) => void, value: Money }) {

	const { value, ...innerFormikProps } = props;
	const form = useForm({ defaultValues: { value: value.toJSON() } });
	const {handleSubmit} = form;
	return (
		<FormProvider {...form}>
			<form onSubmit={handleSubmit(() => { console.log("submitted");})}>
				<FormikInner {...innerFormikProps} control={form.control} />
			</form>
		</FormProvider>);
}

FormikHandler.defaultProps = {
	// eslint-disable-next-line @typescript-eslint/no-empty-function
	onChange: () => { },
	locale: 'en',
};
export default { title: 'MoneyTextField' };

export function usd100() {
	const usd100 = Money.fromCents(100, 'usd');
	return <FormikHandler onChange={action('on-change')} value={usd100} />;
}

export function jpy100() {
	const jpy100 = Money.fromCents(100, 'jpy');
	return <FormikHandler onChange={action('on-change')} value={jpy100} />;
}
