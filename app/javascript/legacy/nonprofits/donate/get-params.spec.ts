// License: LGPL-3.0-or-later

import getParams from './get-params';

describe('getParams', () => {
	describe('custom_amounts', () => {

		it('has default amounts', () => {

			const a = getParams();
			expect(a.custom_amounts).toEqual([10,25,50,100,250,500,1000]);
		});

		it('has passed in amounts', () => {
			const a = getParams({custom_amounts: '10_33,100;1000'});

			expect(a.custom_amounts).toEqual([10, 33, 100, 1000]);
		});

	});

	describe('multiple_designations', () => {
		it('has a default undefined multiple_designations', () => {
			const a = getParams();
			expect(a.multiple_designations).toBeUndefined();
		});

		it('has split multiple designations', () => {
			const a = getParams({multiple_designations: 'first,second;third_fourth'});

			expect(a.multiple_designations).toEqual(["first", "second", "third", "fourth"]);
		});
	});

	describe('custom_fields', () => {
		it('has a default undefined custom_fields', () => {
			const a = getParams();
			expect(a.custom_fields).toBeUndefined();
		});

		it('has split custom_fields', () => {
			const a = getParams({custom_fields: ' a:first_value ,b,c : value_two'});

			expect(a.custom_fields).toEqual([{
				name: "a",
				label: "first_value",
			},
			{
				name: "b",
				label: "b",
			},
			{
				name: "c",
				label: "value_two",
			},
			]);
		});
	});
});
