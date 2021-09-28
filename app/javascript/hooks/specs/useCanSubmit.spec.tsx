import '@testing-library/jest-dom/extend-expect';
import { renderHook } from '@testing-library/react-hooks';
import useCanSubmit from '../useCanSubmit';

describe('useCanSubmit', () => {
	describe('when the input is valid', () => {
		const isValid = true;
		const showProgressAndSuccess = true;
		const touched = true;
		const isReady = true;

		describe('when the form is ready', () => {
			describe('when showProgressAndSuccess is set to true', () => {
				describe('when the form was touched', () => {

					it('should be allowed to submit', () => {
						expect.assertions(1);
						const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
						expect(result.current).toBe(true);
					});
				});

				describe('when the form was not touched', () => {
					const touched = false;
					it('should NOT be allowed to submit', () => {
						expect.assertions(1);
						const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
						expect(result.current).toBe(false);
					});
				});
			});

			describe('when showProgressAndSuccess is set to false', () => {
				const showProgressAndSuccess = false;
				it('should NOT be allowed to submit', () => {
					expect.assertions(1);
					const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
					expect(result.current).toBe(false);
				});
			});
		});

		describe('when the form is not ready', () => {
			const isReady = false;
			it('should NOT be allowed to submit', () => {
				expect.assertions(1);
				const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(false);
			});
		});
	});

	describe('when the input is invalid', () => {
		const isValid = false;
		const showProgressAndSuccess = true;
		const touched = true;
		const isReady = true;

		describe('when the form is ready', () => {
			describe('when showProgressAndSuccess is set to true', () => {
				describe('when the form was touched', () => {

					it('should NOT be allowed to submit', () => {
						expect.assertions(1);
						const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
						expect(result.current).toBe(false);
					});
				});

				describe('when the form was not touched', () => {
					const touched = false;
					it('should NOT be allowed to submit', () => {
						expect.assertions(1);
						const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
						expect(result.current).toBe(false);
					});
				});
			});

			describe('when showProgressAndSuccess is set to false', () => {
				const showProgressAndSuccess = false;
				it('should NOT be allowed to submit', () => {
					expect.assertions(1);
					const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
					expect(result.current).toBe(false);
				});
			});
		});

		describe('when the form is not ready', () => {
			const isReady = false;
			it('should NOT be allowed to submit', () => {
				expect.assertions(1);
				const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(false);
			});
		});
	});

	describe('when the form is ready', () => {
		const isValid = true;
		const showProgressAndSuccess = true;
		const touched = true;
		const isReady = true;
		describe('when showProgressAndSuccess is set to true', () => {
			describe('when the form was touched', () => {

				it('should be allowed to submit', () => {
					expect.assertions(1);
					const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
					expect(result.current).toBe(true);
				});
			});

			describe('when the form was not touched', () => {
				const touched = false;
				it('should NOT be allowed to submit', () => {
					expect.assertions(1);
					const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
					expect(result.current).toBe(false);
				});
			});
		});

		describe('when showProgressAndSuccess is set to false', () => {
			const showProgressAndSuccess = false;
			it('should NOT be allowed to submit', () => {
				expect.assertions(1);
				const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(false);
			});
		});
	});

	describe('when the form is NOT ready', () => {
		const isValid = true;
		const showProgressAndSuccess = true;
		const touched = true;
		const isReady = false;

		describe('when showProgressAndSuccess is set to true', () => {
			describe('when the form was touched', () => {

				it('should NOT be allowed to submit', () => {
					expect.assertions(1);
					const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
					expect(result.current).toBe(false);
				});
			});

			describe('when the form was not touched', () => {
				const touched = false;
				it('should NOT be allowed to submit', () => {
					expect.assertions(1);
					const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
					expect(result.current).toBe(false);
				});
			});
		});

		describe('when showProgressAndSuccess is set to false', () => {
			const showProgressAndSuccess = false;
			it('should NOT be allowed to submit', () => {
				expect.assertions(1);
				const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(false);
			});
		});
	});

	describe('when showProgressAndSuccess is set to true', () => {
		const isValid = true;
		const showProgressAndSuccess = true;
		const touched = true;
		const isReady = true;
		describe('when the form was touched', () => {

			it('should be allowed to submit', () => {
				expect.assertions(1);
				const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(true);
			});
		});

		describe('when the form was not touched', () => {
			const touched = false;
			it('should NOT be allowed to submit', () => {
				expect.assertions(1);
				const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(false);
			});
		});
	});

	describe('when showProgressAndSuccess is set to false', () => {
		const isValid = true;
		const showProgressAndSuccess = false;
		const touched = true;
		const isReady = true;

		describe('when the form was touched', () => {

			it('should NOT be allowed to submit', () => {
				expect.assertions(1);
				const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(false);
			});
		});

		describe('when the form was not touched', () => {
			const touched = false;
			it('should NOT be allowed to submit', () => {
				expect.assertions(1);
				const { result } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(false);
			});
		});
	});

	describe('when state changes', () => {
		describe('from initial state to touched', () => {
			const isValid = true;
			const showProgressAndSuccess = true;
			let touched = false;
			const isReady = true;
			it('should start as can NOT submit to can submit', () => {
				expect.assertions(2);
				const { result, rerender } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(false);
				touched = true;
				rerender({ isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched });
				expect(result.current).toBe(true);
			});
		});

		describe('from can submit to NOT ready', () => {
			const isValid = true;
			const showProgressAndSuccess = true;
			const touched = true;
			let isReady = true;
			it('should start as can submit to can NOT submit', () => {
				expect.assertions(2);
				const { result, rerender } = renderHook(({ isValid, showProgressAndSuccess, isReady, touched }) => useCanSubmit(isValid, showProgressAndSuccess, isReady, touched), { initialProps: { isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched } });
				expect(result.current).toBe(true);
				isReady = false;
				rerender({ isValid: isValid, showProgressAndSuccess: showProgressAndSuccess, isReady: isReady, touched: touched });
				expect(result.current).toBe(false);
			});
		});
	});
});
