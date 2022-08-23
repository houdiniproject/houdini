// License: LGPL-3.0-or-later
/* eslint-disable jest/no-hooks */
import * as React from 'react';

import '@testing-library/jest-dom/extend-expect';

import { act, HookResult, renderHook } from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';

import { InitialCurrentUserContext, NotLoggedInStatus } from '../../useCurrentUser';
import useCurrentUserAuth, { UseCurrentUserAuthReturnType } from '../../useCurrentUserAuth';
import { NetworkError } from '../../../api/errors';

import { server } from '../../../api/mocks';
import { UserSignInFailsFromInvalidLogin } from '../../../api/mocks/users';
import {DefaultUser, UserSignedInIfAuthenticated} from '../../../api/api/mocks/users';


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

	describe('sign_in failed', () => {
		beforeEach(() => {
			server.use(...UserSignInFailsFromInvalidLogin, ...UserSignedInIfAuthenticated);
		});
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;
			let result:HookResult<UseCurrentUserAuthReturnType>;
			let unmount:() => boolean;
			beforeEach(async () => {
				const {result:innerResult, unmount:innerUnmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				result = innerResult;
				unmount = innerUnmount;

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
			});

			afterEach(() => {
				unmount();
			});


			it('has no user', async () => {
				expect.assertions(1);
				expect(result.current.currentUser).toBeNull();
			});

			it('isnt signed in', async () => {
				expect.assertions(1);
				expect(result.current.signedIn).toBe(false);
			});

			it('has the lastSignInAttemptError status=403', () => {
				expect.assertions(1);
				expect(result.current.lastSignInAttemptError).toStrictEqual(new NetworkError({status:NotLoggedInStatus}));
			});

			it('has the lastGetCurrentUserError status=403', () => {
				expect.assertions(1);
				expect(result.current.lastGetCurrentUserError).toStrictEqual(new NetworkError({status: NotLoggedInStatus}));
			});

			it('is failed', () => {
				expect.assertions(1);

				expect(result.current.failed).toBe(true);
			});

			it('is validating current user', () => {
				expect.assertions(1);

				expect(result.current.validatingCurrentUser).toBe(true);
			});

			it('is not submitting', () => {
				expect.assertions(1);

				expect(result.current.submitting).toBe(false);
			});
		});


		describe('when user initially logged in', () => {
			function wrapper(props:React.PropsWithChildren<unknown>) {
				return <InitialCurrentUserContext.Provider value={DefaultUser}>
					<SWRWrapper>
						{props.children}
					</SWRWrapper>
				</InitialCurrentUserContext.Provider>;
			}


			let result:HookResult<UseCurrentUserAuthReturnType>;
			let unmount:() => boolean;
			beforeEach(async () => {
				const {result:innerResult, unmount:innerUnmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				result = innerResult;
				unmount = innerUnmount;

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
			});

			afterEach(() => {
				unmount();
			});

			it('has no user', async () => {
				expect.assertions(1);
				expect(result.current.currentUser).toBeNull();
			});


			it('isnt signed in', async () => {
				expect.assertions(1);
				expect(result.current.signedIn).toBe(false);
			});

			it('has the lastSignInAttemptError status=403', async () => {
				expect.assertions(1);
				expect(result.current.lastSignInAttemptError).toStrictEqual(new NetworkError({status:NotLoggedInStatus}));
			});

			it('has the lastGetCurrentUserError status=403', async () => {
				expect.assertions(1);
				expect(result.current.lastGetCurrentUserError).toStrictEqual(new NetworkError({status:NotLoggedInStatus}));
			});

			it('is failed', async () => {
				expect.assertions(1);

				expect(result.current.failed).toBe(true);
			});

			it('is validating current user', async () => {
				expect.assertions(1);

				expect(result.current.validatingCurrentUser).toBe(true);
			});

			it('is not submitting', () => {
				expect.assertions(1);

				expect(result.current.submitting).toBe(false);
			});
		});
	});
});