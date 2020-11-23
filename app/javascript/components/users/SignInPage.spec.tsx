// License: LGPL-3.0-or-later
import * as React from "react";
import { render, fireEvent } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';
import { Hoster, HosterContext } from '../../hooks/useHoster';

import SignInPage from "./SignInPage";

import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";

/* NOTE: We're mocking calls to `/user/sign_in` */
jest.mock('../../legacy_react/src/lib/api/sign_in');
import { IntlProvider } from "../intl";
import I18n from '../../i18n';

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


