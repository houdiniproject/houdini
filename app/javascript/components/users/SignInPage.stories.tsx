import * as React from 'react';
import MockCurrentUserProvider from '../tests/MockCurrentUserProvider';
import SignInPage from './SignInPage';
/* it's already mocked in the storybook webpack */
import webUserSignIn from '../../legacy_react/src/lib/api/sign_in';
import { SignInError } from '../../legacy_react/src/lib/api/errors';
import { Hoster, HosterContext } from '../../hooks/useHoster';
import { Fallback } from './SignInPage';

const mockedWebUserSignIn = webUserSignIn as jest.Mocked<typeof webUserSignIn>;

const optionsToSignInError: Record<string, { data?: { error: string[] | string }, status?: number }> = {
	'Unknown Error - 500': { status: 500, data: { error: "Error unknown" } },
	'Not Found - 404': { status: 404, data: { error: 'Not Found' } },
	'User or password not valid - 401': { status: 401, data: { error: 'We didn\'t recognize that email or password' } },
};

export default {
	title: 'users/SignInPage',
	component: SignInPage,
	argTypes: {
		isError: {
			type: { name: 'boolean' },
			defaultValue: false,
			description: "Set whether getting the useCurrentUserAuth should throw an error next time",
		},
		error: {
			control: { type: 'radio', options: Object.keys(optionsToSignInError) },
			defaultValue: 'User or password not valid - 401',
		},
		hasHoster: {
			type: { name: 'boolean' },
			defaultValue: false,
			description: "Set whether the hoster is set",
		},
		hoster: {
			type: {name: 'string'},
			defaultValue: "Houdini Hoster LLC",
		},
	},
};

interface TemplateArgs {
	error?: string;
	hasHoster?: boolean;
	hoster: string;
	isError: boolean;
}

const Template = (args: TemplateArgs) => {
	if (args.isError) {
		mockedWebUserSignIn.postSignIn.mockImplementation(() => new Promise((_resolve, reject) => {
			setTimeout(() => {
				reject(new SignInError(optionsToSignInError[args.error]));
			}, 5000);
		}));
	}
	else {
		mockedWebUserSignIn.postSignIn.mockImplementation(() => new Promise(resolve => {
			setTimeout(() => {
				resolve({ id: 50 });
			}, 5000);
		}));
	}

	let hosterReturnValue:{hoster: Hoster} = {hoster: null};
	if (args.hasHoster) {
		hosterReturnValue = {hoster: {legalName:args.hoster}};
	}
	else {
		hosterReturnValue = {hoster: null};
	}

	return <HosterContext.Provider value={hosterReturnValue}>
		<MockCurrentUserProvider>
			<SignInPage redirectUrl={'redirectUrl'} />
		</MockCurrentUserProvider>
	</HosterContext.Provider>;
};

const ErrorBoundaryTemplate = () => {
	return  <Fallback/>;
};


export const SignInFailed = Template.bind({});
SignInFailed.args = {
	isError: true,
	error: 'Unknown Error - 500',
};

export const SignInSucceeded = Template.bind({});

export const ShowErrorBoundary = ErrorBoundaryTemplate.bind({});
SignInFailed.args = {
};



