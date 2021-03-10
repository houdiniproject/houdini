// License: LGPL-3.0-or-later
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { HookResult, renderHook } from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';
const currentUser  = {id: 1};

jest.mock('../../../api/api/users', () => {
	return {
		getCurrent: async () => {
			throw new NetworkError({status: 403});
		},
	};
});


import useCurrentUser, { InitialCurrentUserContext, UseCurrentUserReturnType } from '../../useCurrentUser';
import { NetworkError } from '../../../api/errors';

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

	describe('first call failed', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;
			async function commonPrep(callback:(result:HookResult<UseCurrentUserReturnType>) => Promise<void>) {
				const {result, unmount, wait} = renderHook(() => useCurrentUser(), {wrapper});
				await wait(() => !!result.current.error);
				await callback(result);
				unmount();
			}
			it('doesnt get the user', async () => {
				expect.assertions(1);
				const {result, wait} = renderHook(() => useCurrentUser(), {wrapper});
				await wait(() => !!result.current.error);

				await commonPrep(async (result) =>expect(result.current.currentUser).toBeNull());
			});


			it('isnt signed in', async () => {
				expect.assertions(1);
				await commonPrep(async (result) => expect(result.current.signedIn).toBe(false));
			});

			it('has the networkError', async () => {
				expect.assertions(1);
				await commonPrep(async (result) => expect(result.current.error).toBeInstanceOf(NetworkError));
			});

			it('is not validatingCurrentUser', async () => {
				expect.assertions(1);


				await commonPrep(async (result) =>	expect(result.current.validatingCurrentUser).toBe(true));
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
				const {result, unmount, wait} = renderHook(() => useCurrentUser(), {wrapper});
				await wait(() => !!result.current.error);
				await callback(result);
				unmount();
			}

			it('doesnt get the user', async () => {
				expect.assertions(1);

				await commonPrep(async (result) =>		expect(result.current.currentUser).toBeNull());
			});


			it('isnt signed in', async () => {
				expect.assertions(1);

				await commonPrep(async (result) =>	expect(result.current.signedIn).toBe(false));
			});

			it('has the networkError', async () => {
				expect.assertions(1);
				await commonPrep(async (result) =>	expect(result.current.error).toBeInstanceOf(NetworkError));
			});

			it('is not validatingCurrentUser', async () => {
				expect.assertions(1);

				await commonPrep(async (result) =>	 expect(result.current.validatingCurrentUser).toBe(true));
			});
		});
	});
});