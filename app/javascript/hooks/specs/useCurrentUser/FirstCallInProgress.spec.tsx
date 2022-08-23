// License: LGPL-3.0-or-later
/* eslint-disable jest/no-hooks */
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { HookResult, renderHook} from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';
import { server } from '../../../api/mocks';
import { UserPresignedInAndWaitUntilSignal, StopWaitingDuringGetCurrent } from '../../../api/api/mocks/users';
import { DefaultUser } from '../../../api/api/mocks/users';


import useCurrentUser, { InitialCurrentUserContext, SetCurrentUserReturnType } from '../../useCurrentUser';

describe('useCurrentUser', () => {

	beforeEach(() => {
		server.use(...UserPresignedInAndWaitUntilSignal);
	});
	function SWRWrapper(props:React.PropsWithChildren<unknown>) {
		return <SWRConfig value={{	dedupingInterval: 0, // we need to make SWR not dedupe
			revalidateOnMount: true,
			revalidateOnFocus: true,
			revalidateOnReconnect: true,
			focusThrottleInterval: 0,
			provider: () => new Map()}}>
			{props.children}
		</SWRConfig>;
	}



	describe('first call in progress', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;
			let result: HookResult<SetCurrentUserReturnType>;
			let unmount: () => boolean;
			beforeAll(async () => {
				const {result:innerResult, unmount:innerUnmount, wait} = renderHook(() => useCurrentUser<SetCurrentUserReturnType>(), {wrapper});
				result = innerResult;
				unmount = innerUnmount;
				await wait(() => result.current.validatingCurrentUser === true);
			});

			afterAll(() => {
				StopWaitingDuringGetCurrent();
				unmount();
			});


			it('is validatingCurrentUser', async () => {
				expect.assertions(1);

				expect(result.current.validatingCurrentUser).toBe(true);

			});

			it('has no currentUser', async () => {
				expect.assertions(1);

				expect(result.current.currentUser).toBeNull();

			});

			it('is not signed in', async () => {
				expect.assertions(1);

				expect(result.current.signedIn).toBe(false);

			});

			it('has no error', async () => {
				expect.assertions(1);
				expect(result.current.error).toBeUndefined();

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

			let result: HookResult<SetCurrentUserReturnType>;
			let unmount: () => boolean;
			beforeAll(async () => {
				const {result:innerResult, unmount:innerUnmount, wait} = renderHook(() => useCurrentUser<SetCurrentUserReturnType>(), {wrapper});
				result = innerResult;
				unmount = innerUnmount;
				await wait(() => result.current.validatingCurrentUser === true);
			});

			afterAll(() => {
				sessionStorage.setItem('finish-promise', 'true');
				unmount();
			});

			it('is validatingCurrentUser', async () => {
				expect.assertions(1);

				expect(result.current.validatingCurrentUser).toBe(true);

			});

			it('has currentUser', async () => {
				expect.assertions(1);

				expect(result.current.currentUser).toBe(DefaultUser);

			});

			it('is not signed in', async () => {
				expect.assertions(1);

				expect(result.current.signedIn).toBe(true);

			});

			it('has no error', async () => {
				expect.assertions(1);
				expect(result.current.error).toBeUndefined();

			});
		});
	});
});