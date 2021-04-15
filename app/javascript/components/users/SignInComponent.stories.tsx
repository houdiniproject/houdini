import * as React from 'react';
import { action } from '@storybook/addon-actions';

import SignInComponent from './SignInComponent';
jest.mock('../../api/api/users');
jest.mock('../../api/users');
import { InitialCurrentUserContext } from '../../hooks/useCurrentUser';
import { SWRConfig } from 'swr';
import { mocked } from "ts-jest/utils";
import {postSignIn} from '../../api/users';
import {getCurrent} from '../../api/api/users';
import { NetworkError } from '../../api/errors';


function SWRWrapper(props:React.PropsWithChildren<unknown>) {
	return <SWRConfig value={
		{
			dedupingInterval: 2500, // we need to make SWR not dedupe
		}
	}>
		{props.children}
	</SWRConfig>;
}

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

	if (args.isError) {
		mocked(postSignIn).mockImplementation(() => new Promise((_resolve, reject) => {
			setTimeout(() => {
				const result = optionsToSignInError[args.error];
				reject(new NetworkError({data:result.data, status: result.status}));
			}, 5000);
		}));
	}
	else {

		mocked(postSignIn).mockImplementation(() => new Promise(resolve => {
			setTimeout(() => {
				resolve({ id: 50 });
				mocked(getCurrent).mockResolvedValue({id: 50});
			}, 5000);
		}));
	}

	return <SignInComponent onFailure={action('onFailure')} onSubmitting={action('onSubmitting')} onSuccess={action('onSuccess')} showProgressAndSuccess={args.showProgressAndSuccess}/>;
};

const SignedInTemplate = () => {
	return <SWRWrapper><InitialCurrentUserContext.Provider value={{id:1}}><SignInComponent onSuccess={action('onSuccess')} showProgressAndSuccess /></InitialCurrentUserContext.Provider></SWRWrapper>;
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


