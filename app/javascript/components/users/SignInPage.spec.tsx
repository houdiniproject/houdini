// License: LGPL-3.0-or-later
import * as React from "react";
import { render, fireEvent, act, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import noop from 'lodash/noop';
import { Hoster, HosterContext } from '../../hooks/useHoster';

import SignInPage from "./SignInPage";

import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";

/* NOTE: We're mocking calls to `/user/sign_in` */
jest.mock('../../legacy_react/src/lib/api/sign_in');
import webUserSignIn from '../../legacy_react/src/lib/api/sign_in';
import { IntlProvider } from "../intl";
import I18n from '../../i18n';
import {LocationMock} from '@jedmao/location';

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
 * locationAssign is wrapper which provides you a spy to verify that
 * window.location.assign has been called somewhere in the test. Make sure
 * @param input a contents of your test as a function which accepts a
 * jest.SpyInstance<void, [url: string]> and returns a Promise
 */
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

describe('SignInPage', () => {

	it('signIn successfully', async() => {
		expect.assertions(1);

		locationAssign(async (locationAssignSpy:jest.SpyInstance<void, [url: string]>) => {
			const result = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);

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

			// was document.location.assign called with redirectUrl?
			expect(locationAssignSpy).toHaveBeenCalledWith('redirectUrl');

			const error = result.getByTestId('signInPageError');
			expect(error).toBeEmptyDOMElement();
		});

	});

	it('signIn failed', async () => {
		expect.hasAssertions();

		locationAssign(async (locationAssignSpy:jest.SpyInstance<void, [url: string]>) => {

			const result = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);

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

			// was document.location.assign not called?
			expect(locationAssignSpy).not.toHaveBeenCalledWith('redirectUrl');

			const error = result.getByTestId('signInPageError');

			// Sometimes because of React's rendering cycle, the changes haven't been
			// made to the HTML by the time we need to expect. waitFor tries some sort
			// function multiple times until it passes (or 5 seconds have passed)
			waitFor(() => expect(error).toHaveTextContent("Ermahgerd! We had an error!"));
		});
	});

	it('renders signInComponent Correctly', () => {
		expect.hasAssertions();
		const { getByTestId } = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
		expect(getByTestId("SignInComponent")).toBeInTheDocument();
	});

});

describe('Links', () => {
	it('renders forgot password Link', () => {
		expect.assertions(1);
		const { getByTestId } = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
		fireEvent.click(getByTestId("passwordTest"));
		getByTestId('passwordTest').click();
		expect(getByTestId('passwordTest')).toBeInTheDocument();
	});
	it('renders get started Link', () => {
		expect.assertions(1);
		const { getByTestId } = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
		fireEvent.click(getByTestId("getStartedTest"));
		getByTestId('getStartedTest').click();
		expect(getByTestId('getStartedTest')).toBeInTheDocument();
	});
	it('renders terms & privacy Link', () => {
		expect.assertions(1);
		const { getByTestId } = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
		fireEvent.click(getByTestId("termsTest"));
		getByTestId('termsTest').click();
		expect(getByTestId('termsTest')).toBeInTheDocument();
	});
});

describe ('useHoster', () => {
	it ('renders', () => {
		expect.assertions(1);
		const { getByTestId } = render (
			<Wrapper hoster= {null} >
				<SignInPage redirectUrl={"redirectUrl"}/>
			</Wrapper>
		);
		expect(getByTestId('hosterTest')).toBeInTheDocument();
	});
	it ('renders with hoster', () => {
		expect.assertions(1);
		const { getByTestId } = render (
			<Wrapper hoster= {{legalName: 'Houdini Hoster LLC'}}>
				<SignInPage redirectUrl={"redirectUrl"}/>
			</Wrapper>
		);
		expect(getByTestId('hosterTest')).toBeInTheDocument();
	});
});


