import * as React from 'react';
import { action } from '@storybook/addon-actions';

import MockCurrentUserProvider from '../tests/MockCurrentUserProvider';
import SignInComponent, { SignInComponentProps } from './SignInComponent';

/* it's already mocked in the storybook webpack */
import webUserSignIn from '../../legacy_react/src/lib/api/sign_in';
import { SignInError } from '../../legacy_react/src/lib/api/errors';

const mockedWebUserSignIn = webUserSignIn as jest.Mocked<typeof webUserSignIn>;


const optionsToSignInError:Record<string, {error: string, status:number }> = {
	'Unknown Error - 500': {status: 500, error: "Error unknown"},
	'Not Found - 404': {status: 404, error: 'Not Found'},
	'User or password not valid - 401': {status: 401, error: 'We didn\'t recognize that email or password'},
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
	},
};

interface TemplateArgs {
	error?: string;
	isError: boolean;
}

const Template = (args:TemplateArgs) => {

	if (args.isError ) {

		mockedWebUserSignIn.postSignIn.mockRejectedValue(
			new SignInError(optionsToSignInError[args.error])
		);
	}
	else {
		mockedWebUserSignIn.postSignIn.mockResolvedValue({id: 50});
	}
	return <MockCurrentUserProvider><SignInComponent onFailure={action('onFailure')} /></MockCurrentUserProvider>;
};

export const SignInFailed = Template.bind({});
SignInFailed.args = {
	isError: true,
	error: 'Unknown Error - 500',
};


export const SignInSucceeded = Template.bind({});


