import * as React from 'react';
import SignInPage from './SignInPage';
jest.mock('../../api/api/users');
jest.mock('../../api/users');

import { Hoster, HosterContext } from '../../hooks/useHoster';
import { Fallback } from './SignInPage';
import MockCurrentUserProvider from '../tests/MockCurrentUserProvider';
import { SWRConfig } from 'swr';
import { mocked } from "ts-jest/utils";
import {postSignIn} from '../../api/users';
import {getCurrent} from '../../api/api/users';
import { NetworkError } from '../../api/errors';


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

function SWRWrapper(props:React.PropsWithChildren<unknown>) {
	return <SWRConfig value={
		{
			dedupingInterval: 2500, // we need to make SWR not dedupe
		}
	}>
		{props.children}
	</SWRConfig>;
}

interface TemplateArgs {
	error?: string;
	hasHoster?: boolean;
	hoster: string;
	isError: boolean;
}

const Template = (args: TemplateArgs) => {
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

	let hosterReturnValue:Hoster|null = null;
	if (args.hasHoster) {
		hosterReturnValue = {legal_name:args.hoster, casual_name: args.hoster, main_admin_email: 'none@none.none', support_email: 'none@none.none', terms_and_privacy: {}};
	}
	else {
		hosterReturnValue = null;
	}
	return <SWRWrapper>
		<HosterContext.Provider value={hosterReturnValue}>
			<MockCurrentUserProvider>
				<SignInPage redirectUrl={'redirectUrl'} />
			</MockCurrentUserProvider>
		</HosterContext.Provider>
	</SWRWrapper>;
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



