/* eslint-disable jest/no-hooks */
// License: LGPL-3.0-or-later
import * as React from "react";
import { render, act, fireEvent, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import { Hoster, HosterContext } from '../../hooks/useHoster';

import SignInPage from "./SignInPage";


import { IntlProvider } from "../intl";
import I18n from '../../i18n';

import { server } from '../../api/mocks';
import { UserSignsInOnFirstAttempt } from "../../hooks/mocks/useCurrentUserAuth";
import { SWRConfig } from 'swr';
import { axe } from 'jest-axe';
import { convert } from "dotize";

type WrapperProps = React.PropsWithChildren<{ hoster?: Hoster }>;

function Wrapper(props: WrapperProps) {
	return <HosterContext.Provider value={props.hoster}>
		<IntlProvider locale={'en'} messages={convert(I18n.translations['en']) as any} > {/* eslint-disable-line @typescript-eslint/no-explicit-any */}
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
				{props.children}
			</SWRConfig>;
		</IntlProvider>
	</HosterContext.Provider>;
}

describe('Links', () => {
	beforeEach(() => {

		server.use(...UserSignsInOnFirstAttempt);
	});

	it('forgot password Link goes to correct path', async () => {
		expect.hasAssertions();
		const { getByText } = render(<Wrapper><SignInPage redirectUrl={'http://j.com/redirectUrl'} /></Wrapper>);
		await waitFor(() => {
			expect(getByText('Forgot Password?')).toBeInTheDocument();
		});

		expect(getByText('Forgot Password?')).toHaveAttribute('href', '/users/password/new' );

		act(() => {
			fireEvent.click(getByText('Forgot Password?'));
		});
	});
	it('terms & privacy Link has correct path', async () => {
		expect.hasAssertions();
		const { getByTestId } = render(<Wrapper><SignInPage redirectUrl={'http://j.com/redirectUrl'} /></Wrapper>);
		await waitFor(() => {
			expect(getByTestId('termsTest')).toBeInTheDocument();
		});

		expect(getByTestId('termsTest')).toHaveAttribute('href', '/static/terms_and_privacy');
		act(() => {
			fireEvent.click(getByTestId('termsTest'));
		});
	});
});

describe('useHoster', () => {
	beforeEach(() => {
		server.use(...UserSignsInOnFirstAttempt);
	});
	it('renders', async () => {
		expect.hasAssertions();
		const { getByTestId } = render(<Wrapper hoster={null} ><SignInPage redirectUrl={"http://j.com/redirectUrl"} /></Wrapper>);
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

describe('axe validation', () => {
	beforeEach(() => {
		server.use(...UserSignsInOnFirstAttempt);
	});

	it('passes axe accessibility verification', async () => {
		const { container } = render(<Wrapper hoster={{ legal_name: 'Houdini Hoster LLC', casual_name: 'Houdini Project' }}><SignInPage redirectUrl={"redirectUrl"} /></Wrapper>);
		const results = await axe(container);
		expect(results).toHaveNoViolations();
	});
});