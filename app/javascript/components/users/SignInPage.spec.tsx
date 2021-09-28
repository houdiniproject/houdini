// License: LGPL-3.0-or-later
import * as React from "react";
import { render, act, fireEvent, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import { Hoster, HosterContext } from '../../hooks/useHoster';
import noop from "lodash/noop";

import SignInPage from "./SignInPage";
import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";
import { mocked } from "ts-jest/utils";

/* NOTE: We're mocking calls to `/user/sign_in` */

import { postSignIn } from '../../api/users';
import { IntlProvider } from "../intl";
import I18n from '../../i18n';
import { LocationMock } from '@jedmao/location';

jest.mock('../../api/users');
import { SWRConfig } from 'swr';


type WrapperProps = React.PropsWithChildren<{ hoster?: Hoster }>;

function Wrapper(props: WrapperProps) {
	return <HosterContext.Provider value={props.hoster}>
		<IntlProvider locale={'en'} messages={I18n.translations['en'] as any} > {/* eslint-disable-line @typescript-eslint/no-explicit-any */}
			<SWRConfig value={
				{
					dedupingInterval: 0, // we need to make SWR not dedupe
					revalidateOnMount: true,
					revalidateOnFocus: true,
					revalidateOnReconnect: true,
					focusThrottleInterval: 0,
					provider: () => new Map(),
				}
			}>
				<MockCurrentUserProvider>
					{props.children}
				</MockCurrentUserProvider>
			</SWRConfig>;
		</IntlProvider>
	</HosterContext.Provider>;
}

/**
//  * locationAssign is wrapper which provides you a spy to verify that
//  * window.location.assign has been called somewhere in the test. Make sure
//  * @param input a contents of your test as a function which accepts a
//  * jest.SpyInstance<void, [url: string]> and returns a Promise
//  */
async function locationAssign(input: (locationAssignSpy: jest.SpyInstance<void, [url: string]>) => Promise<void>) {
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
	it('forgot password Link goes to correct path', async () => {
		expect.hasAssertions();
		await locationAssign(async (locationAssignSpy: jest.SpyInstance<void, [url: string]>) => {
			const { getByText } = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'} /></Wrapper>);
			await waitFor(() => {
				expect(getByText('Forgot Password?')).toBeInTheDocument();
			});
			act(() => {
				fireEvent.click(getByText('Forgot Password?'));
			});

			await waitFor(() => {
				expect(locationAssignSpy).toHaveBeenCalledWith('/users/password/new');
			});
		});
	});
	it('terms & privacy Link has correct path', async () => {
		expect.hasAssertions();
		await locationAssign(async (locationAssignSpy: jest.SpyInstance<void, [url: string]>) => {
			const { getByTestId } = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'} /></Wrapper>);
			await waitFor(() => {
				expect(getByTestId('termsTest')).toBeInTheDocument();
			});
			act(() => {
				fireEvent.click(getByTestId('termsTest'));
			});
			await waitFor(() => {
				expect(locationAssignSpy).toHaveBeenCalledWith('/static/terms_and_privacy');
			});
		});
	});
});

describe('useHoster', () => {
	it('renders', async () => {
		expect.hasAssertions();
		const { getByTestId } = render(<Wrapper hoster={null} ><SignInPage redirectUrl={"redirectUrl"} /></Wrapper>);
		await waitFor(() => {
			expect(getByTestId('hosterTest')).toBeInTheDocument();
		});
	});
	it('renders with hoster', async () => {
		expect.hasAssertions();
		const { getByTestId } = render(<Wrapper hoster={{ legal_name: 'Houdini Hoster LLC', casual_name: 'Houdini Project' }}><SignInPage redirectUrl={"redirectUrl"} /></Wrapper>);
		await waitFor(() => {
			expect(getByTestId('hosterTest')).toHaveTextContent('Houdini Hoster LLC');

		});
	});
});

describe('redirectUrl', () => {
	it('has to redirect', async () => {
		expect.hasAssertions();
		await locationAssign(async (locationAssignSpy: jest.SpyInstance<void, [url: string]>) => {
			mocked(postSignIn).mockResolvedValue(true);
			const { getByTestId, getByLabelText } = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'} /></Wrapper>);
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