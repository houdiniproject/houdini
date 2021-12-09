/* eslint-disable jest/no-hooks */
/* eslint-disable jest/no-commented-out-tests */
// License: LGPL-3.0-or-later
import * as React from "react";
import { render, act, fireEvent, waitFor } from '@testing-library/react';
import 'app/javascript/components/form_fields/node_modules/@testing-library/jest-dom/extend-expect';

import SignInComponent from './SignInComponent';

import { IntlProvider } from "../intl";
import I18n from '../../i18n';
import { SWRConfig } from "swr";

import { axe } from 'jest-axe';


import { InitialCurrentUserContext } from "../../hooks/useCurrentUser";

import { server } from '../../api/mocks';
import { UserSignInFailed, UserSignsInOnFirstAttempt } from "../../hooks/mocks/useCurrentUserAuth";

function MainWrapper(props: React.PropsWithChildren<unknown>) {
	return <IntlProvider messages={I18n.translations['en'] as any} locale={'en'}> {/* eslint-disable-line @typescript-eslint/no-explicit-any */}
		<SWRConfig value={
			{
				dedupingInterval: 0, // we need to make SWR not dedupe
				provider: () => new Map(),
			}
		}>
			{props.children}
		</SWRConfig>;
	</IntlProvider>;
}

describe('SignInComponent', () => {
	beforeEach(() => {
		server.use(...UserSignsInOnFirstAttempt);
	});
	describe('initially not signed in', () => {
		const Wrapper = MainWrapper;

		it('signIn is successful', async () => {
			expect.hasAssertions();
			const onSuccess = jest.fn();
			const { findByLabelText, findByTestId, container } = render(<Wrapper><SignInComponent onSuccess={onSuccess} showProgressAndSuccess /></Wrapper>);
			const success = await findByTestId("signInComponentSuccess");
			const email = await findByLabelText("Email");
			const password = await findByLabelText("Password");
			fireEvent.change(email, { target: { value: 'validEmail@email.com' } });
			fireEvent.change(password, { target: { value: 'password' } });

			// we're getting the first element an attribute named 'data-testid' and a
			// of 'signInButton'
			const button = await findByTestId('signInButton');

			// act puts all of the related React updates for the click event into a
			// single update. Since fireEvent.click calls some promises, we need to make
			// the callback a Promise and await on act. If we didn't, our test wouldn't
			// wait for all the possible React changes to happen at once.

			await waitFor(() => { !button.hasAttribute('disabled'); });

			act(() => {
				fireEvent.click(button);
			});

			await waitFor(() => {
				expect(success).toBeInTheDocument();
			});

			await waitFor(() => {
				expect(onSuccess).toHaveBeenCalledTimes(1);
				expect(email).not.toBeInTheDocument();
				expect(password).not.toBeInTheDocument();
			});

			const results = await axe(container);
			expect(results).toHaveNoViolations();
		});

		describe('Email', () => {
			it('renders', () => {
				expect.assertions(1);
				const { getByLabelText } = render(<Wrapper><SignInComponent /></Wrapper>);
				const email = getByLabelText("Email");
				expect(email).toBeInTheDocument();
			});

			it('checks email validation on correct input', async () => {
				// We use hasAssertions() becuase the waitFor could attempt the assertion
				// toBeInvalid() multiple times waiting for it to update
				expect.hasAssertions();
				const { getByLabelText } = render(<Wrapper><SignInComponent /></Wrapper>);
				const email = getByLabelText("Email") as HTMLInputElement;

				// change changes the value
				fireEvent.change(email, { target: { value: "ValidEmail@email.com" } });
				// blur makes the field "touched"
				fireEvent.blur(email);
				// just verify the value has been changed by the change event
				expect(email.value).toBe('ValidEmail@email.com');

				// yup validation is an asynchronous task so we have a "waitFor" to keep
				// checking for up to 5 seconds. It should complete very quickly.
				await waitFor(() => {
					expect(email).toBeValid();
				});
			});

			it('checks email validation on incorrect input', async () => {
				// We use hasAssertions() becuase the waitFor could attempt the assertion
				// toBeInvalid() multiple times waiting for it to update
				expect.hasAssertions();
				const { getByLabelText, container } = render(<Wrapper><SignInComponent /></Wrapper>);
				const email = getByLabelText("Email") as HTMLInputElement;

				// change changes the value
				fireEvent.change(email, { target: { value: "InvalidEmails" } });
				// blur makes the field "touched"
				fireEvent.blur(email);
				// just verify the value has been changed by the change event
				expect(email.value).toBe('InvalidEmails');

				// yup validation is an asynchronous task so we have a "waitFor" to keep
				// checking for up to 5 seconds. It should complete very quickly.
				await waitFor(() => {
					expect(email).toBeInvalid();
				});
				const results = await axe(container);
				expect(results).toHaveNoViolations();
			});

			it('renders error message on incorrect email', async () => {
				// We use hasAssertions() becuase the waitFor could attempt the assertion
				// toBeInvalid() multiple times waiting for it to update
				expect.hasAssertions();
				const { getByLabelText, getByTestId, container } = render(<Wrapper><SignInComponent /></Wrapper>);
				const email = getByLabelText("Email") as HTMLInputElement;
				const error = getByTestId("errorTest");
				const button = getByTestId('signInButton');

				// change changes the value
				fireEvent.change(email, { target: { value: "InvalidEmails" } });
				// blur makes the field "touched"
				fireEvent.blur(email);
				// just verify the value has been changed by the change event
				expect(email.value).toBe('InvalidEmails');

				// yup validation is an asynchronous task so we have a "waitFor" to keep
				// checking for up to 5 seconds. It should complete very quickly.
				await waitFor(() => {
					fireEvent.click(button);
					expect(error).toBeInTheDocument();
				});

				const results = await axe(container);
				expect(results).toHaveNoViolations();
			});
		});

		describe('Password', () => {
			it('renders', () => {
				expect.assertions(1);
				const { getByLabelText } = render(<Wrapper><SignInComponent /></Wrapper>);
				const password = getByLabelText("Password");
				expect(password).toBeInTheDocument();
			});

			it('checks if password is valid', async () => {
				expect.hasAssertions();
				const { getByLabelText } = render(<Wrapper><SignInComponent /></Wrapper>);
				const password = getByLabelText("Password") as HTMLInputElement;
				// change changes the value
				fireEvent.change(password, { target: { value: "1234" } });
				// blur makes the field "touched"
				fireEvent.blur(password);
				// just verify the value has been changed by the change event
				expect(password.value).toBe('1234');
				fireEvent.click(password);
				await waitFor(() => {
					expect(password).toBeValid();
				});
			});
			it('checks error messages on password', async () => {
				expect.assertions(1);
				const { getByLabelText, getByTestId } = render(<Wrapper><SignInComponent /></Wrapper>);
				const input = getByLabelText('Password');
				fireEvent.blur(input);
				const Errors = getByTestId('errorTest');
				expect(Errors).toBeInTheDocument();
			});

			it('checks if password is invalid', async () => {
				expect.hasAssertions();
				const { getByLabelText } = render(<Wrapper><SignInComponent /></Wrapper>);
				const password = getByLabelText("Password") as HTMLInputElement;
				// change changes the value
				fireEvent.change(password, { target: { value: "" } });
				// blur makes the field "touched"
				fireEvent.blur(password);
				// just verify the value has been changed by the change event
				expect(password.value).toBe('');
				fireEvent.click(password);
				await waitFor(() => {
					expect(password).toBeInvalid();
				});
			});
		});

		describe('submit button', () => {
			it('is disabled when the form is not complete', async () => {
				expect.hasAssertions();
				const { getByTestId, getByLabelText, container } = render(<Wrapper><SignInComponent showProgressAndSuccess /></Wrapper>);
				const email = getByLabelText("Email");
				fireEvent.change(email, { target: { value: 'invalidEmail' } });
				await waitFor(() => {
					expect(getByTestId('signInButton')).toBeDisabled();
				});

				const results = await axe(container);
				expect(results).toHaveNoViolations();
			});

			it('not disabled when form is complete', async () => {
				expect.assertions(2);
				const { getByTestId, getByLabelText, container } = render(<Wrapper><SignInComponent showProgressAndSuccess /></Wrapper>);
				const email = getByLabelText("Email");
				const password = getByLabelText("Password");
				fireEvent.change(email, { target: { value: 'validemail@valid.com' } });
				fireEvent.change(password, { target: { value: 'password' } });
				const button = getByTestId('signInButton');
				await waitFor(() => { !button.hasAttribute('disabled'); });
				expect(button).not.toBeDisabled();
				const results = await axe(container);
				expect(results).toHaveNoViolations();
			});
		});

		describe('signin failure', () => {
			beforeEach(() => {
				server.use(...UserSignInFailed);
			});

			async function signInFailureWrapper(): Promise<{ container:HTMLElement, error: HTMLElement, onFailure: () => unknown }> {
				const onFailure = jest.fn();
				const { findByLabelText, findByTestId, container } = render(<Wrapper><SignInComponent onFailure={onFailure} showProgressAndSuccess /></Wrapper>);
				const email = await findByLabelText("Email");
				const password = await findByLabelText("Password");
				fireEvent.change(email, { target: { value: 'validEmail@email.com' } });
				fireEvent.change(password, { target: { value: 'password' } });
				const button = await findByTestId('signInButton');

				await waitFor(() => { !button.hasAttribute('disabled'); });

				act(() => {
					fireEvent.click(button);
				});

				const error = await findByTestId('errorTest');

				return { error, onFailure, container };
			}
			it('has filled the error section and called onFailure', async () => {
				expect.hasAssertions();
				const { error, onFailure, container } = await signInFailureWrapper();

				await waitFor(() => {
					expect(error).toHaveTextContent('An unknown error occurred');
					expect(onFailure).toHaveBeenCalledTimes(1);
				});

				const results = await axe(container);
				expect(results).toHaveNoViolations();
			});
		});
	});

	describe('initially signed in', () => {
		function Wrapper(props: React.PropsWithChildren<unknown>) {
			return (<MainWrapper>
				<InitialCurrentUserContext.Provider value={{ id: 1 }}>
					{props.children}
				</InitialCurrentUserContext.Provider>
			</MainWrapper>);
		}

		it('displays success message if user is already signed in', async () => {
			expect.hasAssertions();
			const { getByTestId } = render(<Wrapper><SignInComponent showProgressAndSuccess /></Wrapper>);
			const success = getByTestId("signInComponentSuccess");
			await waitFor(() => {
				expect(success).toBeInTheDocument();
			});
		});

		it('fires onSuccess if user is already signed in', async () => {
			expect.hasAssertions();
			const onSuccess = jest.fn();
			render(<Wrapper><SignInComponent onSuccess={onSuccess} showProgressAndSuccess /></Wrapper>);
			await waitFor(() => {
				expect(onSuccess).toHaveBeenCalledTimes(1);
			});
		});
	});

	describe('Progress bar and success message', () => {
		const Wrapper = MainWrapper;
		it('does not render', async () => {
			expect.assertions(1);
			const { queryByTestId, getByLabelText } = render(<Wrapper><SignInComponent /></Wrapper>);
			const button = queryByTestId('signInButton');
			const email = getByLabelText("Email");
			const password = getByLabelText("Password");
			fireEvent.change(email, { target: { value: 'validemail@valid.com' } });
			fireEvent.change(password, { target: { value: 'password' } });
			const progressBar = queryByTestId("progressTest");
			await act(async () => {
				fireEvent.click(button);
			});
			expect(progressBar).toBeNull();
		});
		it('renders progress bar and success message', async () => {
			expect.hasAssertions();
			const { getByTestId, getByLabelText, queryByTestId, container } = render(<Wrapper><SignInComponent showProgressAndSuccess /></Wrapper>);
			const button = getByTestId('signInButton');
			const email = getByLabelText("Email");
			const password = getByLabelText("Password");
			fireEvent.change(email, { target: { value: 'validemail@valid.com' } });
			fireEvent.change(password, { target: { value: 'password' } });

			await waitFor(() => {
				expect(button).toBeEnabled();
			});

			act(() => {
				fireEvent.submit(button);
			});

			await waitFor(() => {
				const progressBar = queryByTestId("progressTest");
				expect(progressBar).toBeInTheDocument();
			});

			let results = await axe(container);
			expect(results).toHaveNoViolations();

			await waitFor(() => {
				const successAlert = queryByTestId("signInComponentSuccess");
				expect(successAlert).toBeInTheDocument();
			});

			results = await axe(container);
			expect(results).toHaveNoViolations();
		});
	});
});
