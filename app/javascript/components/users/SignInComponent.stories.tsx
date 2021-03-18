import * as React from 'react';
import { action } from '@storybook/addon-actions';

import MockCurrentUserProvider from '../tests/MockCurrentUserProvider';
import SignInComponent from './SignInComponent';

/* it's already mocked in the storybook webpack */
import webUserSignIn from '../../legacy_react/src/lib/api/sign_in';
import { SignInError } from '../../legacy_react/src/lib/api/errors';

const mockedWebUserSignIn = webUserSignIn as jest.Mocked<typeof webUserSignIn>;


const optionsToSignInError:Record<string, { data?: { error: string[]|string }, status?: number }> = {
	'Unknown Error - 500': {status: 500, data: {error: "Error unknown"}},
	'Not Found - 404': {status: 404, data: {error: 'Not Found'}},
	'User or password not valid - 401': {status: 401, data:{ error: 'We didn\'t recognize that email or password'}},
};


export default {
	title: 'users/SignInComponent',
	component: SignInComponent,
	argTypes: {
		isError: {
			type: {name: 'boolean'},
			defaultValue: false,
			description: "Set whether getting the useCurrentUserAuth should throw an error next time",
		},
		error: {
			control: {type: 'radio',options: Object.keys(optionsToSignInError)},
			defaultValue: 'User or password not valid - 401',
		},
		showProgressAndSuccess: {
			type: {name: 'boolean'},
			defaultValue: true,
		},
	},
};

interface TemplateArgs {
	error?: string;
	isError: boolean;
	showProgressAndSuccess?: boolean;
}

const Template = (args:TemplateArgs) => {

	if (args.isError ) {
		mockedWebUserSignIn.postSignIn.mockImplementation(() => new Promise((_resolve, reject) => {
			setTimeout(() => {
				reject(	new SignInError(optionsToSignInError[args.error]));
			}, 5000);
		}));
	}
	else {
		mockedWebUserSignIn.postSignIn.mockImplementation(() => new Promise(resolve => {
			setTimeout(() => {
				resolve({id:50});
			},5000);
		}));
	}

	return <MockCurrentUserProvider >
		<SignInComponent onFailure={action('onFailure')} onSubmitting={action('onSubmitting')} onSuccess={action('onSuccess')} showProgressAndSuccess={args.showProgressAndSuccess}/>
	</MockCurrentUserProvider>;
};

const SignedInTemplate = () => {
	return <MockCurrentUserProvider initialUserId={1}><SignInComponent onSuccess={action('onSuccess')} showProgressAndSuccess /></MockCurrentUserProvider>;
};

export const SignInFailed = Template.bind({});
SignInFailed.args = {
	isError: true,
	error: 'Unknown Error - 500',
};

export const SignedInToStart = SignedInTemplate.bind({});
SignedInToStart.args = {
};

export const SignInSucceeded = Template.bind({});


