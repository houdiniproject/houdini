/* eslint-disable @typescript-eslint/no-explicit-any */
// License: LGPL-3.0-or-later

import Callback from "./Callback";
import CallbackControllerBuilder from "./CallbackControllerBuilder";

jest.mock('./run', () => {
	return jest.fn();
});

import run from './run';

const runMocked = run as jest.Mock;

describe('Runner', () => {


	beforeEach(() => {
		runMocked.mockClear();
	});

	interface CustomInputType {
		field: string;
	}

	class CallbackClass1 extends Callback<CustomInputType> {

	}

	class CallbackClass2 extends Callback<CustomInputType> {

	}

	class CallbackClass3 extends Callback<CustomInputType> {

	}

	function buildRunner() {
		return new CallbackControllerBuilder('success', 'failure').withInputType<CustomInputType>();
	}

	function buildRunnerWithBeforeSuccessAndAfterForBoth() {
		const runner = new CallbackControllerBuilder('success', 'failure').withInputType<CustomInputType>();
		runner.addAfterCallback('success', CallbackClass1);
		runner.addAfterCallback('failure', CallbackClass2);
		runner.addBeforeCallback('success', CallbackClass3);
		return runner;
	}

	describe('.callbacks', () => {
		it('defaults to empty arrays for each callback type', () => {
			const runner = buildRunner();
			expect(Array.from(runner.callbacks().entries())).toStrictEqual([
				['success', {before: [], after:[]}],
				['failure', {before: [], after:[]}],
			]);
		});

		it('contains callbacks when added', () => {
			const runner = buildRunnerWithBeforeSuccessAndAfterForBoth();
			expect(Array.from(runner.callbacks().entries())).toStrictEqual([
				['success', {before: [CallbackClass3], after: [CallbackClass1]}],
				['failure', {before: [], after: [CallbackClass2]}],
			]);
		});

		it('returns Map when when no type passed', () => {
			const runner = buildRunnerWithBeforeSuccessAndAfterForBoth();
			expect(runner.callbacks()).toBeInstanceOf(Map);
		});

		it('returns undefined when an invalid callback type is passed', () => {
			const runner = buildRunner();
			expect(runner.callbacks('invalid' as any)).toBeUndefined();
		});

		it('returns an array of callbacks when a valid callback type is passed', () => {
			const runner = buildRunnerWithBeforeSuccessAndAfterForBoth();
			expect(runner.callbacks('success')).toBeInstanceOf(Object);
			expect(runner.callbacks('success')?.after).toBeInstanceOf(Array);
			expect(runner.callbacks('success')?.after).toStrictEqual([CallbackClass1]);

			expect(runner.callbacks('success')?.before).toBeInstanceOf(Array);
			expect(runner.callbacks('success')?.before).toStrictEqual([CallbackClass3]);
		});
	});

	describe('.addCallback', () => {
		it('defaults to empty arrays for each callback type', () => {
			const runner = buildRunner();
			expect(Array.from(runner.callbacks().entries())).toStrictEqual([
				['success', {before: [], after: []}],
				['failure', {before: [], after: []}],
			]);
		});

		it('contains callbacks when added', () => {
			const runner = buildRunnerWithBeforeSuccessAndAfterForBoth();
			expect(Array.from(runner.callbacks().entries())).toStrictEqual([
				['success', {after:[CallbackClass1], before: [CallbackClass3]}],
				['failure', {after:[CallbackClass2], before: []}],
			]);
		});

		it('orders callbacks in the order theyre received', () => {
			const runner = buildRunner();
			runner.addAfterCallback('success', CallbackClass2);
			runner.addAfterCallback('success', CallbackClass1);

			expect(runner.callbacks('success')?.after).toStrictEqual([CallbackClass2, CallbackClass1]);
		});
	});

	describe('.run', () => {
		it('does not call run when an invalid callback type is used', async () => {
			const runner = buildRunner();
			runner.addBeforeCallback('success', CallbackClass2);
			runner.addAfterCallback('success', CallbackClass1);

			const actionFor = jest.fn();

			await runner.run('fakeStatus' as any, { field: 'imaginary' }, actionFor);

			expect(runMocked).not.toHaveBeenCalled();
			expect(actionFor).not.toHaveBeenCalled();

		});

		it('calls run with proper information', async () => {
			const runner = buildRunner();
			runner.addBeforeCallback('success', CallbackClass2);
			runner.addAfterCallback('success', CallbackClass1);
			const actionFor = jest.fn();
			await runner.run('success', { field: 'imaginary' }, actionFor);

			expect(runMocked).toHaveBeenCalledWith({ field: 'imaginary' }, [CallbackClass2]);
			expect(runMocked).toHaveBeenLastCalledWith({field: 'imaginary'}, [CallbackClass1]);
			expect(actionFor).toHaveBeenCalled();
		});
	});



});

