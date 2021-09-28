// License: LGPL-3.0-or-later
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { HookResult, renderHook } from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';

import { InitialCurrentUserContext } from '../../useCurrentUser';
import useCurrentUserAuth, { UseCurrentUserAuthReturnType } from '../../useCurrentUserAuth';
import {DefaultUser} from '../../../api/api/mocks/users';

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

	describe('initial state', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;

			async function commonPrep(callback:(result:HookResult<UseCurrentUserAuthReturnType>) => Promise<void>) {
				const {result, unmount} = renderHook(() => useCurrentUserAuth(), {wrapper});
				await callback(result);
				unmount();
			}


			it('has null currentUser', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.currentUser).toBeNull());
			});

			it('is not signedIn', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.signedIn).toBe(false));
			});

			it('has no lastGetCurrentUserError', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.lastGetCurrentUserError).toBeUndefined());
			});

			it('has no lastSignInAttemptError', async () => {
				expect.assertions(1);

				await commonPrep(async result =>expect(result.current.lastSignInAttemptError).toBeUndefined());
			});

			it('is not submitting', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.submitting).toBe(false));
			});

			it('is not failed', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.failed).toBe(false));
			});

			it('is validating current user', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.validatingCurrentUser).toBe(true));
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

			async function commonPrep(callback:(result:HookResult<UseCurrentUserAuthReturnType>) => Promise<void>) {
				const {result, unmount} = renderHook(() => useCurrentUserAuth(), {wrapper});
				await callback(result);
				unmount();
			}

			it('has currentUser', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.currentUser).toBe(DefaultUser));
			});
			it('is signedIn', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.signedIn).toBe(true));
			});

			it('has no lastGetCurrentUserError', async () => {
				expect.assertions(1);

				await commonPrep(async result =>				expect(result.current.lastGetCurrentUserError).toBeUndefined());
			});

			it('has no lastSignInAttemptError', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.lastSignInAttemptError).toBeUndefined());
			});

			it('is not submitting', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.submitting).toBe(false));
			});

			it('is not failed', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.failed).toBe(false));
			});

			it('is not validating current user', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.validatingCurrentUser).toBe(false));
			});

		});
	});
});