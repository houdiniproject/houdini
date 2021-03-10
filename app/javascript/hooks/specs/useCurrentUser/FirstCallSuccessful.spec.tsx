// License: LGPL-3.0-or-later
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { HookResult, renderHook, act} from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';
const currentUser  = {id: 1};

jest.mock('../../../api/api/users', () => {
	return {
		getCurrent: async () => {
			return currentUser;
		},
	};
});

import useCurrentUser, { InitialCurrentUserContext, SetCurrentUserReturnType, UseCurrentUserReturnType } from '../../useCurrentUser';

describe('useCurrentUser', () => {
	function SWRWrapper(props:React.PropsWithChildren<unknown>) {
		return <SWRConfig value={{dedupingInterval: 0}}>
			{props.children}
		</SWRConfig>;
	}

	describe('first call successful', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;
			async function commonPrep(callback:(result:HookResult<UseCurrentUserReturnType>) => Promise<void>) {
				const {result, unmount, wait} = renderHook(() => useCurrentUser(), {wrapper});
				await wait(() => !!result.current.currentUser);
				await callback(result);
				unmount();
			}
			it('has currentUser', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.currentUser).toBe(currentUser));

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


				await commonPrep(async result =>	expect(result.current.validatingCurrentUser).toBe(true));
			});
		});


		describe('when user initially logged in', () => {
			function wrapper(props:React.PropsWithChildren<unknown>) {
				return <InitialCurrentUserContext.Provider value={currentUser}>
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
				await commonPrep(async result =>expect(result.current.currentUser).toBe(currentUser));

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