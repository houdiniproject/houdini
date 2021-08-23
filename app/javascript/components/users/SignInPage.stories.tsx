import * as React from 'react';
// import SignInPage from './SignInPage';

// import { Hoster, HosterContext } from '../../hooks/useHoster';
import { Fallback } from './SignInPage';
// import MockCurrentUserProvider from '../tests/MockCurrentUserProvider';
// import { SWRConfig } from 'swr';
// import { rest } from 'msw';

// import { postSignInRoute} from '../../api/users';
// import { getCurrentRoute} from '../../api/api/users';
// import { UserSignsInOnFirstAttempt } from '../../hooks/mocks/useCurrentUserAuth';
// import { NOT_LOGGED_IN_STATUS } from '.../../hooks/useCurrentUser';


export default {
	title: 'users/SignInPage',
	argTypes: {
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

// function SWRWrapper(props:React.PropsWithChildren<unknown>) {
// 	return <SWRConfig value={
// 		{
// 			dedupingInterval: 2500, // we need to make SWR not dedupe
// 		}
// 	}>
// 		{props.children}
// 	</SWRConfig>;
// }

// interface TemplateArgs {
// 	hasHoster?: boolean;
// 	hoster: string;
// }

// const Template = (args: TemplateArgs) => {

// 	let hosterReturnValue:Hoster|null = null;
// 	if (args.hasHoster) {
// 		hosterReturnValue = {legal_name:args.hoster, casual_name: args.hoster, main_admin_email: 'none@none.none', support_email: 'none@none.none', terms_and_privacy: {}};
// 	}
// 	else {
// 		hosterReturnValue = null;
// 	}
// 	return <OuterWrapper key={Math.random()}><SWRWrapper>
// 		<HosterContext.Provider value={hosterReturnValue}>
// 			<MockCurrentUserProvider>
// 				<SignInPage redirectUrl={'redirectUrl'} />
// 			</MockCurrentUserProvider>
// 		</HosterContext.Provider>
// 	</SWRWrapper></OuterWrapper>;
// };

// function OuterWrapper(props:React.PropsWithChildren<Record<string, unknown>>) {
// 	sessionStorage.clear();
// 	return <> {props.children}</>;
// }

const ErrorBoundaryTemplate = () => {
	return  <Fallback/>;
};


// export const SignInFailed500 = Template.bind({});


// SignInFailed500.story = {
// 	parameters: {
// 		msw: [
// 			rest.get(getCurrentRoute.url(), (_req, res,ctx) => {
// 				return res(
// 					ctx.status(NOT_LOGGED_IN_STATUS)
// 				);
// 			}),

// 			rest.post(postSignInRoute.url(), (_req, res, ctx) => {
// 				return res(
// 					ctx.delay(5000),
// 					ctx.json({error: "Some error"}),
// 					ctx.status(500)
// 				);
// 			}),
// 		],
// 	},
// };



// export const SignInSucceeded = Template.bind({});


// SignInSucceeded.story = {
// 	parameters: {
// 		msw: [
// 			...UserSignsInOnFirstAttempt,
// 		],
// 	},
// };

export const ShowErrorBoundary = ErrorBoundaryTemplate.bind({});



