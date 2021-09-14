import '@testing-library/jest-dom/extend-expect';
import { renderHook } from '@testing-library/react-hooks';
import useIsSubmitting from '../../users/useIsSubmitting';

jest.mock('../../useCurrentUserAuth');

describe('useIsSubmitting', () => {
  describe('when the input is valid', () => {
    describe('when the state from useCurrentUserAuth is submitting', () => {
      const onSubmittingMock = jest.fn();
      it('should be submitting', () => {
        expect.assertions(1);
        const { result } = renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: true, submitting: true } });
        expect(result.current).toBe(true);
      });

      it('should call onSubmitting', () => {
        expect.assertions(1);
        renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: true, submitting: false } });
        expect(onSubmittingMock).toBeCalledTimes(1);
      });
    });

    describe('when the state from useCurrentUserAuth is NOT submitting yet', () => {
      const onSubmittingMock = jest.fn();
      it('should NOT be submitting', () => {
        expect.assertions(1);
        const { result } = renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: true, submitting: false } });
        expect(result.current).toBe(false);
      });

      it('should NOT call onSubmitting', () => {
        expect.assertions(1);
        renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: true, submitting: false } });
        expect(onSubmittingMock).not.toBeCalled();
      });
    });
  });

  describe('when the input is not valid', () => {
    const onSubmittingMock = jest.fn();
    describe('when the state from useCurrentUserAuth is submitting', () => {
      it('should NOT be submitting', () => {
        expect.assertions(1);
        const { result } = renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: true, submitting: false } });
        expect(result.current).toBe(false);
      });

      it('should NOT call onSubmitting', () => {
        expect.assertions(1);
        renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: true, submitting: false } });
        expect(onSubmittingMock).not.toBeCalled();
      });
    });

    describe('when the state from useCurrentUserAuth is NOT submitting yet', () => {
      it('should NOT be submitting', () => {
        expect.assertions(1);
        const { result } = renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: true, submitting: false } });
        expect(result.current).toBe(false);
      });

      it('should NOT call onSubmitting', () => {
        expect.assertions(1);
        renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: true, submitting: false } });
        expect(onSubmittingMock).not.toBeCalled();
      });
    });
  });

  describe('when state changes', () => {
    const onSubmittingMock = jest.fn();
    describe('from the initial state to valid and submitting', () => {
      it('should start as NOT submitting and end as submitting', () => {
        expect.assertions(2);
        let isValid = false;
        let submitting = false;
        const { result, rerender } = renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: isValid, submitting: submitting } });
        expect(result.current).toBe(false);
        isValid = true;
        submitting = true;
        rerender({ onSubmitting: onSubmittingMock, isValid: isValid, submitting: submitting });
        expect(result.current).toBe(true);
      });
    });

    describe('from submitting to not submitting', () => {
      it('should start as submitting and end as NOT submitting', () => {
        expect.assertions(2);
        let isValid = true;
        let submitting = true;
        const { result, rerender } = renderHook(({ onSubmitting, isValid, submitting }) => useIsSubmitting(onSubmitting, isValid, submitting), { initialProps: { onSubmitting: onSubmittingMock, isValid: isValid, submitting: submitting } });
        expect(result.current).toBe(true);
        submitting = false;
        rerender({ onSubmitting: onSubmittingMock, isValid: isValid, submitting: submitting });
        expect(result.current).toBe(false);
      });
    });
  });
});
