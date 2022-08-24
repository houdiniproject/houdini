// License: LGPL-3.0-or-later
import React from 'react';
import { renderHook } from '@testing-library/react-hooks';
import { yupResolver } from '@hookform/resolvers/yup';

import {IntlProvider, useIntl} from '../components/intl';
import I18n from '../i18n';
import useYup, {createMessage} from './useYup';
import {convert} from 'dotize';


function Wrapper(props:React.PropsWithChildren<unknown>) {
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	return <IntlProvider locale={'en'} messages={convert(I18n.translations['en'] as any) as any}>
		{props.children}
	</IntlProvider>;
}

describe("useYup", () => {
	const nameLabel = 'Custom Name';
	const customTranslationId = 'yup.mixed.default';
	it('has the correct messages for locale', async() => {
		expect.assertions(4);
		const {result:{ current: yup} } = renderHook(() => useYup(), {wrapper: Wrapper});
		const {result:{current: intl}} = renderHook(() => useIntl(), {wrapper: Wrapper});

		const schema = yup.object({
			name: yup.string().label(nameLabel).min(20),
			id: yup.string().required(createMessage(({ path}) => intl.formatMessage({id: customTranslationId}, {path}))),
			address: yup.object({
				city: yup.string().required(),
				state: yup.string(),
			}),
		});


		// This is the equivalent of getting errors from the FormikContext
		// eslint-disable-next-line @typescript-eslint/no-explicit-any


		const {errors:initialErrors} = 	await yupResolver(schema)({name: "not 20 chars"}, null,
			{
				fields:{},
				shouldUseNativeValidation: false,
			});

		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		const errors = initialErrors as Record<string,any>;

		expect(errors.name.message).toMatch(/.*Custom Name.+20.*/);
		expect(errors.id.message).toMatch(/.*id.*invalid.*/);
		expect(errors.address.city.message).toMatch(/.*address.city.*required.*/);
		expect(errors.address.state).toBeUndefined();

	});

});
