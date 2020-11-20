/* eslint-disable jest/no-commented-out-tests */
// License: LGPL-3.0-or-later
import * as React from "react";
import {render, act, fireEvent, waitFor, wait} from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import SignInComponent from './SignInComponent';
import { SignInError } from "../../legacy_react/src/lib/api/errors";
import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";

/* NOTE: We're mocking calls to `/user/sign_in` */
jest.mock('../../legacy_react/src/lib/api/sign_in');
import webUserSignIn from '../../legacy_react/src/lib/api/sign_in';
import { IntlProvider } from "../intl";
import I18n from '../../i18n';
const mockedWebUserSignIn = webUserSignIn as jest.Mocked<typeof webUserSignIn>;

function Wrapper(props:React.PropsWithChildren<unknown>) {
	return <IntlProvider messages={I18n.translations['en'] as any } locale={'en'}> {/* eslint-disable-line @typescript-eslint/no-explicit-any */}
		<MockCurrentUserProvider>
			{props.children}
		</MockCurrentUserProvider>
	</IntlProvider>;
}

//Testing email
describe('SignInComponent', () => {
	it('signIn successfully', async() => {
		expect.assertions(2);
		// const result = render(<Wrapper><SignInComponent/></Wrapper>);

		// // we're getting the first element an attribute named 'data-testid' and a
		// // of 'signInButton'
		// const button = result.getByTestId('signInButton');

		// // everytime you try to call the User SignIn API in this test, return a
		// // promise which resolves to {id: 1}
		// mockedWebUserSignIn.postSignIn.mockResolvedValue({id: 1});

		// // act puts all of the related React updates for the click event into a
		// // single update. Since fireEvent.click calls some promises, we need to make
		// // the callback a Promise and await on act. If we didn't, our test wouldn't
		// // wait for all the possible React changes to happen at once.
		// await act(async () => {
		// 	fireEvent.click(button);
		// });

		// const error = result.getByTestId('signInErrorDiv');
		// const userId = result.getByTestId('currentUserDiv');

		// expect(error).toBeEmptyDOMElement();
		// expect(userId).toHaveTextContent("1");
		const { getByTestId, getByLabelText } = render(<Wrapper><SignInComponent/></Wrapper>);
		const email = getByLabelText("Email");
		const password = getByLabelText("Password");
		const button = getByTestId('signInButton');
		//const success = getByTestId('signInComponentSuccess');
		fireEvent.change(email, { target: { value: 'validEmail@email.com' } });
		fireEvent.change(password, { target: { value: 'password' } });
		await waitFor(() => {
			expect(email).toBeValid();
			expect(password).toBeValid();
			fireEvent.click(button);
			// expect(success).toBeTruthy();
		});

	});

	it('signIn failed', async () => {
		expect.assertions(2);
		// everytime you try to call the User SignIn API in this test, return a
		// promise which rejects with a SignInError with status: 400 and data of
		// {error: 'Not Valid'}
		mockedWebUserSignIn.postSignIn.mockRejectedValueOnce(new SignInError({status: 400, data: {error: 'Not valid'}}));
		const result = render(<Wrapper><SignInComponent/></Wrapper>);

		const button = result.getByTestId('signInButton');
		await act(async () => {
			fireEvent.click(button);
		});

		const error = result.getByTestId('signInErrorDiv');
		const userId = result.getByTestId('currentUserDiv');

		expect(userId).toBeEmptyDOMElement();
		expect(error).toHaveTextContent('Not valid');
	});

	describe('Email', () => {
		it('renders', () => {
			expect.assertions(1);
			const {getByLabelText} = render(<Wrapper><SignInComponent/></Wrapper>);
			const email = getByLabelText("Email");
			expect(email).toBeInTheDocument();
		});

		it('renders error message on incorrect input', async () => {
			// We use hasAssertions() becuase the waitFor could attempt the assertion
			// toBeInvalid() multiple times waiting for it to update
			expect.hasAssertions();
			const { getByLabelText} = render(<Wrapper><SignInComponent/></Wrapper>);
			const email = getByLabelText("Email") as HTMLInputElement;

			// change changes the value
			fireEvent.change(email, {target: {value: "InvalidEmails"}});
			// blur makes the field "touched"
			fireEvent.blur(email);
			// just verify the value has been changed by the change event
			expect(email.value).toBe('InvalidEmails');

			// yup validation is an asynchronous task so we have a "waitFor" to keep
			// checking for up to 5 seconds. It should complete very quickly.
			await waitFor(() => {
				expect(email).toBeInvalid();
			});
		});
	});

	describe('Password', () => {
		it('renders', () => {
			expect.assertions(1);
			const {getByLabelText} = render(<Wrapper><SignInComponent/></Wrapper>);
			const password = getByLabelText("Password");
			expect(password).toBeInTheDocument();
		});
		it('renders error message if input is empty', async () => {
			expect.assertions(1);
			const { getByLabelText } = render(<Wrapper><SignInComponent/></Wrapper>);
			const password = getByLabelText("Password");
			fireEvent.change(password, { target: { value: '' } });
			await waitFor(() => {
				expect(getByLabelText("Password")).not.toBeNull();
			});
		});
	});

	describe('submit button', () => {
		it('is disabled when the form is not complete', async () => {
			expect.assertions(1);
			const { getByTestId, getByLabelText } = render(<Wrapper><SignInComponent/></Wrapper>);
			const email = getByLabelText("Email");
			fireEvent.change(email, { target: { value: 'invalidEmail' } });
			await waitFor(() => {
				expect(getByTestId('signInButton')).toBeDisabled();
			});
		});
		it('not disabled when form is complete', async () => {
			expect.assertions(1);
			const { getByTestId, getByLabelText } = render(<Wrapper><SignInComponent/></Wrapper>);
			const email = getByLabelText("Email");
			const password = getByLabelText("Password");
			fireEvent.change(email, { target: { value: 'validemail@valid.com' } });
			fireEvent.change(password, { target: { value: 'password' } });
			await waitFor(() => {
				expect(getByTestId('signInButton')).not.toBeDisabled();
			});
		});
	});
});





