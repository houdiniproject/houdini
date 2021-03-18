// License: LGPL-3.0-or-later
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { HookResult, renderHook } from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';

jest.mock('../../../api/api/users');


import useCurrentUser, { InitialCurrentUserContext, UseCurrentUserReturnType } from '../../useCurrentUser';

describe('useCurrentUser', () => {
	function SWRWrapper(props:React.PropsWithChildren<unknown>) {
		return <SWRConfig value={
			{
				dedupingInterval: 0, // we need to make SWR not dedupe
			}
		}>
			{props.children}
		</SWRConfig>;
	}


	describe('initial state', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;

			async function commonPrep(callback:(result:HookResult<UseCurrentUserReturnType>) => Promise<void>) {
				const {result, unmount} = renderHook(() => useCurrentUser(), {wrapper});
				await callback(result);
				unmount();
			}

			it('has null currentUser', async () => {
				expect.assertions(1);
				await commonPrep(async (result) => expect(result.current.currentUser).toBeNull());

			});

			it('is not signedIn', async () => {
				expect.assertions(1);

				await commonPrep(async (result) => expect(result.current.signedIn).toBe(false));
			});


			it('has no error', async () => {
				expect.assertions(1);


				await commonPrep(async (result) => 	expect(result.current.error).toBeUndefined());
			});

			it('is validatingCurrentUser', async () => {
				expect.assertions(1);

				await commonPrep(async (result) => expect(result.current.validatingCurrentUser).toBe(true));
			});
		});

		describe('when user initially logged in', () => {
			function wrapper(props:React.PropsWithChildren<unknown>) {
				return <InitialCurrentUserContext.Provider value={{id: 1}}>
					<SWRWrapper>
						{props.children}
					</SWRWrapper>
				</InitialCurrentUserContext.Provider>;
			}

			async function commonPrep(callback:(result:HookResult<UseCurrentUserReturnType>) => Promise<void>) {
				const {result, unmount} = renderHook(() => useCurrentUser(), {wrapper});
				await callback(result);
				unmount();
			}

			it('has correct currentUser', async () => {
				expect.assertions(1);

				await commonPrep(async (result) => expect(result.current.currentUser).toStrictEqual({id: 1}));

			});

			it('is  signedIn', async () => {
				expect.assertions(1);


				await commonPrep(async (result) =>	expect(result.current.signedIn).toBe(true));
			});


			it('has no error', async () => {
				expect.assertions(1);



				await commonPrep(async (result) =>	expect(result.current.error).toBeUndefined());
			});

			it('is not validatingCurrentUser', async () => {
				expect.assertions(1);

				await commonPrep(async (result) => expect(result.current.validatingCurrentUser).toBe(false));
			});
		});
	});
});