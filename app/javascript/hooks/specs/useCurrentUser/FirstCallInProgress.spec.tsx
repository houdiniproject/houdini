// License: LGPL-3.0-or-later
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';

import { HookResult, renderHook, act} from '@testing-library/react-hooks';
import {SWRConfig} from 'swr';
const currentUser  = {id: 1};

jest.mock('../../../api/api/users');

import useCurrentUser, { InitialCurrentUserContext, SetCurrentUserReturnType } from '../../useCurrentUser';
import {getCurrent} from '../../../api/api/users';
import { mocked } from 'ts-jest/utils';



describe('useCurrentUser', () => {
	function SWRWrapper(props:React.PropsWithChildren<unknown>) {
		return <SWRConfig value={{dedupingInterval: 0}}>
			{props.children}
		</SWRConfig>;
	}

	const getCurrentMocked = mocked(getCurrent);

	describe('first call in progress', () => {
		describe('when no user logged in', () => {
			const wrapper = SWRWrapper;
			async function commonPrep(expectations:(result:HookResult<ReturnType<typeof useCurrentUser>>) => void) {
				getCurrentMocked.mockReset();
				const {result, unmount, wait} = renderHook(() => useCurrentUser<SetCurrentUserReturnType>(), {wrapper});
				// we need to test what is happening as the getCurrent promise is happening
				getCurrentMocked.mockImplementationOnce(async () => {
					await wait(() => result.current.validatingCurrentUser);

					expectations(result);
					return currentUser;
				});

				await act(async () => {
					await result.current.revalidate();
				});
				unmount();
			}


			it('is validatingCurrentUser', async () => {
				expect.assertions(1);


				await commonPrep(result =>	expect(result.current.validatingCurrentUser).toBe(true));
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

			async function commonPrep(expectations:(result:HookResult<ReturnType<typeof useCurrentUser>>) => void) {
				getCurrentMocked.mockReset();

				const {result, unmount, wait} = renderHook(() => useCurrentUser<SetCurrentUserReturnType>(), {wrapper});
				// we need to test what is happening as the getCurrent promise is happening
				getCurrentMocked.mockImplementationOnce(async () => {
					await wait(() => result.current.validatingCurrentUser);

					expectations(result);

					return currentUser;
				});

				await act(async () => {
					await result.current.revalidate();
				});
				unmount();
			}

			it('is validatingCurrentUser', async () => {
				expect.assertions(1);

				await commonPrep(result => expect(result.current.validatingCurrentUser).toBe(true));
			});
		});
	});
});