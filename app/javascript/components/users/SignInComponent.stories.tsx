// License: LGPL-3.0-or-later
import * as React from 'react';
import { action } from '@storybook/addon-actions';

import SignInComponent from './SignInComponent';
import { InitialCurrentUserContext } from '../../hooks/useCurrentUser';
import { SWRConfig } from 'swr';

import { UserSignInFailedWith500And5SecondDelay, UserSignsInOnFirstAttemptWith5SecondDelay } from '../../hooks/mocks/useCurrentUserAuth';
import { UserPresignedIn } from '../../api/api/mocks/users';
import { defaultStoryExport, StoryTemplate } from '../../tests/stories';

export default defaultStoryExport({
	title: 'users/SignInComponent',
	argTypes: {
		showProgressAndSuccess: {
			type: {name: 'boolean'},
			defaultValue: true,
		},
	},
});

function SWRWrapper(props:React.PropsWithChildren<unknown>) {
	return <SWRConfig value={
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
}

interface TemplateArgs {
	showProgressAndSuccess?: boolean;
}

function OuterWrapper(props:React.PropsWithChildren<Record<string, unknown>>) {
	return <> {props.children}</>;
}

const Template = new StoryTemplate((args:TemplateArgs) => {
	return (<OuterWrapper key={Math.random()}>
		<SWRWrapper key={Math.random()}>
			<SignInComponent  onFailure={action('onFailure')} onSubmitting={action('onSubmitting')} onSuccess={action('onSuccess')} showProgressAndSuccess={args.showProgressAndSuccess} />
		</SWRWrapper>
	</OuterWrapper>);
});

const SignedInTemplate = new StoryTemplate(() => {
	return <OuterWrapper key={Math.random()}><SWRWrapper key={Math.random()}><InitialCurrentUserContext.Provider value={{id:1}}><SignInComponent onSuccess={action('onSuccess')} showProgressAndSuccess /></InitialCurrentUserContext.Provider></SWRWrapper></OuterWrapper>;
});

export const SignInFailed500 = Template.newStory({story:{
	parameters: {
		msw: UserSignInFailedWith500And5SecondDelay,
	},
}});


export const SignedInToStart = SignedInTemplate.newStory({args: {}, story:{
	parameters: {
		msw: [
			...UserPresignedIn,
		],
	},
}});

export const SignInSucceeded = Template.newStory({story:{
	parameters: {
		msw: [
			...UserSignsInOnFirstAttemptWith5SecondDelay,
		],
	},
}});


