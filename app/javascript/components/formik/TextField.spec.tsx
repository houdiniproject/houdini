/* eslint-disable jest/no-disabled-tests */

// License: LGPL-3.0-or-later

import React from 'react';

import { render, act } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import { composeStories } from '@storybook/testing-react';
import * as stories from './TextField.stories';
import userEvent from '@testing-library/user-event';
const { StartingWithPenelopeSchultz} = composeStories(stories);




describe('TextField', () => {
	describe('prefilled TextField', () => {
		let prefilledTextField:HTMLElement = null;
		beforeEach(() => {

			const { getByLabelText} = render(<StartingWithPenelopeSchultz />);

			prefilledTextField = getByLabelText('field');
		});

		it('is valid initially', async() => {
			expect.assertions(1);
			expect(prefilledTextField).toBeValid();
		});

		it('is valid when touched and then blurred', async () => {
			expect.assertions(1);

			await act(async() => {
				userEvent.click(prefilledTextField);
				prefilledTextField.blur();
			});
			expect(prefilledTextField).toBeValid();
		});

		it('is invalid when value is changed', async () => {
			expect.assertions(1);

			await act(async() => {
				userEvent.click(prefilledTextField);
				userEvent.type(prefilledTextField, "{selectall}{backspace}");
			});
			expect(prefilledTextField).toBeInvalid();
		});
	});
});


