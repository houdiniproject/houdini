// License: LGPL-3.0-or-later
import run from './run';
import { CallbackAccessor, CallbackClass, CallbackFilters, CallbackMap} from "./types";
// eslint-disable-next-line @typescript-eslint/no-unused-vars -- it's used in JSDoc
import type Callback from './Callback';

type ModifiableCallbackFilters<CallbackClass> = { after: CallbackClass[], before: CallbackClass[]};

type ModifiableCallbackMap<CallbackProps, ActionNames extends string> = Map<ActionNames, ModifiableCallbackFilters<CallbackClass<CallbackProps>>>;

/**
 * Manages the callbacks for a set of actions described by a specific action name
 * @template CallbackProps the type available in each {@link Callback} at {@link Callback.props}
 * @template ActionNames the names of the various actions which callbacks will occur on.
 * @hideConstructor
 */
export default class CallbackController<
	// eslint-disable-next-line @typescript-eslint/no-unnecessary-type-constraint
	CallbackProps extends unknown,
	ActionNames extends string,
	> implements CallbackAccessor<CallbackProps, ActionNames>{

	private _callbacks: ModifiableCallbackMap<CallbackProps, ActionNames> = new Map();

	/**
	 * @param actionNames the names of all the actions whos callbacks are managed by this object
	 */
	constructor(actionNames: ActionNames[]) {
		for (const actionName of actionNames) {
			this._callbacks.set(actionName, {before: [], after:[]});
		}

	}

	/**
	 * Add a callback to be run after an action occurs
	 * @param callbackType a string representing the particular action to
	 * @param actions
	 */
	addAfterCallback(callbackType: ActionNames, ...actions: CallbackClass<CallbackProps>[]):void {
		this.addCallback(callbackType, 'after', ...actions);
	}

	addBeforeCallback(callbackType: ActionNames, ...actions: CallbackClass<CallbackProps>[]):void {
		this.addCallback(callbackType, 'before', ...actions);
	}

	callbacks(): CallbackMap<CallbackProps, ActionNames>;
	callbacks(actionName: ActionNames): CallbackFilters<CallbackClass<CallbackProps>> | undefined;
	callbacks(actionName?: ActionNames): CallbackMap<CallbackProps, ActionNames> | CallbackFilters<CallbackClass<CallbackProps>> | undefined {
		if (actionName) {
			return this._callbacks.has(actionName) ? this._callbacks.get(actionName) : undefined;
		}
		else {
			return this._callbacks;
		}

	}

	/**
	 * The names of actions managed by this controller
	 */
	get actionNames(): ActionNames[] {
		return [...this._callbacks.keys()];
	}

	/**
	 * Runs the before callbacks for an action, the action itself and then the after callbacks for an action
	 * @param actionName the name of the action to run. If the name isn't in
	 * @param callbackProps the properties to pass each of the callbacks.
	 * @param action the action to run corresponding to the {@link actionName}
	 * @returns a promise to indicate when the last after callback has finished.
	 * @throws when one of the callbacks raises an exception and doesn't catch an exception or if {@link action} raises an
	 * exception
	 */
	async run(actionName: ActionNames, callbackProps: CallbackProps, action:()=> Promise<void>|void): Promise<void> {
		const callbacks = this.callbacks(actionName);
		if (callbacks) {

			await run(callbackProps, callbacks.before);

			await action();

			await run(callbackProps, callbacks.after);
		}
	}

	private addCallback(callbackType: ActionNames, filter: 'after'|'before', ...actions: CallbackClass<CallbackProps>[]) : void {
		const after_and_before = this._callbacks.get(callbackType);
		if (after_and_before) {
			if (filter === 'after') {
				after_and_before.after = [...after_and_before.after, ...actions];
			}
			else {
				after_and_before.before = [...after_and_before.before, ...actions];
			}
		}
	}

}


