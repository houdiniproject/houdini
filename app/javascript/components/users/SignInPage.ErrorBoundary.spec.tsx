// License: LGPL-3.0-or-later
import * as React from "react";
import { render } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';

function SignInComponentErrorMock(): JSX.Element {
	throw "Something went wrong";
}

/* NOTE: we're mocking SignInComponent */
jest.mock('./SignInComponent', () => {
	return {
		default: SignInComponentErrorMock,
	};
});

import SignInPage from "./SignInPage";

import { IntlProvider } from "../intl";
import I18n from '../../i18n';
import { HosterContext } from "../../hooks/useHoster";
import {InitialCurrentUserContext} from "../../hooks/useCurrentUser";
import {convert} from 'dotize';
function Wrapper(props:React.PropsWithChildren<unknown>) {
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	const translations = I18n.translations['en'] as any;

	return <HosterContext.Provider value={null}>
		<IntlProvider messages={convert(translations)} locale={'en'}>
			<InitialCurrentUserContext.Provider value={{id: 1}}>
				{props.children}
			</InitialCurrentUserContext.Provider>
		</IntlProvider>
	</HosterContext.Provider>;

}



describe('SignInPage ErrorBoundary', () => {
	it('has displayed fallback', async() => {
		expect.assertions(1);
		const result = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);

		const fallback = result.getByText(/.*Something went wrong.*/);
		expect(fallback).not.toBeNull();
	});
});

