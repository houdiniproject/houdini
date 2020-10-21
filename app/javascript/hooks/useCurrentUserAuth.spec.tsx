// License: LGPL-3.0-or-later
import * as React from 'react';
import '@testing-library/jest-dom/extend-expect';
import MockCurrentUserProvider, { MockCurrentUserProviderProps } from "../components/tests/MockCurrentUserProvider";
import { act, renderHook, RenderHookResult } from '@testing-library/react-hooks';

import useCurrentUserAuth from './useCurrentUserAuth';
import {SignInError} from '../legacy_react/src/lib/api/errors';

// we're mocking the webUserSignIn
jest.mock('../legacy_react/src/lib/api/sign_in');
import webUserSignIn from '../legacy_react/src/lib/api/sign_in';
const mockedWebUserSignIn = webUserSignIn as jest.Mocked<typeof webUserSignIn>;


type FullProps = React.PropsWithChildren<MockCurrentUserProviderProps>


describe('useCurrentUseAuth', () => {
	describe('when no user logged in', () => {
		const wrapper = (props:FullProps) => <MockCurrentUserProvider>{props.children}</MockCurrentUserProvider>;

		it('has null currentUser', () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.currentUser).toBeNull();
		});

		it('is not signedIn', () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.signedIn).toBe(false);
		});

		it('is not submitting', () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.submitting).toBe(false);
		});

		it('has no lastError', () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.lastError).toBeNull();
		});

		it('is not failed', async () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.failed).toBe(false);
		});

		describe('.signIn', () => {
			describe('resolve', () => {
				describe('hook state', () => {
					async function resolve() {
						mockedWebUserSignIn.postSignIn.mockResolvedValueOnce({id:2});
						const hook = renderHook(() => useCurrentUserAuth(), {wrapper});
						await act(async () => {
							return hook.result.current.signIn({email:'fake', password: 'fake'});
						});

						return hook;
					}


					it('has currentUser', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.currentUser).toStrictEqual({id: 2});
					});

					it('is signedIn', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.signedIn).toBe(true);
					});

					it('is not submitting', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.submitting).toBe(false);
					});

					it('has no lastError', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.lastError).toBeNull();
					});

					it('is not failed', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.failed).toBe(false);
					});
				});
				describe('promise result', () => {
					async function resolve():Promise<unknown>{
						mockedWebUserSignIn.postSignIn.mockResolvedValueOnce({id:2});
						const hook = renderHook(() => useCurrentUserAuth(), {wrapper});
						let promiseResult = null;
						await act(async () => {
							promiseResult = await hook.result.current.signIn({email:'fake', password: 'fake'});
						});

						return promiseResult;
					}

					it('returns the result of the postSignIn call', async () => {
						expect.assertions(1);
						const result = await resolve();

						expect(result).toStrictEqual({id: 2});
					});
				});
			});

			describe('reject', () => {
				async function reject() {
					mockedWebUserSignIn.postSignIn.mockRejectedValueOnce(new SignInError({status: 400, data: {error: 'Not valid'}}));
					const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});
					try {
						await act(async () => result.current.signIn({email:'fake', password: 'fake'}));
					}
					catch {
						//fine;
					}

					return result;
				}

				it('has no currentUser', async () => {
					expect.assertions(1);
					const result = await reject();

					expect(result.current.currentUser).toBeNull();
				});

				it('is not signedIn', async () => {
					expect.assertions(1);
					const result = await reject();
					expect(result.current.signedIn).toBe(false);
				});

				it('is not submitting', async () => {
					expect.assertions(1);
					const result = await reject();
					expect(result.current.submitting).toBe(false);
				});

				it('has lastError', async () => {
					expect.assertions(2);
					const result = await reject();

					expect(result.current.lastError.status).toBe(400);
					expect(result.current.lastError.data).toStrictEqual([{error: 'Not valid'}]);
				});

				it('is failed', async () => {
					expect.assertions(1);
					const result = await reject();

					expect(result.current.failed).toBe(true);
				});

				describe('promise rejection', () => {
					async function reject():Promise<SignInError>{
						mockedWebUserSignIn.postSignIn.mockRejectedValueOnce(new SignInError({status: 400, data: {error: 'Not valid'}}));
						const hook = renderHook(() => useCurrentUserAuth(), {wrapper});
						try {
							await act(async () => {
								await hook.result.current.signIn({email:'fake', password: 'fake'});
							});
						}
						catch(e) {
							return e;
						}
					}

					it('throws a SignInError', async () => {
						expect.assertions(3);
						const result = await reject();

						expect(result).toBeInstanceOf(SignInError);
						expect(result.status).toBe(400);
						expect(result.data).toStrictEqual([{error: 'Not valid'}]);
					});
				});
			});

			describe('on submit', () => {
				describe('sets submitting', () => {
					async function prepare(expectations:(hook:RenderHookResult<unknown, ReturnType<typeof useCurrentUserAuth>>) => void) {
						const hook = renderHook(() => useCurrentUserAuth(), {wrapper});
						// we need to test what is happening as the postLogin promise is happening
						mockedWebUserSignIn.postSignIn.mockImplementationOnce(async () => {
							await hook.wait(() => expectations(hook));
							return {id: 3};
						});

						await act(async () => {
							await hook.result.current.signIn({email:'fake', password: 'fake'});
						});
					}
					it('to true', async () => {
						expect.hasAssertions();
						await prepare((hook) => expect(hook.result.current.submitting).toBe(true));

					});
				});
			});
		});
	});

	describe('user already logged in', () => {
		const wrapper = (props:FullProps) => <MockCurrentUserProvider initialUserId={1}>{props.children}</MockCurrentUserProvider>;

		it('has currentUser', () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.currentUser).toStrictEqual({id: 1});
		});

		it('is signedIn', () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.signedIn).toBe(true);
		});

		it('is not submitting', () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.submitting).toBe(false);
		});

		it('has no lastError', () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.lastError).toBeNull();
		});

		it('is not failed', () => {
			expect.assertions(1);
			const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});

			expect(result.current.failed).toBe(false);
		});

		describe('.signIn', () => {
			describe('resolve', () => {
				describe('hook state', () => {
					async function prepare() {
						const hook = renderHook(() => useCurrentUserAuth(), {wrapper});
						await act(async () => {
							return hook.result.current.signIn({email:'fake', password: 'fake'});
						});

						return hook;
					}
					async function resolve(){
						mockedWebUserSignIn.postSignIn.mockResolvedValueOnce({id:2});
						return await prepare();
					}


					it('has currentUser of 2', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.currentUser).toStrictEqual({id: 2});
					});

					it('is signedIn', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.signedIn).toBe(true);
					});

					it('is not submitting', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.submitting).toBe(false);
					});

					it('has no lastError', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.lastError).toBeNull();
					});

					it('is not failed', async () => {
						expect.assertions(1);
						const {result} = await resolve();

						expect(result.current.failed).toBe(false);
					});
				});
				describe('promise result', () => {
					async function resolve():Promise<unknown>{
						mockedWebUserSignIn.postSignIn.mockResolvedValueOnce({id:2});
						const hook = renderHook(() => useCurrentUserAuth(), {wrapper});
						let promiseResult = null;
						await act(async () => {
							promiseResult = await hook.result.current.signIn({email:'fake', password: 'fake'});
						});

						return promiseResult;
					}

					it('returns the result of the postSignIn call', async () => {
						expect.assertions(1);
						const result = await resolve();

						expect(result).toStrictEqual({id: 2});
					});
				});
			});

			describe('reject', () => {
				async function reject() {
					mockedWebUserSignIn.postSignIn.mockRejectedValueOnce(new SignInError({status: 400, data: {error: 'Not valid'}}));
					const {result} = renderHook(() => useCurrentUserAuth(), {wrapper});
					try {
						await act(async () => result.current.signIn({email:'fake', password: 'fake'}));
					}
					catch {
						// don't care about the exception for the test
					}

					return result;
				}

				it('has currentUser', async () => {
					expect.assertions(1);
					const result = await reject();

					expect(result.current.currentUser).toStrictEqual({id: 1});
				});

				it('is signedIn', async () => {
					expect.assertions(1);
					const result = await reject();
					expect(result.current.signedIn).toBe(true);
				});

				it('is not submitting', async () => {
					expect.assertions(1);
					const result = await reject();
					expect(result.current.submitting).toBe(false);
				});

				it('has lastError', async () => {
					expect.assertions(2);
					const result = await reject();

					expect(result.current.lastError.status).toBe(400);
					expect(result.current.lastError.data).toStrictEqual([{error: 'Not valid'}]);
				});

				describe('promise rejection', () => {
					async function reject():Promise<SignInError>{
						mockedWebUserSignIn.postSignIn.mockRejectedValueOnce(new SignInError({status: 400, data: {error: 'Not valid'}}));
						const hook = renderHook(() => useCurrentUserAuth(), {wrapper});
						try {
							await act(async () => {
								await hook.result.current.signIn({email:'fake', password: 'fake'});
							});
						}
						catch(e) {
							return e;
						}
					}

					it('throws a SignInError', async () => {
						expect.assertions(3);
						const result = await reject();

						expect(result).toBeInstanceOf(SignInError);
						expect(result.status).toBe(400);
						expect(result.data).toStrictEqual([{error: 'Not valid'}]);
					});
				});
			});

			describe('on submit', () => {
				describe('sets submitting', () => {
					async function prepare(expectations:(hook:RenderHookResult<unknown, ReturnType<typeof useCurrentUserAuth>>) => void) {
						const hook = renderHook(() => useCurrentUserAuth(), {wrapper});
						// we need to test what is happening as the postLogin promise is happening
						mockedWebUserSignIn.postSignIn.mockImplementationOnce(async () => {
							await hook.wait(() => expectations(hook));
							return {id: 3};
						});

						await act(async () => {
							await hook.result.current.signIn({email:'fake', password: 'fake'});
						});
					}
					it('to true', async () => {
						expect.hasAssertions();
						await prepare((hook) => expect(hook.result.current.submitting).toBe(true));
					});
				});
			});
		});
	});
});