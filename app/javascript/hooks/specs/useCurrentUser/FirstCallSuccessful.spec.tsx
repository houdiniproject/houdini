/* eslint-disable jest/no-hooks */
// License: LGPL-3.0-or-later
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { HookResult, renderHook, act, RenderHookResult} from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';

import {DefaultUser} from '../../../api/api/mocks/users';


import useCurrentUser, { InitialCurrentUserContext, SetCurrentUserReturnType, UseCurrentUserReturnType } from '../../useCurrentUser';

describe('useCurrentUser', () => {
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

	describe('first call successful', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;
			async function commonPrep(callback:(result:HookResult<UseCurrentUserReturnType>) => Promise<void>) {
				let renderHookReturn:RenderHookResult<unknown, UseCurrentUserReturnType> =null;
				await act(async () =>renderHookReturn =renderHook(() => useCurrentUser(), {wrapper}));
				const {result, unmount, wait} = renderHookReturn;
				await wait(() => !!result.current.currentUser);
				await callback(result);
				unmount();
			}
			it('has currentUser', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.currentUser).toStrictEqual(DefaultUser));

			});

			it('is signedIn', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.signedIn).toBe(true));
			});


			it('has no error', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.error).toBeUndefined());
			});

			it('is not validatingCurrentUser', async () => {
				expect.assertions(1);


				await commonPrep(async result =>	expect(result.current.validatingCurrentUser).toBe(false));
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

			async function commonPrep(callback:(result:HookResult<UseCurrentUserReturnType>) => Promise<void>) {
				const {result, unmount} = renderHook(() => useCurrentUser<SetCurrentUserReturnType>(), {wrapper});
				await act(async () => {
					await result.current.revalidate();
				});
				await callback(result);
				unmount();
			}

			it('has currentUser', async () => {
				expect.assertions(1);
				await commonPrep(async result =>expect(result.current.currentUser).toStrictEqual(DefaultUser));

			});

			it('is signedIn', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.signedIn).toBe(true));
			});

			it('has no error', async () => {
				expect.assertions(1);
				await commonPrep(async result =>expect(result.current.error).toBeUndefined());
			});

			it('is not validatingCurrentUser', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.validatingCurrentUser).toBe(false));
			});
		});
	});
});