import * as React from 'react';
import { action } from '@storybook/addon-actions';

import SignInComponent from './SignInComponent';
import { InitialCurrentUserContext } from '../../hooks/useCurrentUser';
import { SWRConfig } from 'swr';
import { UserSignInFailedWith500And5SecondDelay, UserSignsInOnFirstAttemptWith5SecondDelay } from '../../hooks/mocks/useCurrentUserAuth';
import { UserPresignedIn } from '../../api/api/mocks/users';


function SWRWrapper(props:React.PropsWithChildren<unknown>) {
	return <SWRConfig value={
		{
			dedupingInterval: 2500, // we need to make SWR not dedupe
		}
	}>
		{props.children}
	</SWRConfig>;
}


export default {
	title: 'users/SignInComponent',
	argTypes: {
		showProgressAndSuccess: {
			type: {name: 'boolean'},
			defaultValue: true,
		},
	},
};

interface TemplateArgs {
	showProgressAndSuccess?: boolean;
}

function OuterWrapper(props:React.PropsWithChildren<Record<string, unknown>>) {
	sessionStorage.clear();
	return <> {props.children}</>;
}

const Template = (args:TemplateArgs) => {
	return (<OuterWrapper key={Math.random()}>
		<SignInComponent  onFailure={action('onFailure')} onSubmitting={action('onSubmitting')} onSuccess={action('onSuccess')} showProgressAndSuccess={args.showProgressAndSuccess} />
	</OuterWrapper>);
};

const SignedInTemplate = () => {
	sessionStorage.clear();
	return <OuterWrapper key={Math.random()}><SWRWrapper key={Math.random()}><InitialCurrentUserContext.Provider value={{id:1}}><SignInComponent onSuccess={action('onSuccess')} showProgressAndSuccess /></InitialCurrentUserContext.Provider></SWRWrapper></OuterWrapper>;
};

export const SignInFailed500 = Template.bind({});
SignInFailed500.story = {
	parameters: {
		msw: UserSignInFailedWith500And5SecondDelay,
	},
};


export const SignedInToStart = SignedInTemplate.bind({});
SignedInToStart.args = {
};

SignedInToStart.story =  {
	parameters: {
		msw: [
			...UserPresignedIn,
		],
	},
};

export const SignInSucceeded = Template.bind({});

SignInSucceeded.story = {
	parameters: {
		msw: [
			...UserSignsInOnFirstAttemptWith5SecondDelay,
		],
	},
};


