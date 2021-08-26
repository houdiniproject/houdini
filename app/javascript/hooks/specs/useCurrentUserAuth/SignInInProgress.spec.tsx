// License: LGPL-3.0-or-later
/* eslint-disable jest/no-hooks */
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { renderHook, act} from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';

import { server } from '../../../api/mocks';
import { UserWaitToSignInAndNotLoggedIn } from '../../mocks/useCurrentUserAuth';

import useCurrentUserAuth from '../../useCurrentUserAuth';
import { StopWaitingDuringUserSignIn } from '../../../api/mocks/users';
import { InitialCurrentUserContext } from '../../useCurrentUser';
import { DefaultUser } from '../../../api/api/mocks/users';

describe('useCurrentUserAuth', () => {
	function SWRWrapper(props:React.PropsWithChildren<unknown>) {
		return <SWRConfig value={{dedupingInterval: 0}}>
			{props.children}
		</SWRConfig>;
	}

	describe('SignIn in progress', () => {
		beforeEach(() => {
			server.use(...UserWaitToSignInAndNotLoggedIn);
		});

		it('succeeds when no user logged in', async () => {
			expect.assertions(6);
			const wrapper = SWRWrapper;
			const {result, unmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});

			await act(async() => {
				try {
					result.current.signIn({email: 'any', password: 'any'});
					await wait(() => result.current.submitting);
					expect(result.current.submitting).toBe(true);
					expect(result.current.currentUser).toBeNull();
					expect(result.current.lastSignInAttemptError).toBeUndefined();
					expect(result.current.signedIn).toBe(false);
					expect(result.current.lastGetCurrentUserError).toBeUndefined();
					expect(result.current.validatingCurrentUser).toBe(false);
				}
				catch{
					// ignore
				}
				finally {
					act(() => StopWaitingDuringUserSignIn());
				}
			});

			unmount();
		});

		it('succeeds when user initially logged in', async () => {
			expect.assertions(6);
			function wrapper(props:React.PropsWithChildren<unknown>) {
				return <InitialCurrentUserContext.Provider value={DefaultUser}>
					<SWRWrapper>
						{props.children}
					</SWRWrapper>
				</InitialCurrentUserContext.Provider>;
			}

			const {result, unmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
			await act(async() => {
				try {
					result.current.signIn({email: 'any', password: 'any'});
					await wait(() => result.current.submitting);
					expect(result.current.submitting).toBe(true);
					expect(result.current.currentUser).toStrictEqual(DefaultUser);
					expect(result.current.lastSignInAttemptError).toBeUndefined();
					expect(result.current.signedIn).toBe(true);
					expect(result.current.lastGetCurrentUserError).toBeUndefined();
					expect(result.current.validatingCurrentUser).toBe(false);
				}
				catch {
					//ignore
				}
				finally{
					act(() =>	StopWaitingDuringUserSignIn());
					await wait(() => !result.current.submitting);
					await wait(() => !result.current.lastSignInAttemptError)
				}
			});
			unmount();
		});
	});
});