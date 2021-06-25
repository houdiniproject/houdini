// License: LGPL-3.0-or-later
import * as React from "react";
import { render, act,fireEvent, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import { Hoster, HosterContext } from '../../hooks/useHoster';
import noop from "lodash/noop";

import SignInPage from "./SignInPage";
import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";
import { mocked } from "ts-jest/utils";

/* NOTE: We're mocking calls to `/user/sign_in` */
jest.mock('../../api/api/users');
jest.mock('../../api/users');
import {postSignIn} from '../../api/users';
import {getCurrent} from '../../api/api/users';
import { IntlProvider } from "../intl";
import I18n from '../../i18n';
import { LocationMock } from '@jedmao/location';

type WrapperProps = React.PropsWithChildren<{hoster?:Hoster}>;

function Wrapper(props:WrapperProps) {
	return <HosterContext.Provider value={props.hoster }>
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
	it('forgot password Link goes to correct path', async() => {
		expect.hasAssertions();
		locationAssign(async (locationAssignSpy:jest.SpyInstance<void, [url: string]>) => {
			const {getByText} = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
			const password = getByText("Forgot Password?");
			await act(async () => {
				fireEvent.click(password);
			});
			await waitFor(() => {
				expect(locationAssignSpy).toHaveBeenCalledWith('/users/password/new');
			});
		});
	});
	it ('get Started Link goes to correct path', async() => {
		expect.hasAssertions();
		locationAssign(async (locationAssignSpy:jest.SpyInstance<void, [url: string]>) => {
			const {getByText} = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
			await waitFor(() => {
				const getStarted = getByText("Get Started");
				fireEvent.click(getStarted);
				expect(locationAssignSpy).toHaveBeenCalledWith('/users/password/new');
			});
		});
	});
	it ('terms & privacy Link has correct path', () => {
		expect.hasAssertions();
		locationAssign(async (locationAssignSpy:jest.SpyInstance<void, [url: string]>) => {
			const {getByTestId} = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);
			await waitFor(() => {
				const terms = getByTestId('termsTest');
				fireEvent.click(terms);
				expect(locationAssignSpy).toHaveBeenCalledWith('/static/terms_and_privacy');
			});
		});
	});
});

describe ('useHoster', () => {
	it ('renders', async () => {
		expect.hasAssertions();
		const { getByTestId } = render (<Wrapper hoster={null} ><SignInPage redirectUrl={"redirectUrl"}/></Wrapper>);
		await waitFor(() => {
			expect(getByTestId('hosterTest')).toBeInTheDocument();
		});
	});
	it ('renders with hoster', async () => {
		expect.hasAssertions();
		const { getByTestId } = render (<Wrapper hoster= {{legal_name: 'Houdini Hoster LLC'}}><SignInPage redirectUrl={"redirectUrl"}/></Wrapper>);
		await waitFor(()=> {
			expect(getByTestId('hosterTest')).toHaveTextContent('Houdini Hoster LLC');

		});
	});
});

describe('redirectUrl', () => {
	it('has to redirect', async() => {
		expect.hasAssertions();
		locationAssign(async (locationAssignSpy:jest.SpyInstance<void, [url: string]>) => {
			mocked(postSignIn).mockResolvedValue({id: 1});
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