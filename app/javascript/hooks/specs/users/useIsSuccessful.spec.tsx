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
    beforeEach(() => {
      (useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: { id: 1 } as CurrentUser });
    });

    describe('when showProgressAndSuccess is set to true', () => {
      it('should be successful', () => {
        expect.assertions(1);
        const { result } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
        expect(result.current).toBe(true);
      });

      it('should call onSuccess', () => {
        expect.assertions(1);
        const onSuccessMock = jest.fn();
        renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
        expect(onSuccessMock).toBeCalledTimes(1);
      });
    });

    describe('when showProgressAndSuccess is set to false', () => {
      const onSuccessMock = jest.fn();
      const showProgressAndSuccess = false;
      it('should NOT be successful', () => {
        expect.assertions(1);
        const { result } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
        expect(result.current).toBe(false);
      });

      it('should NOT call onSuccess', () => {
        expect.assertions(1);
        renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
        expect(onSuccessMock).not.toBeCalled();
      });
    });
  });

  describe('when signIn does not succeed', () => {
    const showProgressAndSuccess = true;

    beforeEach(() => {
      (useCurrentUserAuth as jest.Mock).mockReturnValue({ currentUser: undefined as CurrentUser });
    });

    describe('when showProgressAndSuccess is set to true', () => {
      it('should NOT be succeeded', () => {
        expect.assertions(1);
        const { result } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
        expect(result.current).toBe(false);
      });

      it('should NOT call onSuccess', () => {
        const onSuccessMock = jest.fn();
        expect.assertions(1);
        renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
        expect(onSuccessMock).not.toBeCalled();
      });
    });

    describe('when showProgressAndSuccess is set to false', () => {
      const showProgressAndSuccess = false;
      it('should NOT be succeeded', () => {
        expect.assertions(1);
        const { result } = renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
        expect(result.current).toBe(false);
      });

      it('should NOT call onSuccess', () => {
        const onSuccessMock = jest.fn();
        expect.assertions(1);
        renderHook(({ showProgressAndSuccess, onSuccess }) => useIsSuccessful(showProgressAndSuccess, onSuccess), { initialProps: { showProgressAndSuccess: showProgressAndSuccess, onSuccess: onSuccessMock } });
        expect(onSuccessMock).not.toBeCalled();
      });
    });
  });
});
