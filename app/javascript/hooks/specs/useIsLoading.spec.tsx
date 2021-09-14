import '@testing-library/jest-dom/extend-expect';
import { renderHook } from '@testing-library/react-hooks';
import useIsLoading from '../useIsLoading';

describe('useIsLoading', () => {
  describe('when it is submitting', () => {
    const submitting = true;

    describe('when showProgressAndSuccess is set to true', () => {
      const showProgressAndSuccess = true;
      it('should be loading', () => {
        expect.assertions(1);
        const { result } = renderHook(({ submitting, showProgressAndSuccess }) => useIsLoading(submitting, showProgressAndSuccess), { initialProps: { submitting: submitting, showProgressAndSuccess: showProgressAndSuccess } });
        expect(result.current).toBe(true);
      });
    });
    describe('when showProgressAndSuccess is set to false', () => {
      const showProgressAndSuccess = false;
      it('should NOT be loading', () => {
        expect.assertions(1);
        const { result } = renderHook(({ submitting, showProgressAndSuccess }) => useIsLoading(submitting, showProgressAndSuccess), { initialProps: { submitting: submitting, showProgressAndSuccess: showProgressAndSuccess } });
        expect(result.current).toBe(false);
      });
    });
  });

  describe('when it is NOT submitting', () => {
    const submitting = false;
    describe('when showProgressAndSuccess is set to true', () => {
      const showProgressAndSuccess = true;
      it('should NOT be loading', () => {
        expect.assertions(1);
        const { result } = renderHook(({ submitting, showProgressAndSuccess }) => useIsLoading(submitting, showProgressAndSuccess), { initialProps: { submitting: submitting, showProgressAndSuccess: showProgressAndSuccess } });
        expect(result.current).toBe(false);
      });
    });
  });

  describe('when state changes', () => {
    const showProgressAndSuccess = true;
    describe('from initial state to loading', () => {
      let submitting = false;

      it('should start as NOT loading and end as loading', () => {
        expect.assertions(2);
        const { result, rerender } = renderHook(({ submitting, showProgressAndSuccess }) => useIsLoading(submitting, showProgressAndSuccess), { initialProps: { submitting: submitting, showProgressAndSuccess: showProgressAndSuccess } });
        expect(result.current).toBe(false);
        submitting = true;
        rerender({ submitting: submitting, showProgressAndSuccess: showProgressAndSuccess });
        expect(result.current).toBe(true);
      });
    });

    describe('from loading to finished submitting', () => {
      let submitting = true;

      it('should start as loading and end as NOT loading', () => {
        expect.assertions(2);
        const { result, rerender } = renderHook(({ submitting, showProgressAndSuccess }) => useIsLoading(submitting, showProgressAndSuccess), { initialProps: { submitting: submitting, showProgressAndSuccess: showProgressAndSuccess } });
        expect(result.current).toBe(true);
        submitting = false;
        rerender({ submitting: submitting, showProgressAndSuccess: showProgressAndSuccess });
        expect(result.current).toBe(false);
      });
    });
  });
});
