// License: LGPL-3.0-or-later
import * as React from "react";
import { render, fireEvent, act, waitFor } from "@testing-library/react";
import '@testing-library/jest-dom/extend-expect';

/* NOTE: we're mocking SignInComponent */
jest.mock('./SignInComponent', () => {
	return {
		default: SignInComponentErrorMock,
	};
});

import SignInPage from "./SignInPage";

import MockCurrentUserProvider from "../tests/MockCurrentUserProvider";

/* NOTE: We're mocking calls to `/user/sign_in` */
jest.mock('../../legacy_react/src/lib/api/sign_in');
import webUserSignIn from '../../legacy_react/src/lib/api/sign_in';
import { IntlProvider } from "../intl";
import I18n from '../../i18n';

const mockedWebUserSignIn = webUserSignIn as jest.Mocked<typeof webUserSignIn>;

function Wrapper(props:React.PropsWithChildren<unknown>) {
	return <IntlProvider messages={I18n.translations['en'] as any} locale={'en'}>
		<MockCurrentUserProvider>
			{props.children}
		</MockCurrentUserProvider>
	</IntlProvider>;

}

function SignInComponentErrorMock(): JSX.Element {
	throw "Something went wrong";
}

describe('SignInPage ErrorBoundary', () => {
	it('has displayed fallback', async() => {
		expect.assertions(1);
		const result = render(<Wrapper><SignInPage redirectUrl={'redirectUrl'}/></Wrapper>);

		const fallback = result.getByText(/.*Something went wrong.*/);
		expect(fallback).not.toBeNull();
	});
});

