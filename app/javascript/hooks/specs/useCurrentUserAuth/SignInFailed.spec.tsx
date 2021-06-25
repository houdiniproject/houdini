// License: LGPL-3.0-or-later
import * as React from 'react';
import { mocked } from 'ts-jest/utils';
import '@testing-library/jest-dom/extend-expect';

import { act, HookResult, renderHook } from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';

import {getCurrent} from '../../../api/api/users';
import {postSignIn} from '../../../api/users';
const currentUser  = {id: 1};

jest.mock('../../../api/api/users');
jest.mock('../../../api/users');

import { InitialCurrentUserContext } from '../../useCurrentUser';
import useCurrentUserAuth, { UseCurrentUserAuthReturnType } from '../../useCurrentUserAuth';

import { NetworkError } from '../../../api/errors';

describe('useCurrentUserAuth', () => {

	const getCurrentMocked = mocked(getCurrent, true);
	const postSignInMocked = mocked(postSignIn);
	function SWRWrapper(props:React.PropsWithChildren<unknown>) {
		return <SWRConfig value={
			{
				dedupingInterval: 0, // we need to make SWR not dedupe
			}
		}>
			{props.children}
		</SWRConfig>;
	}

	describe('sign_in failed', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;

			// eslint-disable-next-line @typescript-eslint/no-empty-function
			async function commonPrep(callback:(result:HookResult<UseCurrentUserAuthReturnType>) => Promise<void> = async() => {}):Promise<NetworkError> {
				getCurrentMocked.mockReset();
				postSignInMocked.mockReset();
				postSignInMocked.mockRejectedValueOnce(new NetworkError({status: 420}));
				const {result, unmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				let promiseResult = null;
				await act(async () => {
					getCurrentMocked.mockRejectedValueOnce(new NetworkError({status: 403}));
					try {
						await	result.current.signIn({email: 'any', password: 'any'});
					}

					catch(e) {
						promiseResult = e;
					}
				});
				await wait(() => !!result.current.lastSignInAttemptError);
				await callback(result);
				unmount();

				return promiseResult;
			}

			it('has no user', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.currentUser).toBeNull());
			});

			it('isnt signed in', async () => {
				expect.assertions(1);
				await commonPrep(async result =>	expect(result.current.signedIn).toBe(false));
			});

			it('has the lastSignInAttemptError status=420', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.lastSignInAttemptError).toStrictEqual(new NetworkError({status:420})));
			});

			it('has the lastGetCurrentUserError status=403', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.lastGetCurrentUserError).toStrictEqual(new NetworkError({status: 403})));
			});

			it('is failed', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.failed).toBe(true));
			});
			const postSignInMocked = postSignIn as unknown as jest.Mock;			it('is not validating current user', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.validatingCurrentUser).toBe(false));
			});

			it('returns the correct error from the signIn promise', async () => {
				expect.assertions(1);

				expect(await commonPrep()).toStrictEqual(new NetworkError({status: 420}));
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
			async function commonPrep(callback:(result:HookResult<UseCurrentUserAuthReturnType>) => Promise<void> = async() => {}): Promise<NetworkError> {
				getCurrentMocked.mockReset();
				postSignInMocked.mockReset();
				postSignInMocked.mockRejectedValueOnce(new NetworkError({status: 420}));
				const {result, unmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				let promiseResult = null;
				await act(async () => {
					getCurrentMocked.mockRejectedValueOnce(new NetworkError({status: 403}));
					try {
						await	result.current.signIn({email: 'any', password: 'any'});
					}
					catch(e) {
						promiseResult = e;
					}
				});
				await wait(() => !!result.current.lastSignInAttemptError);
				await callback(result);
				unmount();
				return promiseResult;
			}

			it('has no user', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.currentUser).toBeNull());
			});


			it('isnt signed in', async () => {
				expect.assertions(1);
				await commonPrep(async result =>	expect(result.current.signedIn).toBe(false));
			});

			it('has the lastSignInAttemptError status=420', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.lastSignInAttemptError).toStrictEqual(new NetworkError({status:420})));
			});

			it('has the lastGetCurrentUserError status=403', async () => {
				expect.assertions(1);
				await commonPrep(async result => expect(result.current.lastGetCurrentUserError).toStrictEqual(new NetworkError({status: 403})));
			});

			it('is failed', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.failed).toBe(true));
			});

			it('is not validating current user', async () => {
				expect.assertions(1);

				await commonPrep(async result => expect(result.current.validatingCurrentUser).toBe(false));
			});

			it('returns the correct error from the signIn promise', async () => {
				expect.assertions(1);

				expect(await commonPrep()).toStrictEqual(new NetworkError({status: 420}));
			});
		});
	});
});