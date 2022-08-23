// License: LGPL-3.0-or-later
/* eslint-disable jest/no-hooks */
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { HookResult, renderHook} from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';

import useCurrentUser, { InitialCurrentUserContext, UseCurrentUserReturnType } from '../../useCurrentUser';
import { NetworkError } from '../../../api/errors';

import { server } from '../../../api/mocks';
import { DefaultUser, UserSignedInIfAuthenticated } from '../../../api/api/mocks/users';
describe('useCurrentUser', () => {
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

	describe('first call failed', () => {
		beforeEach(() => {
			server.use(...UserSignedInIfAuthenticated);
		});
		describe('when no user logged in', () => {

			const wrapper = SWRWrapper;
			let result:HookResult<UseCurrentUserReturnType>;
			let unmount:() => boolean;
			beforeEach(async () => {
				const {result:innerResult, unmount:innerUnmount, wait} = renderHook(() => useCurrentUser(), {wrapper});
				result = innerResult;
				unmount = innerUnmount;
				await wait(() => !!result.current.error);
			});

			afterEach(() => {
				unmount();
			});

			it('doesnt get the user', () => {
				expect.assertions(1);
				expect(result.current.currentUser).toBeNull();
			});

			it('isnt signed in', () => {
				expect.assertions(1);
				expect(result.current.signedIn).toBe(false);
			});

			it('has the networkError', () => {
				expect.assertions(1);
				expect(result.current.error).toBeInstanceOf(NetworkError);
			});

			it('is validatingCurrentUser', () => {
				expect.assertions(1);


				expect(result.current.validatingCurrentUser).toBe(true);
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

			let result:HookResult<UseCurrentUserReturnType>;
			let unmount:() => boolean;
			beforeEach(async () => {
				const {result:innerResult, unmount:innerUnmount, wait} = renderHook(() => useCurrentUser(), {wrapper});
				result = innerResult;
				unmount = innerUnmount;
				await wait(() => !!result.current.error);
			});

			afterEach(() => {
				unmount();
			});


			it('doesnt get the user',  () => {
				expect.assertions(1);

				expect(result.current.currentUser).toBeNull();
			});


			it('isnt signed in', () => {
				expect.assertions(1);

				expect(result.current.signedIn).toBe(false);
			});

			it('has the networkError', () => {
				expect.assertions(1);
				expect(result.current.error).toBeInstanceOf(NetworkError);
			});

			it('is validatingCurrentUser', () => {
				expect.assertions(1);

				expect(result.current.validatingCurrentUser).toBe(true);
			});
		});
	});
});