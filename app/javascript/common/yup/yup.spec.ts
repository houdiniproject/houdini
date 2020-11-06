// License: LGPL-3.0-or-later
// yup errors are super confusing until formik turns them into something logical
import { validateYupSchema, yupToFormErrors } from 'formik';

import * as yup from './';
import {createMessage, YupFail} from './';


describe("yup", () => {
	describe('.createMessage', () => {
		const nameLabel = 'Name';
		const customTranslationId = 'translation.id.path';
		it('createMessage creates the proper functions', async() => {
			expect.assertions(4);

			const schema = yup.object({
				name: yup.string().label(nameLabel).min(20),
				id: yup.string().required(createMessage(({ path}) => (new YupFail( customTranslationId, {path})))),
				address: yup.object({
					city: yup.string().required(),
					state: yup.string(),
				}),
			});


			// This is the equivalent of getting errors from the FormikContext
			/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
			let errors:any = null;
			try {
				await validateYupSchema({name: "not 20 chars"}, schema, false);
			}
			catch(e) {
				//turn into useful errors
				errors = yupToFormErrors(e);
			}

			expect(errors.name.message).toStrictEqual([{id:"yup.string.min"}, {path: nameLabel, min: 20}]);
			expect(errors.id.message).toStrictEqual([{id:customTranslationId}, {path: 'id'}]);
			expect(errors.address.city.message).toStrictEqual([{id:'yup.mixed.required'}, {path: 'address.city'}]);
			expect(errors.address.state).toBeUndefined();

		});

	});

});
