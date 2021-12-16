// License: LGPL-3.0-or-later
/* eslint-disable jest/no-hooks */
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { act, HookResult, renderHook } from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';

import { InitialCurrentUserContext } from '../../useCurrentUser';
import useCurrentUserAuth, { UseCurrentUserAuthReturnType } from '../../useCurrentUserAuth';

import { server } from '../../../api/mocks';
import { UserSignsInOnFirstAttempt } from '../../mocks/useCurrentUserAuth';
import {DefaultUser} from '../../../api/api/mocks/users';


describe('useCurrentUserAuth', () => {

	function SWRWrapper(props:React.PropsWithChildren<unknown>) {
		return <SWRConfig value={
			{
				dedupingInterval: 0, // we need to make SWR not dedupe
				revalidateOnMount: false,
				revalidateOnFocus: false,
				revalidateOnReconnect: false,
				focusThrottleInterval: 0,
				provider: () => new Map(),
			}
		}>
			{props.children}
		</SWRConfig>;
	}

	describe('sign_in successful', () => {
		beforeEach(() => {
			server.use(...UserSignsInOnFirstAttempt);
		});

		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;
			let result:HookResult<UseCurrentUserAuthReturnType> = null;
			let unmount:() => boolean = null;
			beforeEach(async () => {
				const {result:innerResult, unmount:innerUnmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				result = innerResult;
				unmount = innerUnmount;

				await act(async() => {
					result.current.signIn({email: 'any', password: 'any'});
				});
				await wait(() => result.current.signedIn);
			});

			afterEach(() => {
				unmount();
			});



			it('has currentUser', () => {
				expect.assertions(1);
				expect(result.current.currentUser).toStrictEqual(DefaultUser);

			});

			it('is signedIn', () => {
				expect.assertions(1);

				expect(result.current.signedIn).toBe(true);
			});

			it('is not failed', () => {
				expect.assertions(1);

				expect(result.current.failed).toBe(false);
			});

			it('has no lastGetCurrentUserError', () => {
				expect.assertions(1);

				expect(result.current.lastGetCurrentUserError).toBeUndefined();
			});

			it('has no lastSignInAttemptError', () => {
				expect.assertions(1);

				expect(result.current.lastSignInAttemptError).toBeUndefined();
			});

			it('is not validating current user', () => {
				expect.assertions(1);

				expect(result.current.validatingCurrentUser).toBe(false);
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

			let result:HookResult<UseCurrentUserAuthReturnType> = null;
			let unmount:() => boolean = null;
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
				await wait(() => !result.current.submitting);
			});

			afterEach(() => {
				unmount();
			});
			it('has currentUser', () => {
				expect.assertions(1);
				expect(result.current.currentUser).toStrictEqual(DefaultUser);
			});

			it('is signedIn', () => {
				expect.assertions(1);

				expect(result.current.signedIn).toBe(true);
			});


			it('has no lastGetCurrentUserError', () => {
				expect.assertions(1);

				expect(result.current.lastGetCurrentUserError).toBeUndefined();
			});

			it('has no lastSignInAttemptError', () => {
				expect.assertions(1);

				expect(result.current.lastSignInAttemptError).toBeUndefined();
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