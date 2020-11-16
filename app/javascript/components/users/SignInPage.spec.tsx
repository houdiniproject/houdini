// License: LGPL-3.0-or-later
import * as React from "react";
import { render, fireEvent, act, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import {ErrorBoundary, useErrorHandler} from 'react-error-boundary';


import SignInPage from "./SignInPage";

import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";

/* NOTE: We're mocking calls to `/user/sign_in` */
jest.mock('../../legacy_react/src/lib/api/sign_in');
import webUserSignIn from '../../legacy_react/src/lib/api/sign_in';
import { IntlProvider } from "../intl";
import I18n from '../../i18n';
import SignInComponent from "./SignInComponent";
const mockedWebUserSignIn = webUserSignIn as jest.Mocked<typeof webUserSignIn>;

function Wrapper(props:React.PropsWithChildren<unknown>) {
	return <IntlProvider messages={I18n.translations['en'] as any} locale={'en'}>
		<MockCurrentUserProvider>
			{props.children}
		</MockCurrentUserProvider>
	</IntlProvider>;

}

function SignInComponentErrorMock() {
	const handleError = useErrorHandler()
	handleError(new Error('err'));
	return <div></div>;
  }

describe('SignInPage', () => {
	it('signIn successfully', async() => {
		expect.assertions(1);
		const result = render(<Wrapper><SignInPage/></Wrapper>);

		const button = result.getByTestId('signInButton');
		// everytime you try to call the User SignIn API in this test, return a
		// promise which resolves to {id: 1}
		mockedWebUserSignIn.postSignIn.mockResolvedValue({id: 1});

		// act puts all of the related React updates for the click event into a
		// single update. Since fireEvent.click calls some promises, we need to make
		// the callback a Promise and await on act. If we didn't, our test wouldn't
		// wait for all the possible React changes to happen at once.
		await act(async () => {
			fireEvent.click(button);
		});

		const error = result.getByTestId('signInPageError');
		expect(error).toBeEmptyDOMElement();
	});

	it('signIn failed', async () => {
		expect.hasAssertions();
		const result = render(<Wrapper><SignInPage/></Wrapper>);

		const button = result.getByTestId('signInButton');
		// everytime you try to call the User SignIn API in this test, return a
		// promise which resolves to {id: 1}
		mockedWebUserSignIn.postSignIn.mockResolvedValue({id: 1});

		// act puts all of the related React updates for the click event into a
		// single update. Since fireEvent.click calls some promises, we need to make
		// the callback a Promise and await on act. If we didn't, our test wouldn't
		// wait for all the possible React changes to happen at once.
		await act(async () => {
			fireEvent.click(button);
		});

		const error = result.getByTestId('signInPageError');

		// Sometimes because of React's rendering cycle, the changes haven't been
		// made to the HTML by the time we need to expect. waitFor tries some sort
		// function multiple times until it passes (or 5 seconds have passed)
		waitFor(() => expect(error).toHaveTextContent("Ermahgerd! We had an error!"));
	});
});

//Testing error boundary
describe('<SignInPage>', () => {
	it('handles generic errors from child components', () => {
		jest.spyOn(global.console, 'error').mockImplementation(() => jest.fn());
		expect.hasAssertions()
		const result = render(<Wrapper><SignInPage SignInComponent={SignInComponentErrorMock} /></Wrapper>);
		const error = result.getByTestId('renderError');
		expect(error).toHaveTextContent("Something went wrong. Please reload the page.")
	})
});
