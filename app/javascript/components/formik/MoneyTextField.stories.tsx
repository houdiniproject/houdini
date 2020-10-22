// License: LGPL-3.0-or-later
import * as React from 'react';

import { Money } from '../../common/money';
import { useEffect } from 'react';
import { Formik, Field, useFormikContext } from 'formik';
import { MoneyTextField } from './index';
import { action } from '@storybook/addon-actions';

function FormikInner(props: { onChange:(args:{value:Money})=> void}) {
	const context = useFormikContext<{value:Money}>();
	const {value} = context.values;
	const {onChange} = props;
	useEffect(() => {
		onChange({value});
	}, [value, onChange]);

	return <><div><span aria-label="amount">{value.amount}</span><span aria-label="currency">{value.currency}</span></div>
		<Field component={MoneyTextField} name="value" aria-label="field" /></>;
}

function FormikHandler(props: { onChange:(args:{value:Money})=> void, value: Money}) {

	const {value, ...innerFormikProps} = props;
	return (<Formik initialValues={{ value }} onSubmit={() => { console.log("submitted");}} enableReinitialize={true}>
		<FormikInner {...innerFormikProps} />
	</Formik>);
}

FormikHandler.defaultProps = {
	// eslint-disable-next-line @typescript-eslint/no-empty-function
	onChange: () => {},
	locale: 'en',
};
export default { title: 'MoneyTextField' };

export function usd100() {
	const usd100 = Money.fromCents(100, 'usd');
	return <FormikHandler onChange={action('on-change')} value={usd100}/>;
}

export function jpy100() {
	const jpy100 = Money.fromCents(100, 'jpy');
	return <FormikHandler onChange={action('on-change')} value={jpy100}/>;
}
