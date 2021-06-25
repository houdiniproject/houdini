// License: LGPL-3.0-or-later
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { HookResult, renderHook, act} from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';
const currentUser  = {id: 1};

jest.mock('../../../api/api/users');

jest.mock('../../../api/users');


import { InitialCurrentUserContext} from '../../useCurrentUser';

import useCurrentUserAuth from '../../useCurrentUserAuth';

import {postSignIn} from '../../../api/users';
const postSignInMocked = postSignIn as unknown as jest.Mock;

describe('useCurrentUserAuth', () => {
	function SWRWrapper(props:React.PropsWithChildren<unknown>) {
		return <SWRConfig value={{dedupingInterval: 0}}>
			{props.children}
		</SWRConfig>;
	}

	describe('SignIn in progress', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;
			async function commonPrep(expectations:(result:HookResult<ReturnType<typeof useCurrentUserAuth>>) => void) {
				postSignInMocked.mockReset();
				const {result, unmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				// we need to test what is happening as the getCurrent promise is happening
				postSignInMocked.mockImplementationOnce(async () => {
					await wait(() => result.current.submitting);

					expectations(result);
					return currentUser;
				});

				await act(async () => {
					await result.current.signIn({email: 'email', password: 'password'});
				});
				unmount();
			}


			it('is submitting', async () => {
				expect.assertions(1);


				await commonPrep(result =>	expect(result.current.submitting).toBe(true));
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

			async function commonPrep(expectations:(result:HookResult<ReturnType<typeof useCurrentUserAuth>>) => void) {
				postSignInMocked.mockReset();
				const {result, unmount, wait} = renderHook(() => useCurrentUserAuth(), {wrapper});
				// we need to test what is happening as the getCurrent promise is happening
				postSignInMocked.mockImplementationOnce(async () => {
					await wait(() => result.current.submitting);

					expectations(result);
					return currentUser;
				});

				await act(async () => {
					await result.current.signIn({email: 'email', password: 'password'});
				});
				unmount();
			}

			it('is submitting', async () => {
				expect.assertions(1);

				await commonPrep(result => expect(result.current.submitting).toBe(true));
			});
		});
	});
});