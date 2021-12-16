/* eslint-disable jest/no-hooks */
/* eslint-disable jest/no-commented-out-tests */
// License: LGPL-3.0-or-later
import * as React from "react";
import { render, fireEvent, waitFor, act, RenderResult } from '@testing-library/react';

import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom/extend-expect';

import SignInComponent from './SignInComponent';

import { IntlProvider } from "../intl";
import I18n from '../../i18n';
import { SWRConfig } from "swr";

import { axe } from 'jest-axe';


import { InitialCurrentUserContext } from "../../hooks/useCurrentUser";

import { server } from '../../api/mocks';
import { UserSignInFailed, UserSignsInOnFirstAttempt } from "../../hooks/mocks/useCurrentUserAuth";
import { MutableRefObject, useCallback, useState } from "react";
import { PinDropSharp } from "@material-ui/icons";

async function actRender(ui:React.ReactElement<any, string | ((props: any) => React.ReactElement<any, any>) | (new (props: any) => React.Component<any, any, any>)>): Promise<any>  {
	let ret: any = null;

	await act(async() => {ret = render(ui);});

	return ret;

}


function MainWrapper({cancelSWR, children}: React.PropsWithChildren<{ cancelSWR?: boolean }>,) {
	// const [cleanupSWR, setCleanupSWR] = useState(false);

	// const cancelSWRCB = useCallback(() => {
	// 	return setCleanupSWR(true);
	// }, [setCleanupSWR]);

	// cancelSWR.current = cancelSWRCB;

	const isPaused = useCallback(() => {
		return cancelSWR;
	}, [cancelSWR]);




	return <IntlProvider messages={I18n.translations['en'] as any} locale={'en'}> {/* eslint-disable-line @typescript-eslint/no-explicit-any */}
		<SWRConfig value={
			{
				dedupingInterval: 0, // we need to make SWR not dedupe
				provider: () => new Map(),
				isPaused,
			}
		}>
			{children}
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
			const { findByLabelText, findByTestId, container, rerender } =await actRender(<Wrapper><SignInComponent onSuccess={onSuccess} showProgressAndSuccess /></Wrapper>);
			const success = await findByTestId("signInComponentSuccess");
			const email = await findByLabelText("Email");
			const password = await findByLabelText("Password");
			userEvent.type(email, 'validEmail@email.com');
			userEvent.type(password, 'password');
			userEvent.tab();

			// we're getting the first element an attribute named 'data-testid' and a
			// of 'signInButton'
			const button = await findByTestId('signInButton');

			// act puts all of the related React updates for the click event into a
			// single update. Since fireEvent.click calls some promises, we need to make
			// the callback a Promise and await on act. If we didn't, our test wouldn't
			// wait for all the possible React changes to happen at once.

			await waitFor(() => { expect(button).toBeEnabled() });


			userEvent.click(button);

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

			await act(() => {
				rerender(<Wrapper cancelSWR={true}><SignInComponent onSuccess={onSuccess} showProgressAndSuccess /></Wrapper>);
			});
		});

		describe('Email', () => {
			// it('renders', () => {
			// 	expect.assertions(1);

			// 	const { getByLabelText } = act(() =>await actRender(<Wrapper><SignInComponent /></Wrapper>);
			// 	const email = getByLabelText("Email");
			// 	expect(email).toBeInTheDocument();
			// });

			it('checks email validation on correct input', async () => {
				// We use hasAssertions() becuase the waitFor could attempt the assertion
				// toBeInvalid() multiple times waiting for it to update
				expect.hasAssertions();
				const { getByLabelText, rerender } =await actRender(<Wrapper><SignInComponent /></Wrapper>);
				const email = getByLabelText("Email") as HTMLInputElement;
				//break it first so we know when the validation is done.
				userEvent.click(email);
				userEvent.tab();

				// yup validation is an asynchronous task so we have a "waitFor" to keep
				// checking for up to 5 seconds. It should complete very quickly.
				await waitFor(() => {
					expect(email).toBeInvalid();
				});

				userEvent.type(email, "ValidEmail@email.com");
				userEvent.tab();
				// just verify the value has been changed by the change event
				expect(email.value).toBe('ValidEmail@email.com');

				// yup validation is an asynchronous task so we have a "waitFor" to keep
				// checking for up to 5 seconds. It should complete very quickly.
				await waitFor(() => {
					expect(email).toBeValid();
				});

			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent /></Wrapper>));
			});

			it('checks email validation on incorrect input', async () => {
				// We use hasAssertions() becuase the waitFor could attempt the assertion
				// toBeInvalid() multiple times waiting for it to update
				expect.hasAssertions();
				const { getByLabelText, container, rerender } =await actRender(<Wrapper><SignInComponent /></Wrapper>);
				const email = getByLabelText("Email") as HTMLInputElement;

				userEvent.type(email, "InvalidEmails");
				userEvent.tab();
				// just verify the value has been changed by the change event
				expect(email.value).toBe('InvalidEmails');

				// yup validation is an asynchronous task so we have a "waitFor" to keep
				// checking for up to 5 seconds. It should complete very quickly.
				await waitFor(() => {
					expect(email).toBeInvalid();
				});
				const results = await axe(container);
				expect(results).toHaveNoViolations();
			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent /></Wrapper>))
			});
		});

		describe('Password', () => {
			// it('renders', () => {
			// 	expect.assertions(1);
			// 	const { getByLabelText } =await actRender(<Wrapper><SignInComponent /></Wrapper>);
			// 	const password = getByLabelText("Password");
			// 	expect(password).toBeInTheDocument();
			// });

			it('checks if password is valid', async () => {
				expect.hasAssertions();
				const { getByLabelText, rerender} =await actRender(<Wrapper><SignInComponent /></Wrapper>);
				const password = getByLabelText("Password") as HTMLInputElement;
				// change changes the value
				userEvent.click(password);
				userEvent.tab();

				await waitFor(() => {
					expect(password).toBeInvalid();
				});
				userEvent.type(password, '1234');
				userEvent.tab();

				// just verify the value has been changed by the change event
				expect(password.value).toBe('1234');
				await waitFor(() => {
					expect(password).toBeValid();
				});
			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent /></Wrapper>))
			});
			it('checks error messages on password', async () => {
				expect.assertions(1);
				const { getByLabelText, getByTestId, rerender } =await actRender(<Wrapper><SignInComponent /></Wrapper>);
				const input = getByLabelText('Password');
				userEvent.click(input);
				userEvent.tab();
				const Errors = getByTestId('errorTest');
				expect(Errors).toBeInTheDocument();
			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent /></Wrapper>))
			});

			it('checks if password is invalid', async () => {
				expect.hasAssertions();
				const { getByLabelText,rerender } =await actRender(<Wrapper><SignInComponent /></Wrapper>);
				const password = getByLabelText("Password") as HTMLInputElement;
				// change changes the value
				userEvent.click(password);
				userEvent.tab();
				// just verify the value has been changed by the change event
				expect(password.value).toBe('');

				await waitFor(() => {
					expect(password).toBeInvalid();
				});

			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent /></Wrapper>))
			});
		});



		describe('submit button', () => {
			it('is disabled when the form is not complete', async () => {
				expect.hasAssertions();
				const { getByTestId, getByLabelText, container, rerender } =await actRender(<Wrapper><SignInComponent showProgressAndSuccess /></Wrapper>);
				const email = getByLabelText("Email");
				userEvent.type(email, 'invalidEmail');
				userEvent.tab();

				await waitFor(() => {
					expect(getByTestId('signInButton')).toBeDisabled();
				});

				const results = await axe(container);
				expect(results).toHaveNoViolations();
			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent /></Wrapper>))
			});

			it('not disabled when form is complete', async () => {
				expect.hasAssertions();
				const { getByTestId, getByLabelText, container, rerender } =await actRender(<Wrapper><SignInComponent showProgressAndSuccess /></Wrapper>);
				const email = getByLabelText("Email");
				const password = getByLabelText("Password");
				userEvent.type(email, 'validemail@valid.com');
				userEvent.type(password, 'password');
				userEvent.tab();
				const button = getByTestId('signInButton');
				await waitFor(() => { expect(button).not.toBeDisabled(); });
				expect(button).not.toBeDisabled();
				const results = await axe(container);
				expect(results).toHaveNoViolations();

			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent /></Wrapper>))
			});
		});

		describe('signin failure', () => {
			beforeEach(() => {
				server.use(...UserSignInFailed);
			});

			async function signInFailureWrapper(): Promise<{ container: HTMLElement, error: HTMLElement, onFailure: () => unknown, rerender:any }> {
				const onFailure = jest.fn();
				const { findByLabelText, findByTestId, container,rerender } =await actRender(<Wrapper><SignInComponent onFailure={onFailure} showProgressAndSuccess /></Wrapper>);
				const email = await findByLabelText("Email");
				const password = await findByLabelText("Password");
				userEvent.type(email, 'validEmail@email.com');
				userEvent.type(password, 'password');
				userEvent.tab();
				const button = await findByTestId('signInButton');

				await waitFor(() => { !button.hasAttribute('disabled'); });

				userEvent.click(button);


				const error = await findByTestId('errorTest');

				return { error, onFailure, container, rerender };
			}
			it('has filled the error section and called onFailure', async () => {
				expect.hasAssertions();
				const { error, onFailure, container,rerender } = await signInFailureWrapper();

				await waitFor(() => {
					expect(error).toHaveTextContent('An unknown error occurred');
					expect(onFailure).toHaveBeenCalledTimes(1);
				});

				const results = await axe(container);
				expect(results).toHaveNoViolations();

			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent onFailure={onFailure} showProgressAndSuccess /></Wrapper>))
			});
		});
	});

	describe('initially signed in', () => {

		function Wrapper(props: React.PropsWithChildren<any>) {
			return (<MainWrapper cancelSWR={props.cancelSWR}>
				<InitialCurrentUserContext.Provider value={{ id: 1 }}>
					{props.children}
				</InitialCurrentUserContext.Provider>
			</MainWrapper>);
		}

		it('displays success message if user is already signed in', async () => {
			expect.hasAssertions();
			const { getByTestId, rerender } =await actRender(<Wrapper><SignInComponent showProgressAndSuccess /></Wrapper>);
			const success = getByTestId("signInComponentSuccess");
			await waitFor(() => {
				expect(success).toBeInTheDocument();
			});

		await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent showProgressAndSuccess /></Wrapper>))
		});

		it('fires onSuccess if user is already signed in', async () => {
			expect.hasAssertions();
			const onSuccess = jest.fn();
			const {rerender} =await actRender(<Wrapper><SignInComponent onSuccess={onSuccess} showProgressAndSuccess /></Wrapper>);
			await waitFor(() => {
				expect(onSuccess).toHaveBeenCalledTimes(1);
			});

			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent onSuccess={onSuccess} showProgressAndSuccess /></Wrapper>))
		});
	});

	describe('Progress bar and success message', () => {
		const Wrapper = MainWrapper;
		it('does not render', async () => {
			expect.hasAssertions();
			const finished = jest.fn();
			const { queryByTestId, getByLabelText, rerender } =await actRender(<Wrapper><SignInComponent onSuccess={finished} onFailure={finished} /></Wrapper>);
			const button = queryByTestId('signInButton');
			const email = getByLabelText("Email");
			const password = getByLabelText("Password");
			userEvent.type(email, 'validemail@valid.com');
			userEvent.type(password, 'password');
			const progressBar = queryByTestId("progressTest");

			await waitFor(() => expect(button).toBeEnabled());
			userEvent.click(button);

			expect(progressBar).toBeNull();
			await waitFor(() => expect(finished).toHaveBeenCalled());
			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent onSuccess={finished} showProgressAndSuccess /></Wrapper>));
		});
		it('renders progress bar and success message', async () => {
			expect.hasAssertions();
			const finished = jest.fn();
			const { getByTestId, getByLabelText, queryByTestId, container, rerender } =await actRender(<Wrapper><SignInComponent showProgressAndSuccess onSuccess={finished} onFailure={finished} /></Wrapper>);
			const button = getByTestId('signInButton');
			const email = getByLabelText("Email");
			const password = getByLabelText("Password");
			userEvent.type(email, 'validemail@valid.com');
			userEvent.type(password, 'password');

			await waitFor(() => {
				expect(button).toBeEnabled();
			});

			userEvent.click(button);

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
			await waitFor(() => expect(finished).toHaveBeenCalled());

			await act(async() => rerender(<Wrapper cancelSWR={true}><SignInComponent onSuccess={finished}  onFailure={finished} showProgressAndSuccess /></Wrapper>));
		});
	});
});
