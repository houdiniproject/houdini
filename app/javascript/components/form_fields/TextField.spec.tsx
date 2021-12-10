/* eslint-disable jest/no-disabled-tests */

// License: LGPL-3.0-or-later

import React from 'react';

import { render, act, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import { composeStories } from '@storybook/testing-react';
import * as stories from './TextField.stories';
import userEvent from '@testing-library/user-event';

const { StartingWithPenelopeSchultz, EmptyTextField, EmptyTextFieldWithValidation, TextFieldWithHelperTextThatIsCoveredOnError} = composeStories(stories);

describe('TextField', () => {
	describe('empty TextField', () => {
		let emptyTextField:HTMLElement = null;
		beforeEach(() => {

			const { getByLabelText} = render(<EmptyTextField />);

			emptyTextField = getByLabelText('First Name');
		});

		it('is valid initially', async() => {
			expect.assertions(1);
			expect(emptyTextField).toBeValid();
		});

		it('is valid when touched and then blurred', async () => {
			expect.assertions(1);

			await act(async() => {
				userEvent.click(emptyTextField);
				emptyTextField.blur();
			});
			expect(emptyTextField).toBeValid();
		});

		it('is valid when value is changed and then deleted', async () => {
			expect.assertions(1);
			await userEvent.type(emptyTextField, "enter some information{selectall}{backspace}");
			await act(async() => {
				emptyTextField.blur();
			});

			expect(emptyTextField).toBeValid();
		});
	});

	describe('prefilled TextField', () => {
		let prefilledTextField:HTMLElement = null;
		beforeEach(() => {

			const { getByLabelText} = render(<StartingWithPenelopeSchultz />);

			prefilledTextField = getByLabelText('First Name');
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
			await userEvent.type(prefilledTextField, "{selectall}{backspace}");
			await act(async() => {

				prefilledTextField.blur();
			});

			expect(prefilledTextField).toBeInvalid();
		});
	});

	describe('empty TextField with validation', () => {
		let emptyTextField:HTMLElement = null;
		beforeEach(() => {

			const { getByLabelText} = render(<EmptyTextFieldWithValidation />);

			emptyTextField = getByLabelText('First Name');
		});

		it('is valid initially', async() => {
			expect.assertions(1);
			expect(emptyTextField).toBeValid();
		});

		it('is invalid when touched and then blurred', async () => {
			expect.assertions(1);

			await act(async() => {
				userEvent.click(emptyTextField);
				emptyTextField.blur();
			});
			expect(emptyTextField).toBeInvalid();
		});

		it('is valid when value is changed to be longer than 10', async () => {
			expect.assertions(1);
			// We have to await here becuase validation takes a bit.
			await userEvent.type(emptyTextField, 'this is longer than 10');

			await act(async() => {

				emptyTextField.blur();
			});

			expect(emptyTextField).toBeValid();
		});
	});

	describe('empty TextField with helperText covered on Error', () => {
		let emptyTextField:HTMLElement = null;
		let helperElement:HTMLElement = null;
		beforeEach(() => {
			const { getByLabelText, getByText} = render(<TextFieldWithHelperTextThatIsCoveredOnError />);
			helperElement = getByText('HelperText');
			emptyTextField = getByLabelText('First Name');
		});

		it('shows helper text', async() => {
			expect.assertions(1);
			expect(helperElement).toHaveTextContent('HelperText');
		});

		it('shows error', async() => {
			expect.hasAssertions();
			userEvent.click(emptyTextField);
			userEvent.tab();
			await waitFor(() => expect(emptyTextField).toBeInvalid());
			expect(helperElement).toHaveTextContent('First Name must be at least 10 characters');
		});
	});
});


