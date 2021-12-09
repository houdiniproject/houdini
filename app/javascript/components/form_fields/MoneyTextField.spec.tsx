/* eslint-disable jest/no-disabled-tests */

// License: LGPL-3.0-or-later

import React, { useEffect, useRef } from 'react';

import { render, fireEvent, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import {MoneyTextField} from './index';
import { Money } from '../../common/money';
import { IntlProvider } from '../intl';
import { FormProvider, useForm, useFormContext, useWatch } from 'react-hook-form';
import { useUpdateEffect } from 'react-use';


function InnerForm(props: { onChange:(args:{value:Money})=> void }) {
	const {control} = useFormContext<{value:Money}>();
	const value = useWatch({name: 'value', control});
	const {onChange} = props;
	useEffect(() => {
		onChange({value:Money.fromCents(value)});
	}, [value, onChange]);

	return <><div><span aria-label="amount">{value.cents}</span><span aria-label="currency">{value.currency}</span></div>
		<MoneyTextField name="value" aria-label="field" control={control}/></>;
}

function FormWrapper(props: { onChange:(args:{value:Money})=> void, value: Money}) {

	const {value, ...innerFormProps} = props;
	const form = useForm({defaultValues:{value:value.toJSON()}});
	const {reset} = form;
	const {cents, currency} = value.toJSON();
	useUpdateEffect(() => {
		reset({value: value.toJSON()});
	}, [cents, currency, reset]);

	const {onChange} = props;
	const onChangeRef = useRef(onChange);
	onChangeRef.current = onChange;
	useEffect(() => {
		onChangeRef.current({value:Money.fromCents(value)});
	}, [value, onChangeRef]);

	return <IntlProvider locale="en">
		<FormProvider {...form}>
			<form onSubmit={form.handleSubmit(() => console.log("submitted"))}>
				<InnerForm {...innerFormProps} />
			</form>
		</FormProvider>
	</IntlProvider>;
}

FormWrapper.defaultProps = {
	// eslint-disable-next-line @typescript-eslint/no-empty-function
	onChange: () => {},
};

describe('MoneyTextField', () => {
	it('displays the $8.00 when Money of {800, usd} is passed in', async () => {
		expect.hasAssertions();
		const result = render(<FormWrapper value={Money.fromCents({ cents: 800, currency: 'usd' })}  />);
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("$8.00");
		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("usd");
	});

	it('displays the 8.00 € when Money of {800, eur} is passed in', async () => {
		expect.hasAssertions();
		const result = render(<FormWrapper value={Money.fromCents({ cents: 800, currency: 'eur' })} />);
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("€8.00");
		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("eur");
	});

	it('displays the ¥800 when Money of {800, jpy} is passed in', async () => {
		expect.hasAssertions();
		const result = render(<FormWrapper value={Money.fromCents({ cents: 800, currency: 'jpy' })} />);
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("¥800");
		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("jpy");
	});


	it('displays the $8.00 when Money of {100, usd} is passed in and then the amount changes to 8.00', async () => {
		expect.hasAssertions();
		const result = render(<FormWrapper value={Money.fromCents({ cents: 100, currency: 'usd' })} />);
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("$1.00");

		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("100");
		expect(currency).toHaveTextContent("usd");

		await act(async () => {
			fireEvent.change(field, {target:{value: "$8.00"}});
		});

		expect(field).toHaveValue("$8.00");
		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("usd");
	});

	it('displays the $80.00 when Money of {800, usd} is passed in and then the amount changes to 8.000', async () => {
		expect.hasAssertions();
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		let result:any = null;
		await act(async() => result = render(<FormWrapper value={Money.fromCents({ cents: 800, currency: 'usd' })} />));
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("$8.00");

		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("usd");

		await act(async () => {
			fireEvent.change(field, {target:{value: "$8.000"}});
		});

		await waitFor(() => expect(field).toHaveValue("$80.00"));

		await waitFor(() => expect(amount).toHaveTextContent("8000"));
		expect(currency).toHaveTextContent("usd");
	});

	it('displays the $80.00 when Money of {800, usd} is passed in and then {8000, usd} is passed in', async () => {
		expect.hasAssertions();
		const {container, findByLabelText, rerender}  = render(<FormWrapper value={Money.fromCents({ cents:800, currency: 'usd' })} />, );
		const field = container.querySelector("input[name=value]");
		expect(field).toHaveValue("$8.00");

		const amount = await findByLabelText('amount');
		const currency = await findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("usd");


		rerender(<FormWrapper value={Money.fromCents({ cents:8000, currency: 'usd' })} />);
		await waitFor(() => expect(field).toHaveValue("$80.00"));
		expect(amount).toHaveTextContent("8000");
		expect(currency).toHaveTextContent("usd");


	});
});


