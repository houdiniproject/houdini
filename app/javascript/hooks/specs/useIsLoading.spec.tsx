import '@testing-library/jest-dom/extend-expect';
import { renderHook } from '@testing-library/react-hooks';
import useIsLoading from '../useIsLoading';

describe('useIsLoading', () => {
  it('should start as not loading', () => {
    expect.assertions(1);
    const { result } = renderHook(({ submitting, showProgressAndSuccess }) => useIsLoading(submitting, showProgressAndSuccess), { initialProps: { submitting: false, showProgressAndSuccess: false } });
    expect(result.current).toBe(false);
  });

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
});
