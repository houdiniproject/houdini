// License: LGPL-3.0-or-later
import '@testing-library/jest-dom/extend-expect';
import { renderHook } from '@testing-library/react-hooks';
import useIsSuccessful from '../../users/useIsSuccessful';
import type { CurrentUser } from "../../useCurrentUser";
import useCurrentUserAuth from '../../useCurrentUserAuth';

jest.mock('../../useCurrentUserAuth');

describe('useIsSuccessful', () => {
	const onSuccessMock = jest.fn();
	const showProgressAndSuccess = true;
	describe('when SignIn succeeds', () => {
		describe('when showProgressAndSuccess is set to true', () => {
			it('should be successful', () => {
				expect.assertions(1);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: { id: 1 } as CurrentUser });
				const { result } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(result.current).toBe(true);
			});

			it('should call onSuccess', () => {
				expect.assertions(1);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: { id: 1 } as CurrentUser });
				const onSuccessMock = jest.fn();
				renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(onSuccessMock).toHaveBeenCalledTimes(1);
			});
		});

		describe('when showProgressAndSuccess is set to false', () => {
			const onSuccessMock = jest.fn();
			const showProgressAndSuccess = false;
			it('should NOT be successful', () => {
				expect.assertions(1);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: { id: 1 } as CurrentUser });
				const { result } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(result.current).toBe(false);
			});

			it('should NOT call onSuccess', () => {
				expect.assertions(1);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: { id: 1 } as CurrentUser });
				renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(onSuccessMock).not.toHaveBeenCalled();
			});
		});
	});

	describe('when signIn does not succeed', () => {
		const showProgressAndSuccess = true;

		describe('when showProgressAndSuccess is set to true', () => {
			it('should NOT be succeeded', () => {
				expect.assertions(1);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: undefined as CurrentUser });
				const { result } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(result.current).toBe(false);
			});

			it('should NOT call onSuccess', () => {
				expect.assertions(1);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: undefined as CurrentUser });
				const onSuccessMock = jest.fn();
				renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(onSuccessMock).not.toHaveBeenCalled();
			});
		});

		describe('when showProgressAndSuccess is set to false', () => {
			const showProgressAndSuccess = false;
			it('should NOT be succeeded', () => {
				expect.assertions(1);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: undefined as CurrentUser });
				const { result } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(result.current).toBe(false);
			});

			it('should NOT call onSuccess', () => {
				expect.assertions(1);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: undefined as CurrentUser });
				const onSuccessMock = jest.fn();
				renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(onSuccessMock).not.toHaveBeenCalled();
			});
		});
	});

	describe('when state changes', () => {
		describe('from initial state to successful', () => {
			it('should change from NOT successful to successful', () => {
				expect.assertions(2);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: undefined as CurrentUser });
				const { result, rerender } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(result.current).toBe(false);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: { id: 1 } as CurrentUser });
				rerender({ showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock });
				expect(result.current).toBe(true);
			});
		});

		describe('from successful to not logged in', () => {
			it('should change from successful to NOT successful', () => {
				expect.assertions(2);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: { id: 1 } as CurrentUser });
				const { result, rerender } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
				expect(result.current).toBe(true);
				(useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: undefined as CurrentUser });
				rerender({ showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock });
				expect(result.current).toBe(false);
			});
		});
	});
});
