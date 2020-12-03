// License: LGPL-3.0-or-later
import * as React from "react";
import { render, act,fireEvent, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import { Hoster, HosterContext } from '../../hooks/useHoster';
import noop from "lodash/noop";

import SignInPage from "./SignInPage";
import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";

/* NOTE: We're mocking calls to `/user/sign_in` */
jest.mock('../../legacy_react/src/lib/api/sign_in');
import webUserSignIn from '../../legacy_react/src/lib/api/sign_in';
import { IntlProvider } from "../intl";
import I18n from '../../i18n';
import { LocationMock } from '@jedmao/location';
const mockedWebUserSignIn = webUserSignIn as jest.Mocked<typeof webUserSignIn>;

type WrapperProps = React.PropsWithChildren<{hoster?:Hoster}>;

function Wrapper(props:WrapperProps) {
	return <HosterContext.Provider value={ {hoster: props.hoster || null} }>
		<IntlProvider locale={'en'} messages={I18n.translations['en'] as any } > {/* eslint-disable-line @typescript-eslint/no-explicit-any */}
			<MockCurrentUserProvider>
				{props.children}
			</MockCurrentUserProvider>
		</IntlProvider>
	</HosterContext.Provider>;
}

/**
//  * locationAssign is wrapper which provides you a spy to verify that
//  * window.location.assign has been called somewhere in the test. Make sure
//  * @param input a contents of your test as a function which accepts a
//  * jest.SpyInstance<void, [url: string]> and returns a Promise
//  */
async function locationAssign(input:(locationAssignSpy:jest.SpyInstance<void, [url: string]>) => Promise<void>) {
	const { location: savedLocation } = window;
	try {
		delete window.location;
		window.location = new LocationMock('http://test/');
		const locationAssignSpy = jest
			.spyOn(window.location, 'assign')
			.mockImplementationOnce(noop);

		await input(locationAssignSpy);
	}
	finally {
		window.location = savedLocation;
	}
}

describe('Links', () => {
	it('forgot Password Link has correct path', async () => {
		expect.assertions(1);
		const { getByText } = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
		const password = getByText("Forgot Password?");
		fireEvent.click(password);
		expect(password).toHaveAttribute('href', '/users/password/new');
	});
	it('get Started Link goes to correct path', () => {
		expect.assertions(1);
		const { getByText } = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
		const getStarted = getByText("Get Started");
		fireEvent.click(getStarted);
		// Link will be changed once correct path is available
		expect(getStarted).toHaveAttribute('href', '/users/password/new');
	});
	// it('terms & privacy Link has correct path', () => {
	// 	expect.assertions(1);
	// 	locationAssign(async (locationAssignSpy:jest.SpyInstance<void, [url: string]>) => {
	// 		mockedWebUserSignIn.postSignIn.mockResolvedValue({id: 1});
	// 		const {getByTestId, getByLabelText} = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
	// 		const terms = getByTestId('termsTest');
	// 		await act(async () => {
	// 			fireEvent.click(terms);
	// 		});
	// 		await waitFor(() => {
	// 			(expect(locationAssignSpy).toHaveBeenCalledWith('redirectUrl'));
	// 		});
	// 	});
	// });
});

describe ('useHoster', () => {
	it ('renders', () => {
		expect.assertions(1);
		const { getByTestId } = render (
			<Wrapper hoster= {null} >
				<SignInPage redirectUrl={"redirectUrl"}/>
			</Wrapper>
		);
		expect(getByTestId('hosterTest')).toHaveTextContent("");
	});
	it ('renders with hoster', () => {
		expect.assertions(1);
		const { getByTestId } = render (
			<Wrapper hoster= {{legalName: 'Houdini Hoster LLC'}}>
				<SignInPage redirectUrl={"redirectUrl"}/>
			</Wrapper>
		);
		expect(getByTestId('hosterTest')).toHaveTextContent('Houdini Hoster LLC');
	});
});

describe('redirectUrl', () => {
	it('has to redirect', async() => {
		expect.assertions(1);
		locationAssign(async (locationAssignSpy:jest.SpyInstance<void, [url: string]>) => {
			mockedWebUserSignIn.postSignIn.mockResolvedValue({id: 1});
			const {getByTestId, getByLabelText} = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
			const email = getByLabelText("Email");
			const password = getByLabelText("Password");
			fireEvent.change(email, { target: { value: 'validEmail@email.com' } });
			fireEvent.change(password, { target: { value: 'password' } });
			const button = getByTestId('signInButton');
			await act(async () => {
				fireEvent.click(button);
			});
			await waitFor(() => {
				(expect(locationAssignSpy).toHaveBeenCalledWith('redirectUrl'));
			});
		});
	});
});