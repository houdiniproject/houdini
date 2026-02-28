/* eslint-disable no-case-declarations */
// License: LGPL-3.0-or-later
import { useReducer, useCallback, useEffect } from "react";
import take from 'lodash/take';
import noop from 'lodash/noop';
import fromPairs from 'lodash/fromPairs';

import findLastIndex from 'lodash/findLastIndex';
import hashLeftAntiJoin from 'lodash-joins/lib/hash/hashLeftAntiJoin';
import hashRightAntiJoin from 'lodash-joins/lib/hash/hashRightAntiJoin';

export interface KeyedStep {
	key: string;
}

export interface KeyedStepMap<T = unknown> {
	[stepKey: string]: T;
}

/**
 * A type extending KeyedStep with T
 */
export type KeyedStepWith<T> = T & KeyedStep;

export interface ReadonlyStepsState {
	readonly activeStep: number;
	readonly activeStepKey: string|null;
	readonly completed: KeyedStepMap<boolean>;
	readonly disabled: KeyedStepMap<boolean>;
	/**
	 * An internal copy of steps which only includes the key
	 */
	readonly stepKeys: readonly string[];

}

function areKeyedStepsDifferent(first: readonly string[], second: readonly string[]) {
	return first.length != second.length || first.find((value, index) => second[index] != value);
}

function getIndexAndKeyPair(steps: readonly string[], step: string | number | unknown): { index: number, key: string } | false {

	if (typeof step === 'string') {
		const index = steps.findIndex((i) => i === step);
		if (index) {
			return { key: step, index };
		}
	}
	else if (typeof step === 'number' && step >= 0 && step < steps.length) {
		return { key: steps[step], index: step };
	}
	return false;
}

function getLastEnabledBeforeGivenStep(
	steps: readonly string[],
	currentActiveStep: number,
	disabled: KeyedStepMap<boolean>
): { index: number, key: string } {
	const possibleNewActiveStep = findLastIndex(take(steps, currentActiveStep + 1), (i) => !disabled[i]);
	const index = possibleNewActiveStep >= 0 ? possibleNewActiveStep : 0;
	return { key: steps[index], index };
}

function reindexState(state: ReadonlyStepsState, incomingSteps: readonly KeyedStep[]): ReadonlyStepsState {
	const incomingStepKeys = incomingSteps.map(i => i.key);
	//if true, we've had new steps added or removed
	if (areKeyedStepsDifferent(state.stepKeys, incomingStepKeys)) {
		const newIndexOfActiveStep = incomingStepKeys.findIndex(v => v === state.activeStepKey);
		let activeStep = state.activeStep;
		let activeStepKey = state.activeStepKey;
		let completed = state.completed;
		let disabled = state.disabled;

		const deleted = hashLeftAntiJoin(state.stepKeys as string[], (a) => a, incomingStepKeys as string[], (b) => b);
		const added = hashRightAntiJoin(state.stepKeys as string[], (a) => a, incomingStepKeys as string[], (b) => b);

		if (deleted.length > 0 || added.length > 0) {
			completed = { ...completed };
			disabled = { ...disabled };

			deleted.forEach((i) => {
				delete completed[i];
				delete disabled[i];
			});

			added.forEach((i) => {
				completed[i] = false;
				disabled[i] = false;
			});
		}

		//did activeStep move
		if (newIndexOfActiveStep != state.activeStep) {
			//activeStep moved!

			//is activeStep still in the new list?
			if (newIndexOfActiveStep >= 0) {
				activeStep = newIndexOfActiveStep;
			}
			else {
				// new activestep is the last step before where activeStep was that is enabled (or 0)
				const newActiveStep = getLastEnabledBeforeGivenStep(incomingStepKeys, state.activeStep, disabled);
				activeStep = newActiveStep.index;
				activeStepKey = newActiveStep.key;
			}
		}

		return { ...state, stepKeys: incomingStepKeys, activeStep, activeStepKey, completed, disabled };
	}

	return state;
}

interface StepsInitOptions {
	readonly activeStep?: number;
	readonly completed?: KeyedStepMap<boolean>;
	readonly disabled?: KeyedStepMap<boolean>;
}


export interface InputStepsState<T> {
	readonly addStep: (step: KeyedStepWith<T>, before?: number) => void;
	readonly removeStep: (step: KeyedStepWith<T>) => void;
	readonly steps: readonly KeyedStepWith<T>[];

}


export interface StepsObject<T> extends StepsInitOptions {
	readonly addStep: (step: KeyedStepWith<T>, before?: number) => void;
	back: () => void;
	complete: (step: number) => void;
	disable: (step: number) => void;
	enable: (step: number) => void;
	first: () => void;
	goto: (step: number) => void;
	last: () => void;
	next: () => void;
	readonly removeStep: (step: KeyedStepWith<T>) => void;
	readonly steps: readonly KeyedStepWith<T>[];
	uncomplete: (step: number) => void;
}

type StepActionTypes = 'goto' | 'first' | 'last' | 'back' | 'next' | 'complete' | 'uncomplete' | 'disable' | 'enable' | 'stepsChanged';

interface StepAction<T> {
	payload?: number | string | readonly KeyedStepWith<T>[];
	type: StepActionTypes;
}
function stepsReducer<T>(state: ReadonlyStepsState, args: StepAction<T>): ReadonlyStepsState {
	let indexKeyPair: ReturnType<typeof getIndexAndKeyPair> = false;
	switch (args.type) {
		case ('goto'):
			indexKeyPair = getIndexAndKeyPair(state.stepKeys, args.payload);
			if (indexKeyPair && !state.disabled[indexKeyPair.key]) {
				return { ...state, activeStep: indexKeyPair.index, activeStepKey: indexKeyPair.key };
			}
			return state;
		case ('first'):
			const firstStep = 0;
			if (state.activeStep != firstStep) {
				return { ...state, activeStep: firstStep, activeStepKey: state.stepKeys[firstStep] };
			}
			return state;
		case ('last'):
			const lastStep = state.stepKeys.length - 1 >= 0 ? state.stepKeys.length - 1 : 0;
			if (state.activeStep != lastStep && !state.disabled[state.stepKeys[lastStep]]) {
				return { ...state, activeStep: lastStep, activeStepKey: state.stepKeys[lastStep] };
			}
			return state;
		case ('back'):
			const backStep = state.activeStep - 1;
			if ((backStep === 0) || (backStep >= 0 && !state.disabled[state.stepKeys[backStep]])) {
				return { ...state, activeStep: backStep, activeStepKey: state.stepKeys[backStep] };
			}
			return state;
		case ('next'):
			const nextStep = state.activeStep + 1;
			if (nextStep < state.stepKeys.length && !state.disabled[state.stepKeys[nextStep]]) {
				return { ...state, activeStep: nextStep, activeStepKey: state.stepKeys[nextStep] };
			}
			return state;
		case ('complete'):
			indexKeyPair = getIndexAndKeyPair(state.stepKeys, args.payload);
			if (indexKeyPair) {
				const completed = { ...state.completed };
				completed[indexKeyPair.key] = true;
				return { ...state, completed: completed };
			}
			return state;
		case ('uncomplete'):
			indexKeyPair = getIndexAndKeyPair(state.stepKeys, args.payload);
			if (indexKeyPair) {
				const completed = { ...state.completed };
				completed[indexKeyPair.key] = false;
				return { ...state, completed };
			}
			return state;
		case ('disable'):
			indexKeyPair = getIndexAndKeyPair(state.stepKeys, args.payload);
			if (indexKeyPair) {
				const disabled = { ...state.disabled };
				disabled[indexKeyPair.key] = true;
				let { activeStep, activeStepKey } = state;
				if (state.activeStep == indexKeyPair.index) {
					const result = getLastEnabledBeforeGivenStep(state.stepKeys, activeStep, disabled);
					activeStep = result.index;
					activeStepKey = result.key;
				}
				return { ...state, disabled, activeStep, activeStepKey };
			}
			return state;
		case ('enable'):
			indexKeyPair = getIndexAndKeyPair(state.stepKeys, args.payload);
			if (indexKeyPair) {
				const disabled = { ...state.disabled };
				disabled[indexKeyPair.key] = false;
				return { ...state, disabled };
			}
			return state;
		case ('stepsChanged'):
			if (typeof args.payload === 'object') {
				return reindexState(state, args.payload);
			}
			return state;
		default:
			throw new Error();
	}
}

export default function useSteps<T>(state: InputStepsState<T>, initOptions: StepsInitOptions = {}): Readonly<StepsObject<T>> {

	const activeStep = initOptions.activeStep || 0;

	const initialSteps = state.steps.map(i => i.key);
	const initialState: ReadonlyStepsState = {
		completed: initOptions.completed || fromPairs(initialSteps.map((i) => [i, false])),
		disabled: initOptions.disabled || fromPairs(initialSteps.map((i) => [i, false])),
		stepKeys: initialSteps,
		activeStep,
		activeStepKey: activeStep >= 0 && activeStep < state.steps.length ? state.steps[activeStep].key : null,
	};
	const [stepsState, dispatch] = useReducer(stepsReducer, initialState);

	const { steps } = state;

	const goto = useCallback((step: number | string) => {
		dispatch({ type: "goto", payload: step });
	}, []);

	const back = useCallback(() => {
		dispatch({ type: 'back' });
	}, []);

	const next = useCallback(() => {
		dispatch({ type: 'next' });
	}, []);

	const first = useCallback(() => {
		dispatch({ type: 'first' });
	}, []);

	const last = useCallback(() => {
		dispatch({ type: 'last' });
	}, []);

	const complete = useCallback((step: number) => {
		dispatch({ type: "complete", payload: step });
	}, []);

	const uncomplete = useCallback((step: number) => {
		dispatch({ type: "uncomplete", payload: step });
	}, []);

	const disable = useCallback((step: number) => {
		dispatch({ type: "disable", payload: step });
	}, []);

	const enable = useCallback((step: number) => {
		dispatch({ type: "enable", payload: step });
	}, []);

	useEffect(() => {
		dispatch({ type: 'stepsChanged', payload: steps });
	}, [steps]);

	// eslint-disable-next-line @typescript-eslint/no-unused-vars
	const { activeStepKey, stepKeys, ...outputSteps } = stepsState;
	return Object.freeze({
		steps,
		...outputSteps,
		goto,
		back,
		next,
		first,
		last,
		complete,
		uncomplete,
		disable,
		enable,
		addStep: noop,
		removeStep: noop,
	});

}
