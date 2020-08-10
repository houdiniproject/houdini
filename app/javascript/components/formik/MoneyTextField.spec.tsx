/* eslint-disable jest/no-disabled-tests */

// License: LGPL-3.0-or-later

import React, { useEffect } from 'react';

import { render, fireEvent, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import {MoneyTextField} from './index';
import { Field, Formik, useFormikContext } from 'formik';
import { Money } from '../../common/money';
import { HoudiniIntlProvider } from '../intl';




function FormikInner(props: { onChange:(args:{value:Money})=> void}) {
	const context = useFormikContext<{value:Money}>();
	const {value} = context.values;
	const {onChange} = props;
	useEffect(() => {
		onChange({value});
	}, [value, onChange]);

	return <><div><span aria-label="amount">{value.amount}</span><span aria-label="currency">{value.currency}</span></div>
		<Field component={MoneyTextField} name="value" aria-label="field"/></>;
}

function FormikHandler(props: { value: Money, onChange:(args:{value:Money})=> void}) {

	const {value, ...innerFormikProps} = props;
	return <HoudiniIntlProvider locale="">

		<Formik initialValues={{ value }} onSubmit={() => { console.log("submitted");}} enableReinitialize={true}>
			<FormikInner {...innerFormikProps} />
		</Formik>
	</HoudiniIntlProvider>;
}

FormikHandler.defaultProps = {
	// eslint-disable-next-line @typescript-eslint/no-empty-function
	onChange: () => {}
};

describe('MoneyTextField', () => {
	it('displays the $8.00 when Money of {800, usd} is passed in', async () => {
		expect.hasAssertions();
		const result = render(<FormikHandler value={Money.fromCents({ amount: 800, currency: 'usd' })}  />);
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("$8.00");
		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("usd");
	});

	it('displays the 8.00 € when Money of {800, eur} is passed in', async () => {
		expect.hasAssertions();
		const result = render(<FormikHandler value={Money.fromCents({ amount: 800, currency: 'eur' })} />);
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("€8.00");
		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("eur");
	});

	it('displays the ¥800 when Money of {800, jpy} is passed in', async () => {
		expect.hasAssertions();
		const result = render(<FormikHandler value={Money.fromCents({ amount: 800, currency: 'jpy' })} />);
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("¥800");
		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("jpy");
	});


	it('displays the $8.00 when Money of {100, usd} is passed in and then the amount changes to 8.00', async () => {
		expect.hasAssertions();
		const result = render(<FormikHandler value={Money.fromCents({ amount: 100, currency: 'usd' })} />);
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("$1.00");

		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("100");
		expect(currency).toHaveTextContent("usd");

		act(() => {
			fireEvent.change(field, {target:{value: "$8.00"}});
		});

		expect(field).toHaveValue("$8.00");
		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("usd");
	});

	it('displays the $80.00 when Money of {800, usd} is passed in and then the amount changes to 8.000', async () => {
		expect.hasAssertions();
		const result = render(<FormikHandler value={Money.fromCents({ amount: 800, currency: 'usd' })} />);
		const field = result.container.querySelector("input[name=value]");
		expect(field).toHaveValue("$8.00");

		const amount = await result.findByLabelText('amount');
		const currency = await result.findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("usd");

		act(() => {
			fireEvent.change(field, {target:{value: "$8.000"}});
		});

		expect(field).toHaveValue("$80.00");
		expect(amount).toHaveTextContent("8000");
		expect(currency).toHaveTextContent("usd");
	});

	it('displays the $80.00 when Money of {800, usd} is passed in and then {8000, usd} is passed in', async () => {
		expect.hasAssertions();
		const {container, findByLabelText, rerender}  = render(<FormikHandler value={Money.fromCents({ amount:800, currency: 'usd' })} />, );
		const field = container.querySelector("input[name=value]");
		expect(field).toHaveValue("$8.00");

		const amount = await findByLabelText('amount');
		const currency = await findByLabelText('currency');

		expect(amount).toHaveTextContent("800");
		expect(currency).toHaveTextContent("usd");


		rerender(<FormikHandler value={Money.fromCents({ amount:8000, currency: 'usd' })} />);
		expect(amount).toHaveTextContent("8000");
		expect(currency).toHaveTextContent("usd");

		waitFor(() => expect(field).toHaveValue("$80.00"));
	});
});


