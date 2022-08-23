/* eslint-disable jest/no-hooks */
// License: LGPL-3.0-or-later
import { renderHook, act } from '@testing-library/react-hooks';
import useSteps, { KeyedStep, KeyedStepMap } from './useSteps';
import fromPairs from 'lodash/fromPairs';
import { noop } from 'lodash';


const stepActions = { addStep: noop, removeStep: noop };

describe('.next', () => {

	it('nothing changes if there is no next', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }], ...stepActions }));
		const original = result.current;
		act(() => {
			result.current.next();
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('nothing changes if next is disabled', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }, {
			disabled: { 'i': false, '2': true },
		}));
		const original = result.current;
		act(() => {
			result.current.next();
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('go to next if next exists', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }));
		const original = result.current;
		act(() => {
			result.current.next();
		});

		expect(result.current.activeStep).toBe(1);
		expect(Object.is(result.current, original)).toBe(false);
	});


});

describe('.back', () => {

	it('nothing changes if there is no back', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }], ...stepActions }));
		const original = result.current;
		act(() => {
			result.current.back();
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('nothing changes if back is disabled', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }, { key: 'last' }], ...stepActions }, {
			activeStep: 2,
			disabled: { 'i': true, '2': true, 'last': false },
		}));
		const original = result.current;
		act(() => {
			result.current.back();
		});

		expect(result.current.activeStep).toBe(2);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('if back is the first item, we ignore its disabled state', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }, { key: 'last' }], ...stepActions }, {
			activeStep: 1,
			disabled: { 'i': true, '2': false, 'last': false },
		}));
		const original = result.current;
		act(() => {
			result.current.back();
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(false);
	});

	it('go to back if back exists', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }, { activeStep: 1 }));
		const original = result.current;
		act(() => {
			result.current.back();
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(false);
	});

});

describe('.goto', () => {

	it('nothing changes if goto value is below 0', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }], ...stepActions }));
		const original = result.current;
		act(() => {
			result.current.goto(-1);
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('nothing changes if goto value is bigger number of steps', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }], ...stepActions }));
		const original = result.current;
		act(() => {
			result.current.goto(1);
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('nothing changes if goto value is disabled', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }, {
			disabled: { 'i': false, '2': true },
		}));
		const original = result.current;
		act(() => {
			result.current.goto(1);
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('if goto step is 0, we always go back regardless of disabledness', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }, {
			activeStep: 1,
			disabled: { 'i': false, '2': true },
		}));
		const original = result.current;
		act(() => {
			result.current.goto(0);
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(false);
	});

	it('goto step if it exists', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }, { activeStep: 1 }));
		const original = result.current;
		act(() => {
			result.current.goto(1);
		});

		expect(result.current.activeStep).toBe(1);
		expect(Object.is(result.current, original)).toBe(false);
	});

});

describe('.first', () => {

	it('changes nothing if already first', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }));
		const original = result.current;
		act(() => {
			result.current.first();
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('if first is disabled we still go back', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }, {
			activeStep: 1,
			disabled: { 'i': true, '2': false },
		}));
		const original = result.current;
		act(() => {
			result.current.first();
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(false);
	});

	it('go to first', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }, { activeStep: 1 }));
		const original = result.current;

		act(() => {
			result.current.first();
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(false);
	});

});

describe('.last', () => {
	it('changes nothing if already last', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }, { activeStep: 1 }));
		const original = result.current;
		act(() => {
			result.current.last();
		});

		expect(result.current.activeStep).toBe(1);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('changes nothing if last is disabled', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }, {
			disabled: { 'i': false, '2': true },
		}));
		const original = result.current;
		act(() => {
			result.current.last();
		});

		expect(result.current.activeStep).toBe(0);
		expect(Object.is(result.current, original)).toBe(true);
	});

	it('go to last', async () => {
		expect.assertions(2);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i' }, { key: '2' }], ...stepActions }));
		const original = result.current;
		act(() => {
			result.current.last();
		});

		expect(result.current.activeStep).toBe(1);
		expect(Object.is(result.current, original)).toBe(false);
	});


});

describe('.disable', () => {
	describe.each([
		[[{ key: 'i' }, { key: '2' }], 1, { i: false, 2: false }, 1, 0, { i: false, 2: true }],
		[[{ key: 'i' }, { key: '2' }], 0, { i: false, 2: false }, 1, 0, { i: false, 2: true }],
		[[{ key: 'i' }, { key: '2' }], 1, { i: true, 2: false }, 1, 0, { i: true, 2: true }],
		[[{ key: 'i' }, { key: '2' }], 0, { i: false, 2: false }, 0, 0, { i: true, 2: false }],
	])('.disable with keys of %j, activeStep: %d, initial disabled: %j, we disabled index %d', (
		steps,
		initialActiveStep,
		initialDisabled,
		indexToDisable,
		activeStep,
		disabled) => {
		let current: ReturnType<typeof useSteps>;

		beforeEach(() => {
			const { result } = renderHook(() => useSteps({ steps, ...stepActions },
				{ activeStep: initialActiveStep, disabled: initialDisabled }));
			act(() => {
				result.current.disable(indexToDisable);
			});
			current = result.current;
		});


		it(`sets activeStep to ${activeStep}`, () => {
			expect.hasAssertions();
			expect(current.activeStep).toBe(activeStep);
		});


		it(`sets disabled to properly`, () => {
			expect.hasAssertions();
			expect(current.disabled).toStrictEqual(disabled);
		});
	});
});


describe('.enable', () => {
	describe.each([
		[[{ key: 'i' }, { key: '2' }], 1, { i: false, 2: false }, 1, 1, { i: false, 2: false }],
		[[{ key: 'i' }, { key: '2' }], 0, { i: false, 2: true }, 1, 0, { i: false, 2: false }],
		[[{ key: 'i' }, { key: '2' }], 1, { i: true, 2: false }, 1, 1, { i: true, 2: false }],
		[[{ key: 'i' }, { key: '2' }], 0, { i: true, 2: false }, 0, 0, { i: false, 2: false }],
	])('.enable with keys of %j, activeStep: %d, initial enabled: %j, we enable index %d', (
		steps,
		initialActiveStep,
		initialDisabled,
		indexToEnable,
		activeStep,
		disabled) => {
		let current: ReturnType<typeof useSteps>;

		beforeEach(() => {
			const { result } = renderHook(() => useSteps({ steps, ...stepActions },
				{ activeStep: initialActiveStep, disabled: initialDisabled }));
			act(() => {
				result.current.enable(indexToEnable);
			});
			current = result.current;
		});


		it(`sets activeStep to ${activeStep}`, () => {
			expect.hasAssertions();
			expect(current.activeStep).toBe(activeStep);
		});


		it(`sets disabled to properly`, () => {
			expect.hasAssertions();
			expect(current.disabled).toStrictEqual(disabled);
		});
	});
});


describe('modify steps', () => {
	function createTableEntry(props: {
		expectation: {
			activeStep?: number;
			completed?: KeyedStepMap<boolean>;
			disabled?: KeyedStepMap<boolean>;
		};
		initial: {
			activeStep?: number;
			completed?:
			KeyedStepMap<boolean>;
			disabled?: KeyedStepMap<boolean>;
			steps: KeyedStep[];
		};
		stepChange: KeyedStep[];
	}
	): [
			KeyedStep[], number | undefined, KeyedStepMap<boolean> | undefined, KeyedStepMap<boolean> | undefined, // initial
			KeyedStep[], //stepChange
			number | undefined, KeyedStepMap<boolean>, KeyedStepMap<boolean>, //expectations
		] {
		const expectation = {
			activeStep: props.initial.activeStep || 0,
			disabled: props.initial.disabled || fromPairs(props.initial.steps.map(i => [i.key, false])),
			completed: props.initial.completed || fromPairs(props.initial.steps.map(i => [i.key, false])),
			...props.expectation,
		};
		return [
			props.initial.steps, props.initial.activeStep, props.initial.disabled, props.initial.completed,
			props.stepChange,
			expectation.activeStep, expectation.disabled, expectation.completed,
		];
	}

	describe.each([
		createTableEntry({
			initial: { steps: [{ key: 'i' }, { key: '2' }] },
			stepChange: [{ key: 'i' }, { key: '2' }],
			expectation: {
			},
		}),
		createTableEntry({
			initial: { steps: [{ key: 'i' }, { key: '2' }], activeStep: 0 },
			stepChange: [ { key: '2' }],
			expectation: {
				disabled: {2: false},
				completed: {2: false},
			},
		}),
		createTableEntry({
			initial: { steps: [{ key: 'i' }, { key: '2' }], activeStep: 1 },
			stepChange: [ { key: 'i' }],
			expectation: {
				activeStep: 0,
				disabled: {i: false},
				completed: {i: false},
			},
		}),
		createTableEntry({
			initial: { steps: [{ key: 'i' }, { key: '2' }, {key: 'last'}], activeStep: 2, disabled: {i: false, 2: true, last:false}},
			stepChange: [ { key: 'i' }, { key: '2' }],
			expectation: {
				activeStep: 0,
				disabled: {i: false, 2: true},
				completed: {i: false, 2: false},
			},
		}),
		createTableEntry({
			initial: { steps: [{ key: 'i' }, { key: '2' }, {key: 'last'}], activeStep: 2, disabled: {i: false, 2: true, last:false}},
			stepChange: [ { key: 'i' }, {key: 'last'}, { key: '2' }],
			expectation: {
				activeStep: 1,
				disabled: {i: false, 2: true, last:false},
				completed: {i: false, 2: false, last: false},
			},
		}),

		createTableEntry({
			initial: { steps: [{ key: 'i' }, { key: '2' }, {key: 'last'}], activeStep: 2, disabled: {i: false, 2: true, last:false}},
			stepChange: [ {key: 'last'},{ key: 'i' }],
			expectation: {
				activeStep: 0,
				disabled: {i: false,  last:false},
				completed: {i: false,  last: false},
			},
		}),
	])('with initial steps %j, active: %d, disabled: %o, completed: %o and change steps to %j', (
		initialSteps, initialActiveStep, initialDisabled, initialCompleted,
		stepChange,
		expectationActiveStep, expectationDisabled, expectationCompleted
	) => {
		let finalState:ReturnType<typeof useSteps>;
		beforeEach(() => {
			const { result, rerender } = renderHook((steps) => useSteps({ steps, ...stepActions },
				{ activeStep: initialActiveStep, disabled: initialDisabled, completed: initialCompleted }), {initialProps: initialSteps});
			rerender(stepChange);
			finalState = result.current;
		});

		it(`has the correct steps of ${JSON.stringify(stepChange)}`, () => {
			expect.hasAssertions();
			expect(finalState.steps).toStrictEqual(stepChange);
		});

		it(`has an activeStep of ${expectationActiveStep}`, () => {
			expect.hasAssertions();
			expect(finalState.activeStep).toBe(expectationActiveStep);
		});

		it(`has an disabled list of ${JSON.stringify(expectationDisabled)}`, () => {
			expect.hasAssertions();
			expect(finalState.disabled).toStrictEqual(expectationDisabled);
		});

		it(`has completed list of ${JSON.stringify(expectationCompleted)}`, () => {
			expect.hasAssertions();
			expect(finalState.completed).toStrictEqual(expectationCompleted);
		});
	});
});

describe('extended KeyedStep types', () => {
	it('additional key properties are passed through', () => {
		expect.assertions(1);
		const { result } = renderHook(() => useSteps({ steps: [{ key: 'i', anotherKey: 'something'}], ...stepActions }));
		const original = result.current;
		expect(original.steps[0].anotherKey).toBe('something');
	});
});
