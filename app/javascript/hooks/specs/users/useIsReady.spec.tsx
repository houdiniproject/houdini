import '@testing-library/jest-dom/extend-expect';
import { renderHook } from '@testing-library/react-hooks';
import useIsReady from '../../users/useIsReady';
import { NetworkError } from '../../../api/errors';

describe('useIsReady', () => {
  const error = new NetworkError({ data: 'empty', status: 403 });
  const onFailureMock = jest.fn();

  describe('when it was submitting', () => {
    const wasSubmitting = true;
    const failed = true;
    const submitting = true;

    describe('when it failed', () => {
      it('should be ready', () => {
        expect.assertions(1);
        const { result } = renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
        expect(result.current).toBe(true);
      });

      it('should call onFailure', () => {
        const onFailureMock = jest.fn();
        expect.assertions(1);
        renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
        expect(onFailureMock).toBeCalledWith(error);
      });
    });

    describe('when it did NOT fail', () => {
      const failed = false;

      describe('when it is submitting', () => {
        const submitting = true;
        it('should NOT be ready', () => {
          expect.assertions(1);
          const { result } = renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
          expect(result.current).toBe(false);
        });

        it('should NOT call onFailure', () => {
          const onFailureMock = jest.fn();
          expect.assertions(1);
          renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
          expect(onFailureMock).not.toBeCalled();
        });
      });

      describe('when it is not submitting', () => {
        const submitting = false;
        it('should be ready', () => {
          expect.assertions(1);
          const { result } = renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
          expect(result.current).toBe(true);
        });

        it('should NOT call onFailure', () => {
          const onFailureMock = jest.fn();
          expect.assertions(1);
          renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
          expect(onFailureMock).not.toBeCalled();
        });
      });
    });
  });

  describe('when it was NOT submitting', () => {
    const wasSubmitting = false;
    const failed = true;
    const submitting = true;

    describe('when it is submitting', () => {
      it('should NOT be ready', () => {
        expect.assertions(1);
        const { result } = renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
        expect(result.current).toBe(false);
      });

      it('should NOT call onFailure', () => {
        const onFailureMock = jest.fn();
        expect.assertions(1);
        renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
        expect(onFailureMock).not.toBeCalled();
      });
    });

    describe('when it is NOT submitting', () => {
      const submitting = false;
      it('should be ready', () => {
        expect.assertions(1);
        const { result } = renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
        expect(result.current).toBe(true);
      });

      it('should NOT call onFailure', () => {
        const onFailureMock = jest.fn();
        expect.assertions(1);
        renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
        expect(onFailureMock).not.toBeCalled();
      });
    })
  });

  describe('when state changes', () => {
    describe('from the initial state to submitting', () => {
      const failed = false;
      const wasSubmitting = false;

      it('should start as ready and end as NOT ready', () => {
        expect.assertions(2);
        let submitting = false;
        const { result, rerender } = renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
        expect(result.current).toBe(true);
        submitting = true;
        rerender({ wasSubmitting: wasSubmitting, failed: failed, submitting: submitting });
        expect(result.current).toBe(false);
      });
    });

    describe('from submitting to failed and wasSubmitting', () => {
      it('should start as NOT ready and end as ready', () => {
        expect.assertions(2);
        let failed = false;
        let wasSubmitting = false;
        let submitting = true;
        const { result, rerender } = renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
        expect(result.current).toBe(false);
        submitting = false;
        failed = true;
        wasSubmitting = true;
        rerender({ wasSubmitting: wasSubmitting, failed: failed, submitting: submitting });
        expect(result.current).toBe(true);
      });
    });

    describe('from failed and wasSubmitting to submitting', () => {
      it('should start as ready and end as NOT ready', () => {
        expect.assertions(2);
        let failed = true;
        let wasSubmitting = true;
        let submitting = false;
        const { result, rerender } = renderHook(({ wasSubmitting, failed, submitting }) => useIsReady(wasSubmitting, onFailureMock, failed, error, submitting), { initialProps: { wasSubmitting: wasSubmitting, failed: failed, submitting: submitting } });
        expect(result.current).toBe(true);
        submitting = true;
        failed = false;
        wasSubmitting = false;
        rerender({ wasSubmitting: wasSubmitting, failed: failed, submitting: submitting });
        expect(result.current).toBe(false);
      });
    });
  });
});
