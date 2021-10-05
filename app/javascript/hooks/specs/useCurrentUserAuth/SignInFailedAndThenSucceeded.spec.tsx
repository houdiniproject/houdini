// License: LGPL-3.0-or-later
/* eslint-disable jest/no-hooks */
import * as React from 'react';

import '@testing-library/jest-dom/extend-expect';

import { act, HookResult, renderHook } from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';

// import { InitialCurrentUserContext, NOT_LOGGED_IN_STATUS } from '../../useCurrentUser';
import useCurrentUserAuth, { UseCurrentUserAuthReturnType } from '../../useCurrentUserAuth';

import { server } from '../../../api/mocks';
import { DefaultUser } from '../../../api/api/mocks/users';
import {UserSignInFailsOnceAndThenSucceedsAndGetCurrentWaitsForAuthentication} from '../../mocks/useCurrentUserAuth';

describe('useCurrentUserAuth', () => {


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

	describe('sign_in failed and then succeeded', () => {
		beforeEach(() => {
			server.use(...UserSignInFailsOnceAndThenSucceedsAndGetCurrentWaitsForAuthentication);
		});
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;
			let result:HookResult<UseCurrentUserAuthReturnType> = null;
			beforeEach(async () => {
				const {result:innerResult, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				result = innerResult;

				await act(async() => {
					try {
						await result.current.signIn({email: 'any', password: 'any'});
					}
					catch
					{
						//ignore
					}
				});
				await wait(() => !!result.current.lastSignInAttemptError);
				await act(async() => {
					try {
						await result.current.signIn({email: 'any', password: 'any'}); // it should work this time
					}
					catch
					{
						//ignore
					}
				});

				await wait(() => !result.current.lastSignInAttemptError);
				await wait(() => !result.current.lastGetCurrentUserError);
			});


			it('has user', async () => {
				expect.assertions(1);
				expect(result.current.currentUser).toStrictEqual(DefaultUser);
			});

			it('is signed in', async () => {
				expect.assertions(1);
				expect(result.current.signedIn).toBe(true);
			});

			it('has undefined lastSignInAttemptError', () => {
				expect.assertions(1);
				expect(result.current.lastSignInAttemptError).toBeUndefined();
			});

			it('has undefined lastGetCurrentUserError', () => {
				expect.assertions(1);
				expect(result.current.lastGetCurrentUserError).toBeUndefined();
			});

			it('is not failed', () => {
				expect.assertions(1);

				expect(result.current.failed).toBe(false);
			});

			it('is not validating current user', () => {
				expect.assertions(1);

				expect(result.current.validatingCurrentUser).toBe(false);
			});

			it('is not submitting', () => {
				expect.assertions(1);

				expect(result.current.submitting).toBe(false);
			});
		});
	});
});