// License: LGPL-3.0-or-later
import React from 'react';
import { renderHook } from '@testing-library/react-hooks';
// yup errors are super confusing until formik turns them into something logical
import { validateYupSchema, yupToFormErrors } from 'formik';

import {IntlProvider, useIntl} from '../components/intl';
import I18n from '../i18n';
import useYup, {createMessage} from './useYup';


function Wrapper(props:React.PropsWithChildren<unknown>) {
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	return <IntlProvider locale={'en'} messages={I18n.translations['en'] as any}>
		{props.children}
	</IntlProvider>;
}

describe("useYup", () => {
	const nameLabel = 'Custom Name';
	const customTranslationId = 'yup.mixed.default';
	it('has the correct messages for locale', async() => {
		expect.assertions(4);
		const {result } = renderHook(() => useYup(), {wrapper: Wrapper});
		const intl = renderHook(() => useIntl(), {wrapper: Wrapper});
		const yup = result.current;
		const schema = yup.object({
			name: yup.string().label(nameLabel).min(20),
			id: yup.string().required(createMessage(({ path}) => intl.result.current.formatMessage({id: customTranslationId}, {path}))),
			address: yup.object({
				city: yup.string().required(),
				state: yup.string(),
			}),
		});


		// This is the equivalent of getting errors from the FormikContext
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		let errors:any = null;
		try {
			await validateYupSchema({name: "not 20 chars"}, schema, false);
		}
		catch(e) {
			//turn into useful errors
			errors = yupToFormErrors(e);
		}

		expect(errors.name).toMatch(/.*Custom Name.+20.*/);
		expect(errors.id).toMatch(/.*id.*invalid.*/);
		expect(errors.address.city).toMatch(/.*address.city.*required.*/);
		expect(errors.address.state).toBeUndefined();

	});

});
