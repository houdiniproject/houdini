// License: LGPL-3.0-or-later
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { renderHook, act, HookResult} from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';
const currentUser  = {id: 1};

jest.mock('../../../api/api/users');

jest.mock('../../../api/users');


import {getCurrent} from '../../../api/api/users';


import { CurrentUser, InitialCurrentUserContext } from '../../useCurrentUser';
import useCurrentUserAuth, { UseCurrentUserAuthReturnType } from '../../useCurrentUserAuth';
import { mocked } from 'ts-jest/utils';

describe('useCurrentUserAuth', () => {

	const getCurrentMocked = mocked(getCurrent);
	function SWRWrapper(props:React.PropsWithChildren<unknown>) {
		return <SWRConfig value={
			{
				dedupingInterval: 0, // we need to make SWR not dedupe
			}
		}>
			{props.children}
		</SWRConfig>;
	}

	describe('sign_in successful', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;

			// eslint-disable-next-line @typescript-eslint/no-empty-function
			async function commonPrep(callback:(result:HookResult<UseCurrentUserAuthReturnType>) => Promise<void> = async () => {}):Promise<CurrentUser> {
				getCurrentMocked.mockReset();
				const {result, unmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				let promiseResult = null;
				await act(async () => {
					getCurrentMocked.mockResolvedValueOnce(currentUser);
					promiseResult = await	result.current.signIn({email: 'any', password: 'any'});
				});
				await wait(() => !!result.current.currentUser );
				await callback(result);
				unmount();
				return promiseResult;
			}

			it('has currentUser', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.currentUser).toBe(currentUser));

			});

			it('is signedIn', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.signedIn).toBe(true));
			});

			it('is not failed', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.failed).toBe(false));
			});

			it('has no lastGetCurrentUserError', async () => {
				expect.assertions(1);

				await commonPrep(async result =>  expect(result.current.lastGetCurrentUserError).toBeUndefined());
			});

			it('has no lastSignInAttemptError', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.lastSignInAttemptError).toBeUndefined());
			});

			it('is not validating current user', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.validatingCurrentUser).toBe(false));
			});

			it('returns the correct result from the signIn promise', async () => {
				expect.assertions(1);

				expect(await commonPrep()).toStrictEqual(currentUser);
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

			// eslint-disable-next-line @typescript-eslint/no-empty-function
			async function commonPrep(callback:(result:HookResult<UseCurrentUserAuthReturnType>) => Promise<void> = async () => {}): Promise<CurrentUser> {
				getCurrentMocked.mockReset();
				const {result, unmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				let promiseResult = null;
				await act(async () => {
					getCurrentMocked.mockResolvedValueOnce(currentUser);
					promiseResult = await	result.current.signIn({email: 'any', password: 'any'});
				});
				await wait(() => !!result.current.currentUser );
				await callback(result);
				unmount();

				return promiseResult;
			}

			it('has currentUser', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.currentUser).toBe(currentUser));
			});

			it('is signedIn', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.signedIn).toBe(true));
			});


			it('has no lastGetCurrentUserError', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.lastGetCurrentUserError).toBeUndefined());
			});

			it('has no lastSignInAttemptError', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.lastSignInAttemptError).toBeUndefined());
			});

			it('is not failed', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.failed).toBe(false));
			});

			it('is not validating current user', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.validatingCurrentUser).toBe(false));
			});

			it('returns the correct result from the signIn promise', async () => {
				expect.assertions(1);

				expect(await commonPrep()).toStrictEqual(currentUser);
			});
		});
	});
});